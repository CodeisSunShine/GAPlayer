//
//  GACacheManager.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GACacheModel;

//声明类型SDCallbacksDictionary key=NSString，value=id
typedef NSMutableDictionary<NSString *, id> DACallbacksDictionary;
typedef void(^DAProgressCallBlock)(NSString *downloadId, NSString *progress, int64_t speed);
typedef void(^DADownloadStateCallBlock)(NSString *downloadId, NSInteger downloadState);
typedef void(^DAFinishCallBlock)(NSString *downloadId, BOOL success, NSError *error);

@interface GACacheManager : NSObject

+ (instancetype)sharedInstance;

/**
 绑定下载回调
 
 @param progressBlock 返回下载进度和下载id
 @param finishBlock 下载成功 / 下载失败返回 失败原因
 */
- (void)addProgressBlock:(DAProgressCallBlock)progressBlock
      downloadStateBlock:(DADownloadStateCallBlock)downloadStateBlock
             finishBlock:(DAFinishCallBlock)finishBlock
                 idClass:(NSString *)idClass;

/**
 * 解除绑定的回调
 */
- (void)removeDonwloadBlcokWithIdClass:(NSString *)idClass;

/**
 * 加入下载
 */
- (void)addDownloadWith:(NSDictionary *)downloadDict callBlock:(void (^)(BOOL success, id object))callBlock;

/**
 * 下载操作
 */
- (void)downloadIsControlledAccordingToVideoId:(NSString *)videoId callBlock:(void (^)(BOOL success, id object))callBlock;

/**
 * 检测数据库是否有未完成的下载任务
 */
- (void)queryingTheDatabaseUnfinishedDownloadTaskCallBlock:(void (^)(BOOL success))callBlock;

/**
 * 全部暂停
 */
- (void)allSuspended;

/**
 * 全部下载 当前任务列表所有的任务
 */
- (void)allStart;

@end
