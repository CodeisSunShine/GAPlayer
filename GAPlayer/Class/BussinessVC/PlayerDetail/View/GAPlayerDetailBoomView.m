//
//  GAPlayerDetailBoomView.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/30.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerDetailBoomView.h"

@interface GAPlayerDetailBoomView ()

@property (nonatomic, strong) UILabel *finishLabel;

@property (nonatomic, strong) UILabel *unFinishLabel;

@end

@implementation GAPlayerDetailBoomView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
        [self setupLayouts];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.finishLabel];
    [self addSubview:self.unFinishLabel];
}

- (void)setupLayouts {
    self.finishLabel.frame = CGRectMake(0, 0, ScreenWidth * 0.5, 44);
    self.unFinishLabel.frame = CGRectMake(CGRectGetMaxX(self.finishLabel.frame) + 1, 0, ScreenWidth * 0.5 - 1, 44);
}

- (void)setFinishCount:(NSInteger)finishCount {
    _finishCount = finishCount;
    self.finishLabel.text = [NSString stringWithFormat:@"已完成:%ld",finishCount];
}

- (void)setUnFinishCount:(NSInteger)unFinishCount {
    _unFinishCount = unFinishCount;
    self.unFinishLabel.text = [NSString stringWithFormat:@"未完成:%ld",unFinishCount];
}

- (UILabel *)finishLabel {
    if (!_finishLabel) {
        _finishLabel = [[UILabel alloc] init];
        _finishLabel.textColor = kMyColor(253, 141, 63);
        _finishLabel.font = [UIFont systemFontOfSize:15];
        _finishLabel.textAlignment = 1;
    }
    return _finishLabel;
}

- (UILabel *)unFinishLabel {
    if (!_unFinishLabel) {
        _unFinishLabel = [[UILabel alloc] init];
        _unFinishLabel.textColor = kMyColor(253, 141, 63);
        _unFinishLabel.font = [UIFont systemFontOfSize:15];
        _unFinishLabel.textAlignment = 1;
    }
    return _unFinishLabel;
}

@end
