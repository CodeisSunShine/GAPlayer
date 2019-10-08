//
//  DADownloadSession.m
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "DADownloadSession.h"
#import "DADownloadModel.h"
#import "DADownloadItem.h"
#import "DADownloadItemModel.h"
#import <UIKit/UIKit.h>
#import "DownloadError.h"

#define kMaxReconnection 3
#define kMaxDownloadingCount 1

@interface DADownloadSession ()<NSURLSessionDownloadDelegate,NSURLSessionDownloadDelegate>

//下载的session
@property (nonatomic, strong) NSURLSession *session;
//下载模型字典
@property (nonatomic, strong) NSMutableDictionary *downloadTaskDict;
//下载进度
@property (nonatomic, strong) NSProgress *progress;
//下载索引
@property (nonatomic, assign) NSInteger currentIndex;
//当前下载 downloadItem
@property (nonatomic, strong) DADownloadItem *downloadItem;
//下载中个数
@property (nonatomic, assign) CGFloat downloadingCount;

@property (atomic, assign) BOOL isPause;

@end

@implementation DADownloadSession

- (instancetype)initWithDownloadModel:(DADownloadModel *)downloadModel {
    if (self = [super init]) {
        self.downloadingCount = 0;
        _downloadModel = downloadModel;
        self.session = [self getDownloadURLSession];
        self.currentIndex = 0;
        [self mekeProgressTaskDict];
    }
    return self;
}

#pragma mark - public
//开始下载
- (void)start {
    @synchronized(self) {
        self.isPause = NO;
        [self download];
    }
}

//暂停下载
- (void)pauseDownload {
    NSLog(@"pauseDownload    pauseDownload  pauseDownload");
    @synchronized(self) {
        self.isPause = YES;
        self.downloadingCount = 0;
        [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_t seamphore = dispatch_semaphore_create(0);
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    dispatch_semaphore_signal(seamphore);
                }];
                dispatch_semaphore_wait(seamphore, waitTime);
            }
        }];
    }
}

//删除下载
- (void)removeDownload {
    [self pauseDownload];
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark - private
- (void)download {
    @synchronized(self) {
        if (self.isPause) return;
        // 每个下载任务的最大并发量
        if (self.downloadingCount < kMaxDownloadingCount) {
            if (self.currentIndex < self.downloadModel.downloadItemArray.count) {
                DADownloadItemModel *itemModel = self.downloadModel.downloadItemArray[self.currentIndex];
                BOOL exist = [self downloadTaskCheckExistDownloadItemModel:itemModel];
                NSString *downloadUrl = itemModel.downloadUrl;
                if (exist) {
                    [self downloadTaskExist:downloadUrl];
                } else {
                    [self downloadTaskNoneExist:downloadUrl];
                }
            } else {
                [self downloadFinish];
            }
        }
    }
}

//检测当前下载任务是否已经完成
- (BOOL)downloadTaskCheckExistDownloadItemModel:(DADownloadItemModel *)itemModel {
    NSString *localUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"%@",itemModel.finishLocalName];
    //1. 判断当前任务是否已经下载完成
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:localUrl];
    return exist;
}

//当前下载任务已经完成
- (void)downloadTaskExist:(NSString *)downloadUrl {
    DADownloadItem *downloadItem = self.downloadTaskDict[downloadUrl];
    [self downloadItemFinishWith:downloadItem];
    self.currentIndex++;
    [self download];
}

//进度发生改变
- (void)downloadItemFinishWith:(DADownloadItem *)downloadItem {
    downloadItem.itemModel.isFinish = @"1";
    if (downloadItem.progress) {
        downloadItem.progress.completedUnitCount = downloadItem.progress.totalUnitCount;
    } else {
        self.progress.completedUnitCount += 1;
    }
    self.downloadModel.progress = [NSString stringWithFormat:@"%f",self.progress.fractionCompleted];
}

