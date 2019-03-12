//
//  GADataBaseManager+GACacheModel.m
//  GAPlayer
//
//  Created by 宫傲 on 2019/3/8.
//  Copyright © 2019年 宫傲. All rights reserved.
//

#import "GADataBaseManager+GACacheModel.h"
#import "GACacheModelTool.h"

@implementation GADataBaseManager (GACacheModel)

/**
 * 查询任务数据
 */
- (void)queryCacheTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, GACacheModel *cacheModel))resultBlock {
    [self queryTaskData:dict resultBlock:^(BOOL success, id object) {
        if (success) {
            resultBlock(YES, [GACacheModelTool getCacheModelWithDatabaseDict:object]);
        } else {
            resultBlock(success, object);
        }
    }];
}

/**
 * 查询未完成的下载的任务
 */
- (void)queryCacheTheUnfinishedDownloadDataWithResultBlock:(void (^)(BOOL success, NSArray *cacheList))resultBlock {
    [self queryTheUnfinishedDownloadDataWithResultBlock:^(BOOL success, id object) {
        if (success) {
            resultBlock(YES, [GACacheModelTool getCacheModelListWithDatabaseDictList:object]);
        } else {
            resultBlock(success, object);
        }
    }];
}

/**
 * 查询已完成的下载的任务
 */
- (NSArray *)queryCacheTheFinishedDownloadData {
    return [self queryTheFinishedDownloadData];
}

/**
 * 插入任务数据
 */
- (void)insertCacheTaskData:(GACacheModel *)cacheModel resultBlock:(void (^)(BOOL success, id object))resultBlock {
    NSDictionary *dict = [GACacheModelTool makeProgressDataBaseDictWith:cacheModel];
    [self insertTaskData:dict resultBlock:resultBlock];
}

/**
 * 删除任务数据
 */
- (void)removeCacheTaskData:(GACacheModel *)cacheModel resultBlock:(void (^)(BOOL success, id object))resultBlock {
    NSDictionary *dict = [GACacheModelTool makeProgressDataBaseDictWith:cacheModel];
    [self removeTaskData:dict resultBlock:resultBlock];
}

/**
 * 修改任务数据
 */
- (void)modifyCacheTaskData:(GACacheModel *)cacheModel resultBlock:(void (^)(BOOL success, id object))resultBlock {
    NSDictionary *dict = [GACacheModelTool makeProgressDataBaseDictWith:cacheModel];
    [self modifyTaskData:dict resultBlock:resultBlock];
}

@end
