//
//  GAPlayerItemModel.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 手势类型
 */
typedef NS_ENUM(NSUInteger, PlayUrlType) {
    /** 正文内容 */
    kPlayUrlTypeBody = 0,
    /** 头部广告 */
    kPlayUrlTypeBeginAd = 1,
    /** 结尾广告 */
    kPlayUrlTypeEndAd = 2
};


@interface GAPlayerItemModel : NSObject

/**
 播放id
 */
@property (nonatomic, strong) NSString *videoId;

/**
 当前播放地址
 */
@property (nonatomic, strong) NSString *currentClaritUrl;

/**
 当前播放清晰度
 */
@property (nonatomic, strong) NSString *currentClaritName;

/**
 当前播放倍速
 */
@property (nonatomic, strong) NSString *currentSpeed;

/**
 播放类型
 */
@property (nonatomic, assign) PlayUrlType playUrlType;

/**
 是否需要滑动
 */
@property (nonatomic, assign) BOOL isDrag;

/**
 是否在线
 */
@property (nonatomic, assign) BOOL isOnline;

/**
 清晰度数组
 */
@property (nonatomic, strong) NSArray *claritList;

/**
 清晰度数组
 */
@property (nonatomic, strong) NSArray *speedList;

/**
 播放视频名称
 */
@property (nonatomic, copy) NSString *hasVideoTitle;

/**
 视频总时长
 */
@property (nonatomic, assign) NSTimeInterval totalInterval;

/**
 注意：此只为 记录 切换清晰度时的播放进度
 */
@property (nonatomic, assign) NSTimeInterval currentInterval;

/**
 片头广告
 */
@property (nonatomic, strong) NSString *beginningAdUrl;

/**
 片尾广告
 */
@property (nonatomic, strong) NSString *endingAdUrl;

@end
