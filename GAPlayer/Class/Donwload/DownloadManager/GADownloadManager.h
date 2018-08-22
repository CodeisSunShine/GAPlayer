//
//  GADownloadManager.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DADownloadModel;

@protocol CEDownloadManagerDelegate <NSObject>
@optional
/**
 * 当下载状态发生变化
 */
- (void)downloadManagerChangeDownloadStateWithDownloadModel:(DADownloadModel *)downloadModel downloadError:(DownloadError *)error;

/**
 * 当下载进度发生变化
 */
- (void)downloadManagerChangeDownloadProgressWithDownloadModel:(DADownloadModel *)downloadModel;

@end

@interface GADownloadManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) id <CEDownloadManagerDelegate> downloadManagerDelegate;

+ (instancetype)sharedInstance;

/**
 开启下载任务
 
 @param downloadDict 参数字典 {@"fileId":下载id,@"downloadName":下载名称,@"downloadUrls":下载地址数组,@"localUrl":相应的本地储存地址}
 @param toResolve 是否重新解析下载地址
 */
- (void)startDownloadWithDownloadDict:(NSDictionary *)downloadDict toResolve:(BOOL)toResolve;

/**
 暂停下载任务
 
 @param downloadId 下载id
 */
- (void)stopTheDownloadTaskWith:(NSString *)downloadId;

/**
 删除下载任务
 
 @param downloadId 下载id
 */
- (void)removeTheDownloadTaskWith:(NSString *)downloadId;

@end
