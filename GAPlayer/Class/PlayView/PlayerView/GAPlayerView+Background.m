//
//  GAPlayerView+Background.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/27.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerView+Background.h"
#import <objc/runtime.h>

static void *DirectionGroundBlockKey = &DirectionGroundBlockKey;

@implementation GAPlayerView (Background)

#pragma mark - public
// 注册进入后台 进入前台事件
- (void)registergroundBlock:(void(^)(BOOL isBackground))groundBlock {
    @synchronized(self) {
        self.groundBlock = groundBlock;
        self.needGround = YES;
    }
    [self setupgroundNotificationCenter];
}

// 继续前后台监听
- (void)resumegroundListen {
    @synchronized(self) {
        self.needGround = YES;
    }
}

// 暂停前后台监听
- (void)pausegroundListen {
    @synchronized(self) {
        self.needGround = NO;
    }
}

#pragma mark - private
- (void)setupgroundNotificationCenter {
    dispatch_async(dispatch_get_main_queue(), ^{
        // app从后台进入前台都会调用这个方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
        // 添加检测app进入后台的观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    });
}

- (void)applicationBecomeActive {
    if (self.groundBlock) {
        self.groundBlock(NO);
    }
}

- (void)applicationEnterBackground {
    if (self.groundBlock) {
        self.groundBlock(YES);
    }
}

- (void)setGroundBlock:(PlayerViewGroundBlock)groundBlock {
    objc_setAssociatedObject(self, &DirectionGroundBlockKey, groundBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PlayerViewGroundBlock)groundBlock {
    return objc_getAssociatedObject(self, &DirectionGroundBlockKey);
}

@end
