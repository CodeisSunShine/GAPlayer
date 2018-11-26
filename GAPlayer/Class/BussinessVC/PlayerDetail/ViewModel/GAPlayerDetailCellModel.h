//
//  GAPlayerDetailCellModel.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GAPlayerDetailCellModel,GAPlayerDetailModel;

typedef void(^LectureCellVModelPlayImageBlock)(void);
typedef void(^LectureCellVModelDownloadStateBlock)(void);
typedef void(^LectureCellVModelDownloadProgressBlock)(void);
typedef void(^LectureCellVModelDownloadSpeedBlock)(void);

typedef void(^PlayerDetailCellDownloadOpertionBlock)(GAPlayerDetailCellModel *cellModel);
typedef void(^PlayerDetailCellPlayOpertionBlock)(GAPlayerDetailCellModel *cellModel);

@interface GAPlayerDetailCellModel : NSObject

@property (nonatomic, strong) GAPlayerDetailModel *detailModel;

/**
 * 下载状态颜色
 */
@property (nonatomic, copy) UIColor *stateColor;

/**
 * 下载状态名字
 */
@property (nonatomic, copy) NSString *stateName;

/**
 * 下载图片名字
 */
@property (nonatomic, copy) NSString *downloadImageNmae;

/**
 * 课程名字
 */
@property (nonatomic, copy) NSString *courseNmae;

/**
 * 下载进度
 */
@property (nonatomic, copy) NSString *percentStr;

/**
 * 播放图片名字
 */
@property (nonatomic, copy) NSString *playImageName;

/**
 * 下载进度是否被隐藏
 */
@property (nonatomic, assign) BOOL progressHide;

/**
 * 是否被选中
 */
@property (nonatomic, assign) BOOL isCurrentSelect;

@property (nonatomic, assign) CGRect courseLabelF;
@property (nonatomic, assign) CGRect studyTimeLabelF;
@property (nonatomic, assign) CGRect speedLabelF;
@property (nonatomic, assign) CGRect stateLabelF;
@property (nonatomic, assign) CGRect stateButtonF;
@property (nonatomic, assign) CGRect downloadStateViewF;
@property (nonatomic, assign) CGRect playButtonF;
@property (nonatomic, assign) CGRect progressViewF;
@property (nonatomic, assign) CGRect lineF;

@property (nonatomic, assign) CGFloat cellHigh;

@property (nonatomic, assign) DADownloadState downloadState;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *speed;

@property (nonatomic, strong) LectureCellVModelPlayImageBlock playImageBlcok;
@property (nonatomic, strong) LectureCellVModelDownloadStateBlock downloadStateBlock;
@property (nonatomic, strong) LectureCellVModelDownloadProgressBlock downloadProgressBlock;
@property (nonatomic, strong) LectureCellVModelDownloadSpeedBlock downloadSpeedBlock;


@property (nonatomic, copy) PlayerDetailCellDownloadOpertionBlock downloadOptionBlock;
@property (nonatomic, copy) PlayerDetailCellPlayOpertionBlock playOpertionBlock;

- (void)setObject:(id)object;

@end

NS_ASSUME_NONNULL_END
