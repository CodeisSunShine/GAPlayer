//
//  GAPlayerDetailTableView.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * TableView的控件选中类型
 */
typedef NS_ENUM(NSUInteger, PlayerDetailActionType) {
    /** 切换播放状态 */
    kPDActionTypeChangeState = 0,
    /** 切换播放源 */
    kPDActionTypeChangeSource,
    /** 下载 */
    kPDActionTypeDonwload
};

@class GAPlayerDetailModel;

typedef void(^PlayerDetailTableViewActionBlock)(GAPlayerDetailModel *detailModel, PlayerDetailActionType actionType);

@interface GAPlayerDetailTableView : UIView

@property (nonatomic, copy) PlayerDetailTableViewActionBlock actionBlock;

- (void)setObject:(id)object;

/**
 * 切换视频 将UI进行处理
 */
- (void)changLectureWith:(GAPlayerDetailModel *)detailModel isPlay:(BOOL)isPlay;

@end

NS_ASSUME_NONNULL_END
