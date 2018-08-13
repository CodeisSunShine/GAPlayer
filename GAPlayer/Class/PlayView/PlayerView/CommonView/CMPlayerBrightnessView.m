//
//  PlayerBrightnessView.m
//  AvPlayerDemo
//
//  Created by wihan on 15/11/5.
//  Copyright © 2015年 wihan. All rights reserved.
//

#import "CMPlayerBrightnessView.h"

@implementation CMPlayerBrightnessView

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.6];
        self.layer.cornerRadius = 4.f;
        self.layer.masksToBounds = YES;
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupLayout];
}

#pragma mark – private methods
#pragma mark – private 初始化
- (void)setupViews {
    [self addSubview:self.brightnessView];
    [self addSubview:self.brightnessProgress];
}

- (void)setupLayout {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat brightViewH = 50.f;
    CGFloat brightViewW = 50.f;
    self.brightnessView.frame = CGRectMake((width - brightViewW)/2, (height - brightViewH)/2, brightViewW, brightViewH);
    CGFloat progressH = 3.f;
    CGFloat progressW = 120.f;
    CGFloat progressX = (width - progressW)/2;
    CGFloat progressY = (height - CGRectGetMaxY(self.brightnessView.frame) - progressH)/2 + CGRectGetMaxY(self.brightnessView.frame);
    self.brightnessProgress.frame = CGRectMake(progressX, progressY, progressW, progressH);
}

- (void)setProgress:(float)progress {
    [[UIScreen mainScreen] setBrightness:progress];
    self.brightnessProgress.progress = progress;
    NSLog(@"brightness = %f",[UIScreen mainScreen].brightness);
}

#pragma mark – getters and setters
- (UIImageView *)brightnessView {
    if (_brightnessView == nil){
        _brightnessView = [[UIImageView alloc] init];
        _brightnessView.image = [UIImage imageNamed:@"player_ico_play_brightness"];
    }
    return _brightnessView;
}

- (UIProgressView *)brightnessProgress {
    
    if (_brightnessProgress == nil){
        _brightnessProgress = [[UIProgressView alloc] init];
        _brightnessProgress.trackTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        _brightnessProgress.progressTintColor =kMyColor(255, 141, 52);
        _brightnessProgress.progress = [UIScreen mainScreen].brightness;
    }
    return _brightnessProgress;
}
@end
