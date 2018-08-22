//
//  GACacheManager.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GACacheManager.h"
#import "GADownloadManager.h"
#import "DownloadMemory.h"
#import "DownloadError.h"
#import "GACacheModelTool.h"
#import "GACacheModel.h"
#import "DADownloadModel.h"
#import "GADataBaseManager.h"

static NSString *const kProgressCallbackKey = @"Progress";
static NSString *const kDownloadStateCallbackKey = @"downloadState";
static NSString *const kFinishCallbackKey = @"Finish";

@interface GACacheManager () <CEDownloadManagerDelegate>

// 回调数据源
@property (nonatomic, strong, nonnull) NSMutableDictionary *callbackBlocks;
// video数据源
@property (nonatomic, strong) NSMutableArray *donwloadCacheList;
// 最大同时下载数量
@property (nonatomic, assign) NSInteger maxDonwloadingCount;
// 缓存数据库
@property (nonatomic, strong) GADataBaseManager *dataBaseManager;
// 下载器
@property (nonatomic, strong) GADownloadManager *downloadManager;
// 内存计算器
@property (nonatomic, strong) DownloadMemory *downloadMemory;
// 临时字典
@property (nonatomic, copy) NSDictionary *tmpDownloadDict;

@end

@implementation GACacheManager

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GACacheManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GACacheManager alloc] init];
    });
    return sharedInstance;
}

/**
 绑定下载回调
 
 @param progressBlock 返回下载进度和下载id
 @param finishBlock 下载成功 / 下载失败返回 失败原因
 */
- (void)addProgressBlock:(DAProgressCallBlock)progressBlock
      downloadStateBlock:(DADownloadStateCallBlock)downloadStateBlock
             finishBlock:(DAFinishCallBlock)finishBlock
                 idClass:(NSString *)idClass {
    __weak __typeof(self) weakself= self;
    @synchronized(self) {
        DACallbacksDictionary *callbacksDictionary = [[DACallbacksDictionary alloc] init];
        [callbacksDictionary setObject:progressBlock forKey:kProgressCallbackKey];
        [callbacksDictionary setObject:downloadStateBlock forKey:kDownloadStateCallbackKey];
        [callbacksDictionary setObject:finishBlock forKey:kFinishCallbackKey];
        [weakself.callbackBlocks setObject:callbacksDictionary forKey:idClass];
    }
}

// 删除回调
- (void)removeDonwloadBlcokWithIdClass:(NSString *)idClass {
    if (idClass.length > 0) {
        DACallbacksDictionary *callbacksDictionary = self.callbackBlocks[idClass];
        if (callbacksDictionary) {
            [self.callbackBlocks removeObjectForKey:idClass];
        }
    }
}

// 下载状态变化的回调
- (void)downloadStateCallBack:(GACacheModel *)cacheModel {
    [self.callbackBlocks.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *blockDict = self.callbackBlocks[obj];
        DADownloadStateCallBlock downloadStateCallBlock = blockDict[kDownloadStateCallbackKey];
        if (downloadStateCallBlock) {
            downloadStateCallBlock (cacheModel.videoId, cacheModel.downloadState);
        }
    }];
}

// 下载进度变化的回调
- (void)downloadProgressCallBack:(GACacheModel *)cacheModel {
    __weak typeof(self)weakSelf = self;
    [self.callbackBlocks.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int64_t speed = 0;
        [weakSelf.downloadMemory getSpeedWithFileId:cacheModel.videoId];
        NSMutableDictionary *blockDict = weakSelf.callbackBlocks[obj];
        DAProgressCallBlock progressCallBlock = blockDict[kProgressCallbackKey];
        if (progressCallBlock) {
            progressCallBlock (cacheModel.videoId, cacheModel.percent ,speed);
        }
    }];
}

#pragma mark - 下载操作
- (void)addDownloadWith:(NSDictionary *)downloadDict callBlock:(void (^)(BOOL success, id object))callBlock {
    //1.将dict 转CacheModel
    NSString *videoId = downloadDict[@"videoId"];
    self.tmpDownloadDict = downloadDict;
    [self downloadIsControlledAccordingToVideoId:videoId callBlock:callBlock];
}

- (void)downloadIsControlledAccordingToVideoId:(NSString *)videoId callBlock:(void (^)(BOOL success, id object))callBlock {
    if (!(videoId && videoId.length > 0)) {
        callBlock(NO,nil);
    }
    __block GACacheModel *currentCacheModel = [self getCacheModelWithFileId:videoId];
    if (currentCacheModel) {
        self.tmpDownloadDict = nil;
        [self startDownloadWith:currentCacheModel];
    } else {
        NSDictionary *quaryDict = @{@"videoId":videoId};
        __weak __typeof(self) weakself= self;
        [self.dataBaseManager queryTaskData:quaryDict resultBlock:^(BOOL success, id object) {
            if (success) {
                [weakself makeProgressAddNewCacheModel:object callBlock:callBlock];
            } else {
                [weakself makeProgressAddNewCacheModel:weakself.tmpDownloadDict callBlock:callBlock];
            }
            self.tmpDownloadDict = nil;
        }];
    }
}

