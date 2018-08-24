//
//  GAPlayControlBar_TopView.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/3.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayControlBar_TopView.h"
#import "CBAutoScrollLabel.h"

@interface GAPlayControlBar_TopView ()

/**
 背景图片
 */
@property (nonatomic,strong)UIImageView * topBackImgView;
/**
 返回按钮
 */
@property (nonatomic, strong)UIButton * backBtn;
/**
 标题
 */
@property (nonatomic, strong)CBAutoScrollLabel * titleLbl;

@end

@implementation GAPlayControlBar_TopView
- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupViews];
        //默认设置小屏播放
        self.isFullScreen = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupFrames];
}

#pragma mark - setup
- (void)setupViews{
    [self addSubview:self.topBackImgView];
    [self addSubview:self.backBtn];
    [self addSubview:self.titleLbl];
}

- (void)setupFrames{
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.topBackImgView.frame = CGRectMake(0, 0, width, height + 16);
    
    CGFloat topMargin = 20.f;
    CGFloat backBtnW = 46.f;
    CGFloat backBtnH = 46.f;
    CGFloat backBtnX = 0.f;
    CGFloat backBtnY = (height - topMargin - backBtnH)/2 + topMargin;
    self.backBtn.frame = CGRectMake(backBtnX, backBtnY, backBtnW, backBtnH);
    
    CGFloat titRightDistance = 40;
    CGFloat titleW = width - CGRectGetMaxX(self.backBtn.frame) - titRightDistance;
    self.titleLbl.frame = CGRectMake(CGRectGetMaxX(self.backBtn.frame), (height - topMargin - backBtnH)/2 + topMargin, titleW, backBtnH);
}

- (void)returnBtnAction:(UIButton *)button {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)setVideoTitle:(NSString *)videoTitle {
    self.titleLbl.text = videoTitle;
}

- (void)smallHiden:(BOOL)hide {
    self.titleLbl.hidden = hide;
}

#pragma mark - setter and getter
- (UIImageView *)topBackImgView{
    
    if (!_topBackImgView) {
        _topBackImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _topBackImgView.image = [UIImage imageNamed:@"player_img_fplay_bg_up"];
    }
    return _topBackImgView;
}

- (UIButton *)backBtn {
    
    if (_backBtn == nil) {
        _backBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_backBtn setImage:[UIImage imageNamed:@"player_btn_fplaynav_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(returnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (CBAutoScrollLabel *)titleLbl{
    
    if (_titleLbl == nil) {
        _titleLbl = [[CBAutoScrollLabel alloc] initWithFrame:CGRectZero];
        _titleLbl.backgroundColor = [UIColor clearColor];
        _titleLbl.textColor = [UIColor whiteColor];
        _titleLbl.textAlignment = NSTextAlignmentLeft;
        _titleLbl.font = [UIFont systemFontOfSize:16.0f];
        _titleLbl.labelSpacing = 30;//文字结束和从新开始的间隔
        _titleLbl.pauseInterval = 1.7;//循环间隔
        _titleLbl.scrollSpeed = 30;//滚动速度
        _titleLbl.fadeLength = 1.f;//两边渐变的宽度
        _titleLbl.scrollDirection = CBAutoScrollDirectionLeft;//滚动方向
        [_titleLbl observeApplicationNotifications];//设置监听
    }
    return _titleLbl;
}

@end
