//
//  GALoadingView.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/27.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GALoadingView.h"

@interface GALoadingView ()

// 加载框
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation GALoadingView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.6;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.activity];
}

- (void)setupLayout {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.activity.frame = CGRectMake((width - 30) * 0.5, (height - 30) * 0.5, 30, 30);
}

- (void)startAnimating {
    [self setupLayout];
    [self.activity startAnimating];
    self.hidden = NO;
}

- (void)stopAnimating {
    [self.activity stopAnimating];
    self.hidden = YES;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}

@end
