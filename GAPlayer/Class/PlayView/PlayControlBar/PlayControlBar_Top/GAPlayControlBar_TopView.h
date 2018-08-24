//
//  GAPlayControlBar_TopView.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/3.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ControlBar_TopClickBlock)(void);

@interface GAPlayControlBar_TopView : UIView

/**
 是否是横屏
 */
@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, copy) NSString *videoTitle;

@property (nonatomic, strong) ControlBar_TopClickBlock clickBlock;

- (void)smallHiden:(BOOL)hid;

@end
