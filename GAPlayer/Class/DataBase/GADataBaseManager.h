//
//  GADataBaseManager.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GADataBaseManager : NSObject

+ (instancetype)sharedInstance;

/**
 * 查询任务数据
 */
- (void)queryTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock;

/**
 * 查询未完成的下载的任务
 */
- (NSArray *)queryTheUnfinishedDownloadData;

/**
 * 查询已完成的下载的任务
 */
- (NSArray *)queryTheFinishedDownloadData;

/**
 * 插入任务数据
 */
- (void)insertTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock;

/**
 * 删除任务数据
 */
- (void)removeTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock;

/**
 * 修改任务数据
 */
- (void)modifyTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock;



@end
