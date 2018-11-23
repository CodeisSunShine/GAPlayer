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
    /** 选中 */
    kPDActionTypeSelect = 0,
    /** 播放 */
    kPDActionTypePlay,
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
- (void)changLectureWith:(GAPlayerDetailModel *)videoModel;

@end

NS_ASSUME_NONNULL_END
