//
//  GAPlayControlBar_BoomView.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/1.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayControlBar_BoomView.h"
#import "GAPlayerTool.h"

@interface GAPlayControlBar_BoomView ()
/*
 底部背景
 */
@property (nonatomic,strong) UIImageView * bottomImgView;
/*
 播放按钮
 */
@property (nonatomic,strong) UIButton * playBtn;
/*
 前进按钮
 */
@property (nonatomic,strong) UIButton * forwordBtn;
/*
 播放时间Lbl
 */
@property (nonatomic,strong) UILabel * playTimeLbl;
/**
 *  cache进度的view
 */
@property (nonatomic, strong) UIProgressView *cacheProgressView;
/**
 *  清晰度按钮
 */
@property (nonatomic,strong) UIButton *clearityBtn;
/**
 放大按钮
 */
@property (nonatomic,strong) UIButton *scaleBtn;
/**
 下载按钮
 */
@property (nonatomic,strong) UIButton *downloadBtn;
/**
 章节按钮
 */
@property (nonatomic,strong) UIButton *chapterBtn;
/**
 讲义按钮
 */
@property (nonatomic,strong) UIButton *noteBtn;

@end

@implementation GAPlayControlBar_BoomView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupViews];
        //默认设置小屏播放
        self.isFullScreen = NO;
    }
    return self;
}

#pragma mark - setup
- (void)setupViews{
    [self addSubview:self.bottomImgView];
    [self addSubview:self.playBtn];
    [self addSubview:self.forwordBtn];
    [self addSubview:self.playTimeLbl];
    [self addSubview:self.cacheProgressView];
    [self addSubview:self.playProgressSliderView];
    [self addSubview:self.clearityBtn];
    [self addSubview:self.scaleBtn];
    [self addSubview:self.speedBtn];
    [self addSubview:self.chapterBtn];
    [self addSubview:self.downloadBtn];
    [self addSubview:self.noteBtn];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupFrames];
}