//当前下载任务未经完成
- (void)downloadTaskNoneExist:(NSString *)downloadUrl {
    //2. 如果本地没有已完成文件则检测 downloadTaskDict 中是否有下载item
    if (self.downloadTaskDict[downloadUrl]) {
        DADownloadItem *downloadItem = self.downloadTaskDict[downloadUrl];
        [self downloadTaskStartWith:downloadItem];
    } else {
        NSLog(@"不存在  DADownloadItem ");
    }
    self.currentIndex++;
    [self download];
}

- (void)downloadTaskStartWith:(DADownloadItem *)downloadItem {
    //2.1 如果此item已达 失败次数 超过 kMaxReconnection 次则跳过
    if (downloadItem.maxReconnection < kMaxReconnection) {
        //2.2 继续下载
        self.downloadItem = downloadItem;
        [self.downloadItem createDonwloadTaskWith:self.session];
        [downloadItem.downloadTask resume];
        self.downloadingCount++;
    }
}

// 下载完成
- (void)downloadFinish {
    // 之后需要进行视频完整性检测
    NSLog(@"视频完整性检测");
    [self videoIntegrityTest:^(BOOL success, id object) {
        if (success) {
            if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(sessionDownloadFailureWithDownloadModel:downloadError:)]) {
                [self.sessionDelegate sessionDownloadFailureWithDownloadModel:self.downloadModel downloadError:[[DownloadError alloc] initWithinishCode:kDADownloadFinishCodeSuccess error:nil]];
            }
        } else {
            DownloadError *downloadError = [[DownloadError alloc] initWithinishCode:kDADownloadFinishCodeIncomplete customeReason:object];
            [self downloadFailureHandlingWith:downloadError];
        }
    }];
}

- (void)videoIntegrityTest:(void (^)(BOOL success, id object))successBlock {
    __block NSMutableArray *undownloadedTasks = [[NSMutableArray alloc] init];
    [self.downloadModel.downloadItemArray enumerateObjectsUsingBlock:^(DADownloadItemModel *itemModel, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL exist = [self downloadTaskCheckExistDownloadItemModel:itemModel];
        if (!exist) {
            [undownloadedTasks addObject:itemModel];
        }
    }];
    if (undownloadedTasks.count && undownloadedTasks.count > 0) {
        NSString *downloadTaskString = [undownloadedTasks componentsJoinedByString:@"-"];
        self.currentIndex = 0;
        successBlock(NO,downloadTaskString);
    } else {
        successBlock(YES,nil);
    }
}

- (void)currentTaskSuccessWith:(DADownloadItem *)downloadItem {
    //3.3 切片转移成功 继续下载下一个切片
    @synchronized(self) {
        [self downloadItemFinishWith:downloadItem];
        [self download];
    }
}

- (void)currentTaskFailWith:(DADownloadItem *)downloadItem {
    @synchronized(self) {
        self.currentIndex--;
        [self download];
    }
}

//下载失败
- (void)downloadFailueWithFailCode:(DADownloadFinishCode)finishCode error:(NSError *)error {
    if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(sessionDownloadFailureWithDownloadModel:downloadError:)]) {
        [self.sessionDelegate sessionDownloadFailureWithDownloadModel:self.downloadModel downloadError:[[DownloadError alloc] initWithinishCode:finishCode error:error]];
    }
}

// 根据 downloadTask 获取 DADownloadItem
- (DADownloadItem *)getDonwloadItemWith:(NSURLSessionTask *)downloadTask {
    @synchronized(self) {
        DADownloadItem *downloadItem = self.downloadTaskDict[downloadTask.currentRequest.URL.absoluteString];
        if (!downloadItem) {
            [self downloadFailueWithFailCode:kDADownloadFinishCodeItemLose error:nil];
            NSLog(@"Item丢失 %@",downloadTask.currentRequest.URL.absoluteString);
            [self reduceDownloadingCount];
            self.currentIndex--;
        }
        return downloadItem;
    }
}

