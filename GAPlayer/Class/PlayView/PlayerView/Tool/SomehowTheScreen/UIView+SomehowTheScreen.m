//
//  UIView+SomehowTheScreen.m
//  SomehowTheScreen
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "UIView+SomehowTheScreen.h"
#import <objc/runtime.h>

static void *DirectionChangeBlockKey = &DirectionChangeBlockKey;
static void *SomehowTheScreenSuperView = &SomehowTheScreenSuperView;

typedef void(^DirectionChangeBlock)(UIInterfaceOrientation deviceOrientation,UIInterfaceOrientation statusBarOrientation);

@interface UIView ()

@property (nonatomic, strong) UIView *superViews;

@property (nonatomic, strong) DirectionChangeBlock directionChangeBlcok;

@end

@implementation UIView (SomehowTheScreen)

- (void)registerLandscapeCallBack:(void(^)(UIInterfaceOrientation deviceOrientation,UIInterfaceOrientation statusBarOrientation))directionChangeBlcok {
    self.directionChangeBlcok = directionChangeBlcok;
    self.superViews = self.superview;
    [self setupNotification];
}

- (void)setupNotification {
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeProgressOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)makeProgressOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation deviceOrientation = (UIInterfaceOrientation)orientation;
    [self toOrientation:deviceOrientation];
}

- (void)toOrientation:(UIInterfaceOrientation)deviceOrientation {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (deviceOrientation == statusBarOrientation || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown || deviceOrientation == UIInterfaceOrientationUnknown || deviceOrientation >= 5) {
        return;
    }
    if (deviceOrientation == UIInterfaceOrientationPortrait) {
        [self.superViews addSubview:self];
    } else {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:deviceOrientation animated:NO];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.transform = CGAffineTransformIdentity;
        weakSelf.transform = [weakSelf getCurrentDeviceOrientation];
        if (weakSelf.directionChangeBlcok) {
            weakSelf.directionChangeBlcok(deviceOrientation,statusBarOrientation);
        }
    }];
}

//获取当前的旋转状态
- (CGAffineTransform)getCurrentDeviceOrientation{
    //状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //根据要进行旋转的方向来计算旋转的角度
    if (orientation ==UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation ==UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation ==UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

- (void)setSuperViews:(UIView *)superViews {
    objc_setAssociatedObject(self, &SomehowTheScreenSuperView, superViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)superViews {
    return objc_getAssociatedObject(self, &SomehowTheScreenSuperView);
    
}

- (void)setDirectionChangeBlcok:(DirectionChangeBlock)directionChangeBlcok {
    objc_setAssociatedObject(self, &DirectionChangeBlockKey, directionChangeBlcok, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DirectionChangeBlock)directionChangeBlcok {
    return objc_getAssociatedObject(self, &DirectionChangeBlockKey);
}

@end
