//
//  GAPlayerView+Background.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/27.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerView.h"
#import <Foundation/Foundation.h>

@interface GAPlayerView (Background)

/**
 注册进入后台 进入前台事件
 */
- (void)registergroundBlock:(void(^)(BOOL isBackground))groundBlock;

/**
 继续前后台监听
 */
- (void)resumegroundListen;

/**
 暂停前后台监听
 */
- (void)pausegroundListen;

@end
