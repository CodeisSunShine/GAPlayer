//
//  GACacheModel.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DADownloadCommon.h"

@interface GACacheModel : NSObject

/**
 * 视频的Id
 */
@property (nonatomic, copy) NSString *videoId;

/**
 * 下载的百分比
 */
@property (nonatomic, copy) NSString *percent;

/**
 * 本次回调写入沙盒的大小
 */
@property (nonatomic, assign) int64_t bytesWritten;

/**
 * 文件路径
 */
@property (nonatomic, copy) NSString *filePath;

/**
 * 视频名称
 */
@property (nonatomic, copy) NSString *videoName;

/**
 * 视频地址
 */
@property (nonatomic, copy) NSString *videoUrl;

/**
 * 下载状态
 */
@property (nonatomic, assign) DADownloadState downloadState;

/**
 * 数据库数据 记录GACacheModel 对应的字典数据 因数据库会频繁操作，所以记录下来防止多次转化
 */
@property (nonatomic, copy) NSDictionary *tmpDataBaseDict;

@end
