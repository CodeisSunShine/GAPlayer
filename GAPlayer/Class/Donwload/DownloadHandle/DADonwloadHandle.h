//
//  DADonwloadHandle.h
//  DownloadFramework
//
//  Created by 宫傲 on 2018/6/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DonwloadServiceProtocol.h"

@class DADownloadSession,DADownloadModel;

@interface DADonwloadHandle : NSObject

/**
 加入下载
 downloadUrls与localUrls数据必须一致，否则直接返回失败
 
 @param downloadUrls 下载地址数组
 @param localFileUrl 本地储存地址数组
 @param downloadId   下载任务 id
 @param downloadName 下载任务 名称
 @param analysisURLBlock 是否成功 和 下载实例
 */
- (void)downloadWithDownloadUrls:(NSArray *)downloadUrls
                     andLocalUrl:(NSString *)localFileUrl
                      downloadId:(NSString *)downloadId
                    downloadName:(NSString *)downloadName
             andAnalysisURLBlock:(void(^)(BOOL success, id <DonwloadServiceProtocol> downloader, DownloadError *error))analysisURLBlock;

/**
 开启下载
 @param downloadModel 下载模型
 */
- (id <DonwloadServiceProtocol>)downloadWithDownloadModel:(DADownloadModel *)downloadModel;


@end
