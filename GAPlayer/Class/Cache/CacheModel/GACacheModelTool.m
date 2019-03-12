//
//  GACacheModelTool.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GACacheModelTool.h"

@implementation GACacheModelTool

+ (void)makeProgressCacheModelWith:(NSDictionary *)dict callBlock:(void (^)(BOOL success, id object))callBlock {
    GACacheModel *cacheModel = [self getCacheModelWithDatabaseDict:dict];
    callBlock(YES,cacheModel);
}

+ (NSDictionary *)makeProgressDataBaseDictWith:(GACacheModel *)cacheModel {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"videoId"] = cacheModel.videoId;
    dict[@"downloadState"] = [NSString stringWithFormat:@"%ld",cacheModel.downloadState];
    dict[@"filePath"] = cacheModel.filePath;
    dict[@"percent"] = cacheModel.percent;
    dict[@"videoName"] = cacheModel.videoName;
    dict[@"videoUrl"] = cacheModel.videoUrl;
    cacheModel.tmpDataBaseDict = [dict copy];
    return cacheModel.tmpDataBaseDict;
}

+ (NSArray *)getCacheModelListWithDatabaseDictList:(NSArray *)dictList {
    NSMutableArray *cacheModelList = [[NSMutableArray alloc] init];
    [dictList enumerateObjectsUsingBlock:^(NSDictionary *databaseDict, NSUInteger idx, BOOL * _Nonnull stop) {
        [cacheModelList addObject:[self getCacheModelWithDatabaseDict:databaseDict]];
    }];
    return cacheModelList;
}

+ (GACacheModel *)getCacheModelWithDatabaseDict:(NSDictionary *)databaseDict {
    GACacheModel *cacheModel = [[GACacheModel alloc] init];
    cacheModel.videoId = [NSString stringWithFormat:@"%ld",[databaseDict[@"videoId"] integerValue]];
    if (databaseDict[@"downloadState"]) {
        cacheModel.downloadState = [databaseDict[@"downloadState"] integerValue];
    } else {
        cacheModel.downloadState = kDADownloadStateReady;
    }
    cacheModel.filePath = [self makeProgressFilePathWithVideoId:databaseDict[@"videoId"]];
    cacheModel.percent = @"0";
    cacheModel.videoName = databaseDict[@"videoName"];
    cacheModel.videoUrl = databaseDict[@"videoUrl"];
    return cacheModel;
}

/**
 * 创建被下载文件的保存路径
 */
+ (NSString *)makeProgressFilePathWithVideoId:(NSString *)videoId {
    
    NSString *downloadFolder = [NSString stringWithFormat:@"downloads/%@", videoId];
    
    return downloadFolder;
}

+ (NSString *)makeProgressDownloadStateStringWith:(DADownloadState)downloadState {
    if (downloadState == kDADownloadStateReady) {
        return @"未下载";
    } else if (downloadState == kDADownloadStateWait) {
        return @"等待中";
    } else if (downloadState == kDADownloadStateDownloading) {
        return @"下载中";
    } else if (downloadState == kDADownloadStateCompleted) {
        return @"已完成";
    } else if (downloadState == kDADownloadStateCancelled) {
        return @"暂停";
    } else if (downloadState == kDADownloadStateFailed) {
        return @"下载失败";
    }
    return @"未下载";
}

@end
