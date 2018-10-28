//
//  GAPlayerView+GestureAction.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/6.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerView.h"

@interface GAPlayerView (GestureAction)

/**
 注册手势
 */
- (void)registerForGestureEvents:(void(^)(GsetureType gsetureType,CGFloat moveValue))gsetureBlock;

/**
 开启/恢复 手势
 */
- (void)startForGestureEvents;

/**
 取消手势
 */
- (void)cancelForGestureEvents;

@end