- (void)setupFrames {
    
    self.forwordBtn.hidden = !self.isFullScreen;
    self.clearityBtn.hidden = !self.isFullScreen;
    self.speedBtn.hidden = !self.isFullScreen;
    self.scaleBtn.hidden = self.isFullScreen;
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.bottomImgView.frame = CGRectMake(0., 0., width, height);
    CGFloat playBtnW = 46.f;
    CGFloat playBtnH = 46.f;
    CGFloat playBtnX = 0.f;
    CGFloat playBtnY = (height - playBtnH)/2;
    self.playBtn.frame = CGRectMake(playBtnX, playBtnY, playBtnW, playBtnH);
    if (self.isFullScreen) {
        
            CGFloat forwordBtnLeftMargin = 1.f;
            CGFloat forwordBtnW = 44.f;
            CGFloat forwordBtnH = 56.f;
            CGFloat forwordBtnX = CGRectGetMaxX(self.playBtn.frame) + forwordBtnLeftMargin;
            CGFloat forwordBtnY = (height - forwordBtnH)/2;

            self.forwordBtn.frame = CGRectMake(forwordBtnX, forwordBtnY, forwordBtnW, forwordBtnH);

            CGFloat timeWidth = [self getLabelWidthWith:self.playTimeLbl.text font:self.playTimeLbl.font maxWidth:80];
            CGFloat playTimeLblLeftMargin = 6.f;
            self.playTimeLbl.frame = CGRectMake(CGRectGetMaxX(self.forwordBtn.frame) + playTimeLblLeftMargin, (height - 16)/2, timeWidth, 16);

            CGFloat speedBtnRightMargin = 5.f;
            CGFloat speedBtnW = 44.f;
            CGFloat speedBtnH = 44.f;
            CGFloat speedBtnX = width - speedBtnW - speedBtnRightMargin;
            CGFloat speedBtnY = (height -speedBtnH)/2;
            self.speedBtn.frame = CGRectMake(speedBtnX, speedBtnY, speedBtnW, speedBtnH);

            CGFloat clearityLeftMargin = 5.f;
            CGFloat clearityBtnW = 44.f;
            CGFloat clearityBtnH = 44.f;
            CGFloat clearityBtnY = (height - clearityBtnH)/2;
            CGFloat clearityBtnX = CGRectGetMinX(self.speedBtn.frame) - clearityBtnW - clearityLeftMargin;
            self.clearityBtn.frame = CGRectMake(clearityBtnX, clearityBtnY, clearityBtnW, clearityBtnH);
   
//        CGFloat forwordBtnLeftMargin = 1.f;
//        CGFloat forwordBtnW = 44.f;
//        CGFloat forwordBtnH = 56.f;
//        CGFloat forwordBtnX = CGRectGetMaxX(self.playBtn.frame) + forwordBtnLeftMargin;
//        CGFloat forwordBtnY = (height - forwordBtnH)/2;
//
//        self.forwordBtn.frame = CGRectMake(forwordBtnX, forwordBtnY, forwordBtnW, forwordBtnH);
//
//        CGFloat timeWidth = [self getLabelWidthWith:self.playTimeLbl.text font:self.playTimeLbl.font maxWidth:80];
//        CGFloat playTimeLblLeftMargin = 6.f;
//        self.playTimeLbl.frame = CGRectMake(CGRectGetMaxX(self.forwordBtn.frame) + playTimeLblLeftMargin, (height - 16)/2, timeWidth, 16);
//
//        CGFloat speedBtnRightMargin = 5.f;
//        CGFloat speedBtnW = 60.f;
//        CGFloat speedBtnH = 44.f;
//        CGFloat speedBtnX = width - speedBtnW - speedBtnRightMargin;
//        CGFloat speedBtnY = (height -speedBtnH)/2;
//        self.noteBtn.frame = CGRectMake(speedBtnX, speedBtnY, speedBtnW, speedBtnH);
//
//        CGFloat clearityLeftMargin = 5.f;
//        CGFloat clearityBtnW = 60.f;
//        CGFloat clearityBtnH = 44.f;
//        CGFloat clearityBtnY = (height - clearityBtnH)/2;
//        CGFloat clearityBtnX = CGRectGetMinX(self.noteBtn.frame) - clearityBtnW - clearityLeftMargin;
//        self.chapterBtn.frame = CGRectMake(clearityBtnX, clearityBtnY, clearityBtnW, clearityBtnH);
//
//        CGFloat downloadLeftMargin = 5.f;
//        CGFloat downloadBtnW = 60.f;
//        CGFloat downloadBtnH = 44.f;
//        CGFloat downloadBtnY = (height - clearityBtnH)/2;
//        CGFloat downloadBtnX = CGRectGetMinX(self.chapterBtn.frame) - downloadBtnW - downloadLeftMargin;
//        self.downloadBtn.frame = CGRectMake(downloadBtnX, downloadBtnY, downloadBtnW, downloadBtnH);
    } else {
        CGFloat timeWidth = [self getLabelWidthWith:self.playTimeLbl.text font:self.playTimeLbl.font maxWidth:80];
        self.playTimeLbl.frame = CGRectMake(CGRectGetMaxX(self.playBtn.frame), (height - 16)/2,timeWidth, 16);
        
        CGFloat scaleBtnRightMargin = 0.f;
        CGFloat scaleBtnH = 44.f;
        CGFloat scaleBtnW = 44.f;
        CGFloat scaleBtnY = (height - scaleBtnH)/2;
        CGFloat scaleBtnX = width - scaleBtnRightMargin - scaleBtnW;
        self.scaleBtn.frame = CGRectMake(scaleBtnX, scaleBtnY, scaleBtnW, scaleBtnH);
        
    }
    CGFloat playProgressSliderViewH = 10.f;
    CGFloat margin = 5.f;
    CGFloat playProgressSliderViewX = CGRectGetMaxX(self.playTimeLbl.frame) + margin;
    CGFloat playProgressSliderViewW =0.f;
    if (self.isFullScreen) {
        playProgressSliderViewW = CGRectGetMinX(self.clearityBtn.frame) - CGRectGetMaxX(self.playTimeLbl.frame) - 5 * margin ;
    } else {
        playProgressSliderViewW =  CGRectGetMinX(self.scaleBtn.frame) - CGRectGetMaxX(self.playTimeLbl.frame) - 2 * margin ;
    }
    
    CGFloat playProgtessSliderViewY = (height - playProgressSliderViewH)/2;
    self.playProgressSliderView.frame = CGRectMake(playProgressSliderViewX, playProgtessSliderViewY, playProgressSliderViewW, playProgressSliderViewH);
    
    CGFloat cacheProgressViewH = 2.f;
    self.cacheProgressView.frame = CGRectMake(playProgressSliderViewX + 2.f, (height - cacheProgressViewH)/2, playProgressSliderViewW-1, cacheProgressViewH);
}

- (CGFloat)getLabelWidthWith:(NSString *)timeString font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    CGSize size = [timeString sizeWithFont:font];
    if (size.width > 80) {
        return size.width;
    } else {
        return 80;
    }
}

- (void)reloadSilder:(CGFloat)silderValue totalTime:(NSInteger)totalTime buffeValue:(CGFloat)buffeValue {
    if (totalTime > 0) {
        self.playProgressSliderView.value = silderValue;
        NSString * playerTextString = [NSString stringWithFormat:@"%@/%@",[GAPlayerTool convertPlayTimeToString:totalTime * silderValue],[GAPlayerTool convertPlayTimeToString:totalTime]];
        if (playerTextString && playerTextString.length > 0) {
            self.playTimeLbl.text = playerTextString;
            [self setupFrames];
        }
        if (buffeValue > 0) {
            self.cacheProgressView.progress = buffeValue;
        }
    }
}

