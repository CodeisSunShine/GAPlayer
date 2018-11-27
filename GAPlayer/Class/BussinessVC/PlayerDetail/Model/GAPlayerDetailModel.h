//
//  GAPlayerDetailModel.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GAPlayerDetailModel : NSObject

/**
 * 单链表 指向下一个播放model
 */
@property (nonatomic, strong) GAPlayerDetailModel *nextDetailModel;

/**
 * 视频id
 */
@property (nonatomic, copy) NSString *videoId;

/**
 * 视频名称
 */
@property (nonatomic, copy) NSString *videoName;

/**
 * 在线视频播放地址
 */
@property (nonatomic, copy) NSString *videoUrl;

/**
 * 本地视频储存地址
 */
@property (nonatomic, copy) NSString *filePath;

/**
 * 下载状态
 */
@property (nonatomic, assign) NSInteger downloadState;

/**
 * 下载百分比
 */
@property (nonatomic, assign) CGFloat percentage;

/**
 * 下载速度
 */
@property (nonatomic, copy) NSString *speed;

@property (nonatomic, assign) BOOL isActive;

@end

NS_ASSUME_NONNULL_END
