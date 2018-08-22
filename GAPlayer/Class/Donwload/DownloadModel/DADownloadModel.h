//
//  DADownloadModel.h
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DADownloadCommon.h"

@interface DADownloadModel : NSObject

/**
* 下载的id
*/
@property (nonatomic, copy) NSString *downloadId;

/**
 * 本地存储地址
 */
@property (nonatomic, strong) NSArray *downloadItemArray;

/**
 * 本地存储根目录
 */
@property (nonatomic, copy) NSString *pathName;

/**
 * 下载名称
 */
@property (nonatomic, copy) NSString *downloadTitle;

/**
 * 下载进度
 */
@property (nonatomic, copy) NSString *progress;

/**
 * 下载状态
 */
@property (nonatomic, assign) DADownloadState downloadState;

/**
 * 本次回调写入沙盒的大小
 */
@property (nonatomic, assign) int64_t bytesWritten;

@end
