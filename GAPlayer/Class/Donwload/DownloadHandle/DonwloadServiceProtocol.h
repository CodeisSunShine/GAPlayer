//
//  DonwloadServiceProtocol.h
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/23.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DADownloadCommon.h"

@class DADownloadModel,DownloadError;

@protocol DADownloadSessionDelegate <NSObject>
@optional

/**
 * 开始下载将下载进度传出
 */
- (void)sessionDownloadProgressWithDownloadModel:(DADownloadModel *)downloadModel;

/**
 * 下载结束
 */
- (void)sessionDownloadFailureWithDownloadModel:(DADownloadModel *)downloadModel downloadError:(DownloadError *)error;

@end

@protocol DonwloadServiceProtocol <NSObject>

@property (nonatomic, weak) id <DADownloadSessionDelegate> sessionDelegate;

//下载模型
@property (nonatomic, strong, readonly) DADownloadModel *downloadModel;

/**
 * 开始下载
 */
- (void)start;

/**
 * 暂停下载
 */
- (void)pauseDownload;
                        
/**
 * 删除下载
 */
- (void)removeDownload;

@end