// 处理 downloadItem 的 progress
- (void)makeProgessDownloadItemProgress:(DADownloadItem *)downloadItem
                      totalBytesWritten:(int64_t)totalBytesWritten
              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (!downloadItem.progress) {
        [self.progress becomeCurrentWithPendingUnitCount:1];
        downloadItem.progress = [NSProgress progressWithTotalUnitCount:totalBytesExpectedToWrite];
        [self.progress resignCurrent];
    }
    downloadItem.itemModel.totalBytesWritten = [NSString stringWithFormat:@"%lld",totalBytesWritten];
    downloadItem.itemModel.totalBytesExpectedToWrite = [NSString stringWithFormat:@"%lld",totalBytesExpectedToWrite];
    downloadItem.progress.completedUnitCount = totalBytesWritten;
}

// 下载进度回调
- (void)downloadProgessCallBackWith:(int64_t)bytesWritten {
    self.downloadModel.progress = [NSString stringWithFormat:@"%f",self.progress.fractionCompleted];
    self.downloadModel.bytesWritten = bytesWritten;
    if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(sessionDownloadProgressWithDownloadModel:)]) {
        [self.sessionDelegate sessionDownloadProgressWithDownloadModel:self.downloadModel];
    }
}

// 删除ResumeData文件
- (void)removeResumeDataWithDownloadItem:(DADownloadItem *)downloadItem {
    NSString *resumDataUrl = [self getLocationURLWith:downloadItem.itemModel.resumDataLocalName];
    //1. 删除resumeData
    NSError *resumeError = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:resumDataUrl]) {
        //存在
        [[NSFileManager defaultManager] removeItemAtPath:resumDataUrl error:&resumeError];
    }
}

// 保存ResumeData文件
- (void)saveResumeDataWithDownloadItem:(DADownloadItem *)downloadItem resumeData:(NSData *)resumeData{
    NSString *resumDataUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"%@",downloadItem.itemModel.resumDataLocalName];
    //有数据，保存在本地
    [resumeData writeToFile:resumDataUrl atomically:NO];
}

- (void)moveLocationDataWithDownloadItem:(DADownloadItem *)downloadItem moveItemAtPath:(NSString *)locationString {
    NSString *localUrl = [self getLocationURLWith:downloadItem.itemModel.finishLocalName];
    NSError *onceError = [self downloadMoveItemAtPath:locationString toPath:localUrl];
    if (onceError) {//第一次转移失败有可能是因为locationString记录的是上一个沙盒的地址(苹果bug)
        NSString *newLocationString = [self getNewLocalUrlWith:locationString];
        NSError *secondError = [self downloadMoveItemAtPath:newLocationString toPath:localUrl];
        if (secondError) {
            [self downloadFailueWithFailCode:kDADownloadFinishCodeMoveFail error:secondError];
        }
    }
}

- (NSString *)getNewLocalUrlWith:(NSString *)localUrl {
    NSArray *paths = [localUrl componentsSeparatedByString:@"Caches"];
    if (paths.count > 1) {
        NSString *newLocalUrl = [self getCacheFileURLWith:paths.lastObject];
        return newLocalUrl;
    } else {
        return localUrl;
    }
}

// 将指定文件转移到指定文件
- (NSError *)downloadMoveItemAtPath:(NSString *)locationString toPath:(NSString *)toPath {
    NSError *moveError = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:toPath error:&moveError];
    }
    return moveError;
}

// 下载中数量减一
- (void)reduceDownloadingCount {
    @synchronized(self) {
        self.downloadingCount--;
        if (self.downloadingCount < 0) {
            self.downloadingCount = 0;
        }
    }
}

- (NSString *)getLocationURLWith:(NSString *)savePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"%@",savePath];
}

