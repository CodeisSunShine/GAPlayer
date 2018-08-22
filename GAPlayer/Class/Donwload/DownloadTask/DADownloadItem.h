//
//  DADownloadItem.h
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DADownloadItemModel;

@interface DADownloadItem : NSObject

/**
 * 下载task
 */
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

/**
 * 单个任务下载失败最大重连次数
 */
@property (nonatomic, assign) NSInteger maxReconnection;

/**
 * 当前下载任务的进度
 */
@property (nonatomic, strong) NSProgress *progress;


@property (nonatomic, strong) DADownloadItemModel *itemModel;

- (void)createDonwloadTaskWith:(NSURLSession *)session;

@end