- (void)reset {
    self.playTimeLbl.text = @"00:00/00:00";
    self.playProgressSliderView.value = 0;
    self.cacheProgressView.progress = 0;
}

- (void)reloadClearityBtnWith:(NSString *)clearity {
    [self.clearityBtn setTitle:clearity forState:UIControlStateNormal];
}

- (void)reloadSpeedBtnWith:(NSString *)speed {
    [self.speedBtn setTitle:speed forState:UIControlStateNormal];
}

- (void)reloadDownloadStateWith:(NSInteger)downloadState {
    if (downloadState == 1) {
        [self.downloadBtn setTitle:@"开始" forState:UIControlStateNormal];
    } else if (downloadState == 2) {
        [self.downloadBtn setTitle:@"进行" forState:UIControlStateNormal];
    } else if (downloadState == 3) {
        [self.downloadBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
}

- (void)boomActionClick:(UIButton *)button {
    if (self.clickBlock) {
        self.clickBlock(button.tag);
    }
}

- (void)sliderTouchCallBackWith:(BoomControlBarSliderType)sliderType sliderValue:(CGFloat)sliderValue {
    if (self.silderBlock) {
        self.silderBlock(sliderType,sliderValue);
    }
}

- (void)sliderTouchDidBeginAction:(UISlider *)slider{
    [self sliderTouchCallBackWith:kBoomControlBarSliderTypeBeginAction sliderValue:self.playProgressSliderView.value];
}

- (void)sliderTouchDidChanged:(UISlider *)slider{
    [self sliderTouchCallBackWith:kBoomControlBarSliderTypeDidChanged sliderValue:self.playProgressSliderView.value];
}

- (void)sliderTouchDidEndAction:(UISlider *)slider{
    [self sliderTouchCallBackWith:kBoomControlBarSliderTypeEndAction sliderValue:self.playProgressSliderView.value];
}

- (void)sliderJumpAction:(UITapGestureRecognizer *)ges{
    if(ges.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [ges locationInView:self.playProgressSliderView];
        [self sliderTouchCallBackWith:kBoomControlBarSliderTypeBeginAction sliderValue:self.playProgressSliderView.value];
        float width = self.playProgressSliderView.frame.size.width;
        float per = point.x/width;
        [self.playProgressSliderView setValue:per];
        [self sliderTouchCallBackWith:kBoomControlBarSliderTypeJumpAction sliderValue:self.playProgressSliderView.value];
    }
}

- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    if (_isPlay) {
        [_playBtn setImage:[UIImage imageNamed:@"player_btn_fplay_pause"]
                  forState:UIControlStateNormal];
    } else {
        [_playBtn setImage:[UIImage imageNamed:@"player_btn_fplay_play"]
                  forState:UIControlStateNormal];
    }
}

/**
 * 底部的Image
 */
- (UIImageView *)bottomImgView
{
    if (!_bottomImgView) {
        UIImage *image = [UIImage imageNamed:@"player_img_fplay_bg_down"];
        _bottomImgView = [[UIImageView alloc] initWithImage:image];
    }
    return _bottomImgView;
}

- (UIButton *)playBtn{
    
    if (_playBtn == nil){
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //普通位pause 选中为播放
        [_playBtn setImage:[UIImage imageNamed:@"player_btn_fplay_play"]
                  forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.tag = kBoomControlBarTypePlay;
    }
    return _playBtn;
}

- (UIButton *)forwordBtn{
    
    if (_forwordBtn == nil) {
        _forwordBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_forwordBtn setImage:[UIImage imageNamed:@"player_btn_fplay_next"] forState:UIControlStateNormal];
        [_forwordBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _forwordBtn.tag = kBoomControlBarTypeForword;
    }
    return _forwordBtn;
}

- (UILabel *)playTimeLbl{
    
    if (_playTimeLbl == nil) {
        _playTimeLbl = [[UILabel alloc]initWithFrame:CGRectZero];
        _playTimeLbl.font = [UIFont systemFontOfSize:12];
        _playTimeLbl.textColor = [UIColor whiteColor];
        _playTimeLbl.backgroundColor = [UIColor clearColor];
        _playTimeLbl.textAlignment = NSTextAlignmentLeft;
        _playTimeLbl.text = @"00:00/00:00";
    }
    return _playTimeLbl;
}

- (UISlider *)playProgressSliderView{
    
    if (_playProgressSliderView == nil) {
        _playProgressSliderView = [[UISlider alloc]initWithFrame:CGRectZero];
        _playProgressSliderView = [[UISlider alloc] init];
        //        _playProgressSliderView.continuous = NO;
        [_playProgressSliderView setMinimumTrackTintColor:kMyColor(255, 141, 52)];
        [_playProgressSliderView setMaximumTrackTintColor:[UIColor clearColor]];
        [_playProgressSliderView setThumbImage:[UIImage imageNamed:@"player_ion_play_position"] forState:UIControlStateNormal];
        [_playProgressSliderView addTarget:self action:@selector(sliderTouchDidBeginAction:) forControlEvents:UIControlEventTouchDown];
        [_playProgressSliderView addTarget:self action:@selector(sliderTouchDidChanged:) forControlEvents:UIControlEventValueChanged];
        [_playProgressSliderView addTarget:self action:@selector(sliderTouchDidEndAction:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderJumpAction:)];
        gr.cancelsTouchesInView = NO;
        [_playProgressSliderView addGestureRecognizer:gr];
    }
    return _playProgressSliderView;
}

- (UIProgressView *)cacheProgressView {
    if (!_cacheProgressView) {
        _cacheProgressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _cacheProgressView.layer.masksToBounds = YES;
        _cacheProgressView.layer.cornerRadius = 1.f;
        [_cacheProgressView setProgressTintColor:kMyColor(67, 67, 67)];
    }
    return _cacheProgressView;
}

- (UIButton *)clearityBtn{
    
    if (_clearityBtn == nil) {
        _clearityBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_clearityBtn setTitle:@"高清" forState:UIControlStateNormal];
        _clearityBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_clearityBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _clearityBtn.tag = kBoomControlBarTypeClearity;
    }
    return _clearityBtn;
}

- (UIButton *)scaleBtn{
    
    if (_scaleBtn == nil) {
        _scaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scaleBtn.backgroundColor = [UIColor clearColor];
        [_scaleBtn setImage:[UIImage imageNamed:@"player_btn_splay_fscreen"]
                   forState:UIControlStateNormal];
        [_scaleBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _scaleBtn.tag = kBoomControlBarTypeScale;
    }
    return _scaleBtn;
}

- (ASOTwoStateButton *)speedBtn{
    if (!_speedBtn) {
        _speedBtn = [[ASOTwoStateButton alloc] initWithFrame:CGRectZero];
        [_speedBtn setTitle:@"1.0X" forState:UIControlStateNormal];
        _speedBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_speedBtn setBackgroundImage:[UIImage imageNamed:@"vedio_action_bg.png"] forState:UIControlStateNormal];
        [_speedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_speedBtn initAnimationWithFadeEffectEnabled:YES];
        [_speedBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _speedBtn.backgroundColor = [UIColor clearColor];
        _speedBtn.tag = kBoomControlBarTypeSpeed;
    }
    return _speedBtn;
}

- (UIButton *)downloadBtn {
    if (!_downloadBtn) {
        _downloadBtn = [[UIButton alloc] init];
        [_downloadBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _downloadBtn.tag = kBoomControlBarTypeDownload;
        [_downloadBtn setTitle:@"离线" forState:UIControlStateNormal];
        [_downloadBtn setImage:[UIImage imageNamed:@"player_btn_fplay_download"] forState:UIControlStateNormal];
        [self makeProgressButtonContent:_downloadBtn];
        _downloadBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _downloadBtn;
}
- (UIButton *)chapterBtn {
    if (!_chapterBtn) {
        _chapterBtn = [[UIButton alloc] init];
        [_chapterBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _chapterBtn.tag = kBoomControlBarTypeChapter;
        [_chapterBtn setTitle:@"章节" forState:UIControlStateNormal];
        [_chapterBtn setImage:[UIImage imageNamed:@"player_btn_fplay_menu"] forState:UIControlStateNormal];
        [self makeProgressButtonContent:_chapterBtn];
        _chapterBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _chapterBtn;
}

- (UIButton *)noteBtn {
    if (!_noteBtn) {
        _noteBtn = [[UIButton alloc] init];
        [_noteBtn addTarget:self action:@selector(boomActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _noteBtn.tag = kBoomControlBarTypeNote;
        [_noteBtn setTitle:@"讲义" forState:UIControlStateNormal];
        [_noteBtn setImage:[UIImage imageNamed:@"player_btn_fplay_menu"] forState:UIControlStateNormal];
        [self makeProgressButtonContent:_noteBtn];
        _noteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _noteBtn;
}

- (void)makeProgressButtonContent:(UIButton *)button {
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.imageEdgeInsets = UIEdgeInsetsMake(5, -6, 5, 6);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
}

@end
