//
//  GAMemoryView.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/23.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAMemoryView.h"

@interface GAMemoryView ()

@property (nonatomic, strong) UILabel *memoryLabel;

@property (nonatomic, strong) UIView *memoryBackgroundView;

@property (nonatomic, strong) UIView *memoryForegroundView;

@end

@implementation GAMemoryView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setUpView];
    [self setUpLayout];
}

- (void)setUpView {
    [self addSubview:self.memoryBackgroundView];
    [self addSubview:self.memoryForegroundView];
    [self addSubview:self.memoryLabel];
}

- (void)setObject:(id)object {
    
}

- (void)setUpLayout {
    CGFloat kWidth      = ScreenWidth;
    CGFloat kHigh       = 30;
    CGFloat kDistance   = 40;

    self.memoryBackgroundView.frame = CGRectMake(0, 0, kWidth, kHigh);
//    self.memoryForegroundView.frame = CGRectMake(0, 0, kWidth * self.cacheMemoryViewModel.proportion, kHigh);
    self.memoryLabel.frame          = CGRectMake(kDistance, 0, kWidth - kDistance, kHigh);
}

- (UILabel *)memoryLabel {
    if (!_memoryLabel) {
        _memoryLabel = [[UILabel alloc] init];
    }
    return _memoryLabel;
}

- (UIView *)memoryForegroundView {
    if (!_memoryForegroundView) {
        _memoryForegroundView = [[UIView alloc] init];
        _memoryForegroundView.backgroundColor = [UIColor blueColor];
        _memoryLabel.font = [UIFont systemFontOfSize:8];
    }
    return _memoryForegroundView;
}

- (UIView *)memoryBackgroundView {
    if (!_memoryBackgroundView) {
        _memoryBackgroundView = [[UIView alloc] init];
        _memoryBackgroundView.backgroundColor = [UIColor grayColor];
    }
    return _memoryBackgroundView;
}

@end
