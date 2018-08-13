//
//  GAPlayerViewModel.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAPlayerItemModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GAPlayerModel.h"

@interface GAPlayerViewModel : NSObject

@property (nonatomic, strong) GAPlayerItemModel *curItemModel;

/**
 解析外界数据
 */
- (void)thePlayerParsesTheData:(NSDictionary *)dataDict successBlock:(void(^)(BOOL success,id object))successBlock;

/**
 根据 playerItemModel 获得播放model
 */
- (GAPlayerModel *)makeProgressPlayerModelWith:(GAPlayerItemModel *)playerItemModel;

/**
 组织 playerItemModel 中倍速的数据
 */
- (void)makeProgressSpeedList:(GAPlayerItemModel *)playerItemModel;

/**
 处理亮度改变的数据
 */
- (CGFloat)makeProgressGestureBrightnessChange:(CGFloat)moveValue;

/**
 处理音量改变的数据
 */
- (CGFloat)makeProgressGestureVolumeChange:(CGFloat)moveValue;

/**
 处理进度改变的数据
 */
- (CGFloat)makeProgressGestureProgressChange:(CGFloat)moveValue
                                currentWidth:(CGFloat)currentWidth
                                currentValue:(CGFloat)currentValue;

/**
 处理当前播放地址
 */
- (NSString *)makeProgressCurrentPlayerUrl:(GAPlayerItemModel *)playerItemModel;

/**
 判断是否有视频需要继续播放
 */
- (BOOL)judgeVideoNeedContinueToPlayed:(GAPlayerItemModel *)playerItemModel;

/**
 处理广告倒计时
 */
- (NSString *)processAdCountdown:(NSTimeInterval)totalDuration currentPlaybackTime:(NSTimeInterval)currentPlaybackTime ;

@end
