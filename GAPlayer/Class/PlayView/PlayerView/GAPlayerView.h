//
//  GAPlayerView.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/1.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerProtocol.h"
#import "UIView+SomehowTheScreen.h"
#import "GAPlayControlBar_BoomView.h"
#import "GAPlayControlBar_TopView.h"

/**
 * 手势类型
 */
typedef NS_ENUM(NSUInteger, GsetureType) {
    /** 初始无手势 */
    kGsetureTypeNone = 0,
    /** 左侧竖直滑动 */
    kGsetureTypeLeftVertical = 1,
    /** 右侧竖直滑动 */
    kGsetureTypeRightVertical = 2,
    /** 水平滑动 */
    kGsetureTypeHorizontal = 3,
    /** 单击 */
    kGsetureTypeSingleTap = 4,
    /** 双击 */
    kGsetureTypeDoubleTap = 5,
    /** 手势取消 */
    kGsetureTypeCancel = 6,
    /** 手势结束 */
    kGsetureTypeEnd = 7
};

/**
 * 手势类型
 */
typedef NS_ENUM(NSUInteger, PlayerViewActionType) {
    /** 返回 */
    kPVActionTypeBack = 0,
    kPVActionTypePlay,
    kPVActionTypeDownload,
    kPVActionTypeNote,
    kPVActionTypeChapter
};

typedef void(^GsetureViewGsetureBlock)(GsetureType gsetureType,CGFloat moveValue);
typedef void(^PlayerViewActionBlock)(PlayerViewActionType controlBarType,NSString *videoId);

@interface GAPlayerView : UIView

#pragma mark - 类别用到的属性 不能使用，只能使用 gsetureBlock 来判断手势

// 点击的Point
@property (nonatomic, assign) CGPoint beginPoint;
// 手势类型
@property (nonatomic, assign) GsetureType gsetureType;
// 是否需要手势
@property (nonatomic, assign) BOOL needGseture;
// 手势回调
@property (nonatomic, strong) GsetureViewGsetureBlock gsetureBlock;

#pragma mark - publick
/**
 是否全屏
 */
@property (nonatomic, assign) BOOL isFullScreen;

/**
 播放器按钮回调
 */
@property (nonatomic, strong) PlayerViewActionBlock viewActionBlock;

/**
 加载播放器需要的数据
 */
- (void)thePlayerLoadsTheData:(NSDictionary *)dataDict;

/**
 改变播放器下载状态
 */
- (void)changeThePlayerDownloadStatus:(NSString *)videoId downloadState:(NSInteger)downloadState;

@end
