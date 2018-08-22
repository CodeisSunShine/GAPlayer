//
//  GAPlayControlBar_BoomView.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/1.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASOTwoStateButton.h"

/**
 * 当前文件下载的状态
 */
typedef NS_ENUM(NSUInteger, BoomControlBarSliderType) {
    /** 开始滑动 */
    kBoomControlBarSliderTypeBeginAction = 0,
    /** 滑动中 */
    kBoomControlBarSliderTypeDidChanged,
    /** 结束滑动 */
    kBoomControlBarSliderTypeEndAction,
    /** 跳转 */
    kBoomControlBarSliderTypeJumpAction
};

/**
 * 当前文件下载的状态
 */
typedef NS_ENUM(NSUInteger, BoomControlBarType) {
    /** 播放/暂停 */
    kBoomControlBarTypePlay = 2,
    /** 快进 */
    kBoomControlBarTypeForword,
    /** 清晰度 */
    kBoomControlBarTypeClearity,
    /** 放大/缩小 */
    kBoomControlBarTypeScale,
    /** 倍速 */
    kBoomControlBarTypeSpeed,
    /** 下载 */
    kBoomControlBarTypeDownload,
    /** 章节 */
    kBoomControlBarTypeChapter,
    /** 讲义 */
    kBoomControlBarTypeNote
};

typedef void (^ControlBar_BoomClickBlock)(BoomControlBarType barType);
typedef void (^ControlBar_BoomSilderBlock)(BoomControlBarSliderType sliderType,CGFloat sliderValue);

@interface GAPlayControlBar_BoomView : UIView

/*
 播放进度slider
 */
@property (nonatomic,strong)UISlider * playProgressSliderView;

/**
 按钮回调
 */
@property (nonatomic, strong) ControlBar_BoomClickBlock clickBlock;

/**
 silder回调
 */
@property (nonatomic, strong) ControlBar_BoomSilderBlock silderBlock;

/**
 是否是横屏
 */
@property (nonatomic, assign) BOOL isFullScreen;

/**
 是否在播放
 */
@property (nonatomic, assign) BOOL isPlay;

/**
 * 速率Btn
 */
@property (nonatomic, strong) ASOTwoStateButton *speedBtn;

/**
 * 刷新 播放进度 和缓存进度 UI
 */
- (void)reloadSilder:(CGFloat)silderValue totalTime:(NSInteger)totalTime buffeValue:(CGFloat)buffeValue;

/**
 * 刷新清晰度 UI
 */
- (void)reloadClearityBtnWith:(NSString *)clearity;

/**
 * 刷新倍速 UI
 */
- (void)reloadSpeedBtnWith:(NSString *)speed;

/**
 * 刷新下载状态 UI
 */
- (void)reloadDownloadStateWith:(NSInteger)downloadState;

/**
 * 重置
 */
- (void)reset;

@end
