//
//  DADownloadItemModel.h
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DADownloadItemModel : NSObject

/**
 * 本地储存地址
 */
@property (nonatomic, copy) NSString *finishLocalName;

/**
 * 下载地址
 */
@property (nonatomic, copy) NSString *downloadUrl;

/**
 * resumeData的存储地址
 */
@property (nonatomic, copy) NSString *resumDataLocalName;

/**
 * 单个任务已经下载的大小
 */
@property (nonatomic, copy) NSString *totalBytesWritten;

/**
 * 单个任务总大小
 */
@property (nonatomic, copy) NSString *totalBytesExpectedToWrite;

/**
 * 是否下载完成 0 1
 */
@property (nonatomic, copy) NSString *isFinish;

@end
