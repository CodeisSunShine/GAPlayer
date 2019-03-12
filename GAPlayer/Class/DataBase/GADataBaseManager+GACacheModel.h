//
//  GADataBaseManager+GACacheModel.h
//  GAPlayer
//
//  Created by 宫傲 on 2019/3/8.
//  Copyright © 2019年 宫傲. All rights reserved.
//

#import "GADataBaseManager.h"
#import "GACacheModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADataBaseManager (GACacheModel)

/**
 * 查询任务数据
 */
- (void)queryCacheTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, GACacheModel *cacheModel))resultBlock;

/**
 * 查询未完成的下载的任务
 */
- (void)queryCacheTheUnfinishedDownloadDataWithResultBlock:(void (^)(BOOL success, NSArray *cacheList))resultBlock;

/**
 * 查询已完成的下载的任务
 */
- (NSArray *)queryCacheTheFinishedDownloadData;

/**
 * 插入任务数据
 */
- (void)insertCacheTaskData:(GACacheModel *)cacheModel resultBlock:(void (^)(BOOL success, id object))resultBlock;

/**
 * 删除任务数据
 */
- (void)removeCacheTaskData:(GACacheModel *)cacheModel resultBlock:(void (^)(BOOL success, id object))resultBlock;

/**
 * 修改任务数据
 */
- (void)modifyCacheTaskData:(GACacheModel *)cacheModel resultBlock:(void (^)(BOOL success, id object))resultBlock;



@end

NS_ASSUME_NONNULL_END
