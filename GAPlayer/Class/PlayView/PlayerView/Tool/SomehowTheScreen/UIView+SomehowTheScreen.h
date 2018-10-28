//
//  UIView+SomehowTheScreen.h
//  SomehowTheScreen
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIView (SomehowTheScreen)

/**
 注册横竖屏的回调
 */
- (void)registerLandscapeCallBack:(void(^)(UIInterfaceOrientation deviceOrientation,UIInterfaceOrientation statusBarOrientation))directionChangeBlcok;

/**
 将屏幕转向指定方向
 */
- (void)toOrientation:(UIInterfaceOrientation)deviceOrientation;

@end