- (void)startDownloadWith:(GACacheModel *)currentCacheModel {
    //3. 开启下载
    if (currentCacheModel.downloadState == kDADownloadStateReady || currentCacheModel.downloadState == kDADownloadStateCancelled || currentCacheModel.downloadState == kDADownloadStateFailed) {
        if ([self getDownloadingCount] < self.maxDonwloadingCount) {
            [self beginStartDownload:currentCacheModel];
        } else {
            currentCacheModel.downloadState = kDADownloadStateWait;
        }
    } else if (currentCacheModel.downloadState == kDADownloadStateWait) {
        if ([self getDownloadingCount] < self.maxDonwloadingCount) {
            [self beginStartDownload:currentCacheModel];
        } else {
            currentCacheModel.downloadState = kDADownloadStateCancelled;
        }
    } else if (currentCacheModel.downloadState == kDADownloadStateDownloading) {
        [self beginPauseDownload:currentCacheModel];
        [self beginNextDownload];
    }
    [self makeProgressDownloadState:currentCacheModel];
}

// 开启下载
- (void)beginStartDownload:(GACacheModel *)cacheModel {
    cacheModel.downloadState = kDADownloadStateDownloading;
    [self makeProgressDownloadState:cacheModel];
    NSDictionary *downloadDict = [self makeProgressDownloadDict:cacheModel];
    [self.downloadManager startDownloadWithDownloadDict:downloadDict toResolve:YES];
}

- (NSDictionary *)makeProgressDownloadDict:(GACacheModel *)cacheModel {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"downloadId"] = cacheModel.videoId;
    dict[@"downloadName"] = cacheModel.videoName;
    NSMutableArray *downloadUrls = [[NSMutableArray alloc] init];
    [downloadUrls addObject:cacheModel.videoUrl];
    dict[@"downloadUrls"] = [downloadUrls copy];
    dict[@"localUrl"] = cacheModel.filePath;
    return dict;
}

// 暂停下载
- (void)beginPauseDownload:(GACacheModel *)cacheModel {
    cacheModel.downloadState = kDADownloadStateCancelled;
    [self makeProgressDownloadState:cacheModel];
    [self.downloadManager stopTheDownloadTaskWith:cacheModel.videoId];
}

- (void)beginNextDownload {
    GACacheModel *cacheModel = [self getWaittingCacheModel];
    if (cacheModel) {
        [self beginStartDownload:cacheModel];
    }
}

- (void)queryAllDownloadedTasksSuccessBlock:(void (^)(BOOL success, NSArray *cacheList))successBlock {
    [self.dataBaseManager queryTheUnfinishedDownloadData:nil resultBlock:^(BOOL success, id object) {
//        [self addMultipleDownloadTasks:object];
        successBlock(YES,object);
    }];
}

- (void)querySingleDownloadData:(NSDictionary *)dict {

}

#pragma mark - 数据库操作
// 插入单个数据数据库中
- (void)insertSingleDownloadTargeWithCacheModel:(GACacheModel *)cacheModel {
    NSDictionary *sqlDict = [GACacheModelTool makeProgressDataBaseDictWith:cacheModel];
    [self.dataBaseManager insertTaskData:sqlDict resultBlock:^(BOOL success, id object) {
        if (success) {
            NSLog(@"数据插入成功");
        } else {
            NSLog(@"数据插入失败");
        }
    }];
}

// 更新单个数据数据库中
- (void)saveSingleDownloadTargeWithCacheModel:(GACacheModel *)cacheModel {
    NSDictionary *sqlDict = [GACacheModelTool makeProgressDataBaseDictWith:cacheModel];
    [self.dataBaseManager modifyTaskData:sqlDict resultBlock:^(BOOL success, id object) {
        if (success) {
            NSLog(@"数据更新成功");
        } else {
            NSLog(@"数据更新失败");
        }
    }];
}

#pragma mark - CEDownloadManagerDelegate
// 下载结束 和 出错处理
- (void)downloadManagerChangeDownloadStateWithDownloadModel:(DADownloadModel *)downloadModel downloadError:(DownloadError *)error {
    GACacheModel *currentdModel = [self getCacheModelWithFileId:downloadModel.downloadId];
    if (currentdModel) {
        if (error.finishCode == kDADownloadFinishCodeSuccess) {
            currentdModel.downloadState = kDADownloadStateCompleted;
            [self saveSingleDownloadTargeWithCacheModel:currentdModel];
            [self makeProgressDownloadState:currentdModel];
        } else {
            NSLog(@"下载失败%@%@%ld",error.customeReason, error.systemError, error.finishCode);
            [self downloadFailedCallback:currentdModel];
            if (error.finishCode == kDADownloadFinishCodeIncomplete) {
                NSLog(@"删除下载任务");
            }
        }
    } else {
        NSLog(@"内存中找不到 cacheModel 需要根据业务进行处理");
    }
    [self beginNextDownload];
}

