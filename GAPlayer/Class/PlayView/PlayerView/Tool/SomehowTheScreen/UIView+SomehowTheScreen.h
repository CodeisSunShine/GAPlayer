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

- (void)registerLandscapeCallBack:(void(^)(UIInterfaceOrientation deviceOrientation,UIInterfaceOrientation statusBarOrientation))directionChangeBlcok;

- (void)toOrientation:(UIInterfaceOrientation)deviceOrientation;

@end