- (NSString *)getCacheFileURLWith:(NSString *)savePath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"%@",savePath];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    DADownloadItem *downloadItem = [self getDonwloadItemWith:downloadTask];
    if (downloadItem) {
        [self makeProgessDownloadItemProgress:downloadItem totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        [self downloadProgessCallBackWith:bytesWritten];
    }
}

/*
 * 告诉委托一个下载任务完成下载。
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
    DADownloadItem *downloadItem = [self getDonwloadItemWith:downloadTask];
    if (downloadItem) {
        [self removeResumeDataWithDownloadItem:downloadItem];
        NSString *locationString = [location path];
        [self moveLocationDataWithDownloadItem:downloadItem moveItemAtPath:locationString];
    }
}

/*
 * 在任务下载完成，下载失败 或者应用被杀掉后，重新启动应用并创建相关identifier的Session时调用
 * 在下载失败时，erro 的 userInfo属性可以通过NSURLSessionDownloadTaskResumeData
 * 这个key来取到resumeData（和上面的resumeData时一样的），在通过resumeData恢复下载
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDownloadTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"didCompleteWithError");
    DADownloadItem *downloadItem = [self getDonwloadItemWith:task];
    if (downloadItem) {
        [self reduceDownloadingCount];
        if (error) {
            if ([[error.userInfo objectForKey:NSLocalizedDescriptionKey] isEqualToString:@"cancelled"]) {
                //主动取消
                if([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
                    [self saveResumeDataWithDownloadItem:downloadItem resumeData:[error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]];
                }
            } else {
                NSLog(@"下载出错 code ====== %ld ------ error ====== %@",(long)error.code,error);
            }
            [self currentTaskFailWith:downloadItem];
        } else {
            [self currentTaskSuccessWith:downloadItem];
        }
    }
}

- (NSURLSession *)getDownloadURLSession {
    NSURLSession *session = nil;
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@",self.downloadModel.downloadId]];
    sessionConfig.timeoutIntervalForRequest = 20;
    session = [NSURLSession sessionWithConfiguration:sessionConfig
                                            delegate:self
                                       delegateQueue:[NSOperationQueue mainQueue]];
    
    return session;
}

- (void)mekeProgressTaskDict {
    self.progress = [NSProgress progressWithTotalUnitCount:self.downloadModel.downloadItemArray.count];
    self.downloadTaskDict = [[NSMutableDictionary alloc] init];
    __block NSInteger finishCount = 0;
    __weak typeof(self)weakSelf = self;
    [self.downloadModel.downloadItemArray enumerateObjectsUsingBlock:^(DADownloadItemModel *itemModel, NSUInteger idx, BOOL * _Nonnull stop) {
        DADownloadItem *downloadItem = [[DADownloadItem alloc] init];
        downloadItem.itemModel = itemModel;
        downloadItem.maxReconnection = 0;
        if (itemModel.isFinish && [itemModel.isFinish isEqualToString:@"1"]) {
            finishCount++;
        } else {
            if (itemModel.totalBytesExpectedToWrite.length > 0 && itemModel.totalBytesWritten.length > 0 && [itemModel.totalBytesExpectedToWrite integerValue] > 0) {
                [weakSelf.progress becomeCurrentWithPendingUnitCount:1];
                downloadItem.progress = [NSProgress progressWithTotalUnitCount:atoll([itemModel.totalBytesExpectedToWrite UTF8String])];
                downloadItem.progress.completedUnitCount = atoll([itemModel.totalBytesWritten UTF8String]);
                [weakSelf.progress resignCurrent];
            }
        }
        [weakSelf.downloadTaskDict setObject:downloadItem forKey:itemModel.downloadUrl];
    }];
    self.progress.completedUnitCount = finishCount;
}

// 错误产生的回调
- (void)downloadFailureHandlingWith:(DownloadError *)downloadError {
    if (self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(sessionDownloadFailureWithDownloadModel:downloadError:)]) {
        [self.sessionDelegate sessionDownloadFailureWithDownloadModel:self.downloadModel downloadError:downloadError];
    }
}

@end
