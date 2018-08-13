//
//  PlayerBrightnessView.h
//  AvPlayerDemo
//
//  Created by wihan on 15/11/5.
//  Copyright © 2015年 wihan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPlayerBrightnessView : UIView

@property (nonatomic, strong)UIImageView *brightnessView;
@property (nonatomic, strong)UIProgressView *brightnessProgress;

/**
 * 设置调节亮度
 */
@property (nonatomic, assign) float progress;

@end
