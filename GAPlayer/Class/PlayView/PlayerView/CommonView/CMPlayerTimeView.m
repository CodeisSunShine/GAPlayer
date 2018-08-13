//
//  PlayerTimeView.m
//  AvPlayerDemo
//
//  Created by wihan on 15/10/27.
//  Copyright © 2015年 wihan. All rights reserved.
//

#import "CMPlayerTimeView.h"

@interface CMPlayerTimeView()

@property (nonatomic,strong) UILabel *timeLbl;

@property (nonatomic,strong) UIProgressView *progressView;

@end

@implementation CMPlayerTimeView

#pragma mark - life cycle

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.5];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.f;
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
    
    [self addSubview:self.progressView];
    [self addSubview:self.timeLbl];
}

- (void)setupLayout {
    
    CGRect rect = self.bounds;
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    CGSize timeLblSize = [self.timeLbl.text sizeWithFont:self.timeLbl.font];
    self.timeLbl.frame = CGRectMake((width -timeLblSize.width)/2, (height - timeLblSize.height)/2, timeLblSize.width, timeLblSize.height);
    
    CGFloat progressH = 3.f;
    CGFloat progressW = 120.f;
    CGFloat progressX = (width - progressW)/2;
    CGFloat progressY = (height - progressH - CGRectGetMaxY(self.timeLbl.frame))/2 + CGRectGetMaxY(self.timeLbl.frame);
    self.progressView.frame = CGRectMake(progressX, progressY, progressW, progressH);
}

#pragma mark – getters and setters
- (void)setTimeString:(NSString *)timeString{
    
    _timeString = [timeString copy];
    self.timeLbl.text = _timeString;
    [self setupLayout];
}

- (void)setProgressValue:(CGFloat)progressValue{
    
    _progressValue = progressValue;
    self.progressView.progress = _progressValue;
}

- (UIProgressView *)progressView {
    
    if (_progressView == nil){
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        _progressView.progressTintColor =kMyColor(255, 141, 52);
    }
    return _progressView;
}

- (UILabel *)timeLbl{

    if (!_timeLbl) {
        _timeLbl = [[UILabel alloc]initWithFrame:CGRectZero];
        _timeLbl.font = [UIFont systemFontOfSize:35];
        _timeLbl.textColor = kMyColor(255, 255, 255);
        _timeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLbl;
}
@end