// 当下载进度发生变化
- (void)downloadManagerChangeDownloadProgressWithDownloadModel:(DADownloadModel *)downloadModel {
    GACacheModel *currentdModel = [self getCacheModelWithFileId:downloadModel.downloadId];
    if (currentdModel) {
        currentdModel.bytesWritten = downloadModel.bytesWritten;
        currentdModel.percent = downloadModel.progress;
        [self saveDownloadBytesWritten:currentdModel];
        [self saveSingleDownloadTargeWithCacheModel:currentdModel];
        [self downloadProgressCallBack:currentdModel];
    } else {
        NSLog(@"内存中找不到 cacheModel 需要根据业务进行处理");
    }
}

#pragma mark - private
- (void)makeProgressAddNewCacheModel:(NSDictionary *)dataDict callBlock:(void (^)(BOOL success, id object))callBlock {
    __weak __typeof(self) weakself= self;
    [GACacheModelTool makeProgressCacheModelWith:dataDict callBlock:^(BOOL success, id object) {
        if (success) {
            GACacheModel *cacheModel = (GACacheModel *)object;
            [weakself insertSingleDownloadTargeWithCacheModel:cacheModel];
            [weakself.donwloadCacheList addObject:cacheModel];
            [weakself startDownloadWith:cacheModel];
            callBlock(YES,cacheModel);
        } else {
            callBlock(NO,nil);
        }
    }];
}


// 下载失败回调
- (void)downloadFailedCallback:(GACacheModel *)currentdModel {
    currentdModel.downloadState = kDADownloadStateFailed;
    [self makeProgressDownloadState:currentdModel];
}

- (void)saveDownloadBytesWritten:(GACacheModel *)cacheModel {
    [self.downloadMemory makeProgressFileId:cacheModel.videoId bytesWritten:cacheModel.bytesWritten];
}

// 加入多个下载任务
- (void)addMultipleDownloadTasks:(NSArray *)cacheList {
    for (NSInteger i = 0; i < cacheList.count; i++) {
        GACacheModel *currentCacheModel = cacheList[i];
        GACacheModel *thereCacheModel = [self getCacheModelWithFileId:currentCacheModel.videoId];
        if (!thereCacheModel) {
            [self.donwloadCacheList addObject:currentCacheModel];
        }
    }
}

- (void)makeProgressDownloadState:(GACacheModel *)cacheModel {
    // 1.存库
    [self saveSingleDownloadTargeWithCacheModel:cacheModel];
    // 2.回调
    [self downloadStateCallBack:cacheModel];
}

// 获取 downloadModel
- (GACacheModel *)getCacheModelWithFileId:(NSString *)fileId {
    __block GACacheModel *currentdModel;
    if (fileId) {
        //1. 内存是否存在 downloadModel 存在则取出
        [self.donwloadCacheList enumerateObjectsUsingBlock:^(GACacheModel *cacheModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cacheModel.videoId isEqualToString:fileId]) {
                currentdModel = cacheModel;
                *stop = YES;
            }
        }];
    }
    return currentdModel;
}

// 获取 downloadModel
- (GACacheModel *)getWaittingCacheModel {
    //1. 内存是否存在 downloadModel 存在则取出
    __block GACacheModel *currentdModel;
    [self.donwloadCacheList enumerateObjectsUsingBlock:^(GACacheModel *cacheModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cacheModel.downloadState == kDADownloadStateWait) {
            currentdModel = cacheModel;
            *stop = YES;
        }
    }];
    return currentdModel;
}

// 获取 正在下载中的数量
- (NSInteger)getDownloadingCount {
    __block NSInteger downloadingCount = 0;
    [self.donwloadCacheList enumerateObjectsUsingBlock:^(GACacheModel *cacheModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cacheModel.downloadState == kDADownloadStateDownloading) {
            downloadingCount ++;
        }
    }];
    return downloadingCount;
}

- (NSInteger)maxDonwloadingCount {
    return 2;
}

- (GADataBaseManager *)dataBaseManager {
    if (!_dataBaseManager) {
        _dataBaseManager = [GADataBaseManager sharedInstance];
    }
    return _dataBaseManager;
}

- (NSMutableDictionary *)callbackBlocks {
    if (!_callbackBlocks) {
        _callbackBlocks = [[NSMutableDictionary alloc] init];
    }
    return _callbackBlocks;
}

- (NSMutableArray *)donwloadCacheList {
    if (!_donwloadCacheList) {
        _donwloadCacheList = [[NSMutableArray alloc] init];
    }
    return _donwloadCacheList;
}

- (GADownloadManager *)downloadManager {
    if (!_downloadManager) {
        _downloadManager = [GADownloadManager sharedInstance];
        _downloadManager.downloadManagerDelegate = self;
    }
    return _downloadManager;
}

- (DownloadMemory *)downloadMemory {
    if (!_downloadMemory) {
        _downloadMemory = [[DownloadMemory alloc] init];
    }
    return _downloadMemory;
}


@end
