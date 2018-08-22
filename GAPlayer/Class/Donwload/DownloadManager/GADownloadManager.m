//
//  GADownloadManager.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GADownloadManager.h"
#import "DADownloadCommon.h"
#import "DADonwloadHandle.h"
#import "DADownloadModel.h"

@interface GADownloadManager ()

// downloader
@property (nonatomic, strong) NSMutableDictionary *downloaderDict;

@end

@implementation GADownloadManager

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GADownloadManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GADownloadManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public
- (void)startDownloadWithDownloadDict:(NSDictionary *)downloadDict toResolve:(BOOL)toResolve {
    NSString *downloadId = downloadDict[@"downloadId"];
    if (toResolve) {
        [self makeDownloadModeltoResolveDownloadUrl:downloadDict];
    } else {
        id<DonwloadServiceProtocol> downloader = [self getDonwloaderWith:downloadId];
        if (downloader) {
            [downloader start];
        } else {
            [self makeDownloadModeltoResolveDownloadUrl:downloadDict];
        }
    }
}

- (void)stopTheDownloadTaskWith:(NSString *)downloadId {
    id<DonwloadServiceProtocol> downloader = [self getDonwloaderWith:downloadId];
    [downloader pauseDownload];
}

- (void)removeTheDownloadTaskWith:(NSString *)downloadId {
    id<DonwloadServiceProtocol> downloader = [self getDonwloaderWith:downloadId];
    [downloader removeDownload];
}

// 解析下载地址 并生成对应的downloader
- (void)makeDownloadModeltoResolveDownloadUrl:(NSDictionary *)downloadDict {
    __weak typeof(self)weakSelf = self;
    NSString *downloadId = downloadDict[@"downloadId"];
    NSString *downloadName = downloadDict[@"downloadName"];
    DADonwloadHandle *handle = [[DADonwloadHandle alloc] init];
    [handle downloadWithDownloadUrls:downloadDict[@"downloadUrls"] andLocalUrl:downloadDict[@"localUrl"] downloadId:downloadId andAnalysisURLBlock:^(BOOL success, id<DonwloadServiceProtocol> downloader, DownloadError *error) {
        if (success) {
            downloader.sessionDelegate = self;
            //2. 加入内存
            downloader.downloadModel.downloadTitle = downloadName;
            //4. 将downloader 加入下载字典中
            [weakSelf.downloaderDict setObject:downloader forKey:downloader.downloadModel.downloadId];
            [downloader start];
        } else {
            DADownloadModel *downloadModel = [[DADownloadModel alloc] init];
            downloadModel.downloadId = downloadId;
            [self sessionDownloadFailureWithDownloadModel:downloadModel downloadError:error];
        }
    }];
}

- (id<DonwloadServiceProtocol>)getDonwloaderWith:(NSString *)downloadId {
    return self.downloaderDict[downloadId];
}

/**
 * 开始下载将下载进度传出
 */
- (void)sessionDownloadProgressWithDownloadModel:(DADownloadModel *)downloadModel {
    if (self.downloadManagerDelegate && [self.downloadManagerDelegate respondsToSelector:@selector(downloadManagerChangeDownloadProgressWithDownloadModel:)]) {
        [self.downloadManagerDelegate downloadManagerChangeDownloadProgressWithDownloadModel:downloadModel];
    }
}

/**
 * 下载结束
 */
- (void)sessionDownloadFailureWithDownloadModel:(DADownloadModel *)downloadModel downloadError:(DownloadError *)error {
    if (self.downloadManagerDelegate && [self.downloadManagerDelegate respondsToSelector:@selector(downloadManagerChangeDownloadStateWithDownloadModel:downloadError:)]) {
        [self.downloadManagerDelegate downloadManagerChangeDownloadStateWithDownloadModel:downloadModel downloadError:error];
    }
}

- (NSMutableDictionary *)downloaderDict {
    if (!_downloaderDict) {
        _downloaderDict = [[NSMutableDictionary alloc] init];
    }
    return _downloaderDict;
}

@end
