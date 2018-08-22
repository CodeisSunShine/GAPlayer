//
//  PlayerProtocol.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/7/31.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAPlayerModel.h"

/**
 * 当前文件下载的状态
 */
typedef NS_ENUM(NSUInteger, PlayerState) {
    /** 未知状态 */
    kPlayerStateUnkonw = 0,
    /** 缓存中 */
    kPlayerStateCacheing,
    /** 缓存完毕 即将进入播放 */
    kPlayerStateReady,
    /** 播放中 */
    kPlayerStatePlaying,
    /** 暂停 */
    kPlayerStatePause,
    /** 播放停止 */
    kPlayerStateStop,
    /** 播放失败 */
    kPlayerStateFailure,
    /** 播放完成 */
    kPlayerStateFinish
};

@protocol PlayerCallBackDelegate <NSObject>

@optional
/**
 * 播放进度回调
 */
- (void)playbackProgressCallback:(NSTimeInterval)totalDuration
             currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
                playableDuration:(NSTimeInterval)playableDuration;

/**
 * 播放状态回调
 */
- (void)playbackStatusCallback:(PlayerState)playerState;

@end

@protocol PlayerProtocol <NSObject>

@property (nonatomic, weak) id <PlayerCallBackDelegate> callBackDelegate;

@property (nonatomic, assign) PlayerState playerState;

/**
 * 初始化播放器
 */
- (instancetype)initWith:(UIView *)playView;

/**
 * 改变播放器数据源
 */
- (void)setThePlayerDataSource:(GAPlayerModel *)playerModel;

/**
 * 播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;

/**
 * 关闭播放器
 */
- (void)stop;

/**
 * 切换倍速
 */
- (void)switchingTimesSpeed:(CGFloat)speed;

/**
 * 跳转进度
 */
- (void)playFromNowOnWithSchedule:(CGFloat)seekTime;

/**
 * 改变播放器view的frame
 */
- (void)makeProgressPlayerViewFrame:(CGRect)frame;

@end
