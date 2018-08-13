//
//  GAPlayerView.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/1.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerView.h"
#import "GAPlayerModel.h"
#import "GAIJKPlayer.h"
#import "GAAVPlayer.h"
#import "GAPlayerSelectView.h"
#import "GAPlayerViewModel.h"
#import "GAPlayerView+GestureAction.h"
#import "CMPlayerBrightnessView.h"
#import "CMPlayerTimeView.h"
#import "GAPlayerTool.h"

#define FastForwardTime 15

@interface GAPlayerView () <PlayerCallBackDelegate>
// 播放器
@property (nonatomic, strong) id <PlayerProtocol> player;
// 播放器视图
@property (nonatomic, strong) UIView *playerView;
// 顶部栏
@property (nonatomic, strong) GAPlayControlBar_TopView *topView;
// 底部栏
@property (nonatomic, strong) GAPlayControlBar_BoomView *boomView;
// 工具栏是否隐藏
@property (nonatomic, assign) BOOL controlBarHidden;
// 亮度视图
@property (nonatomic, strong) CMPlayerBrightnessView *brightnessView;
// 时间进度视图
@property (nonatomic, strong) CMPlayerTimeView *timeView;
// 是否正在播放
@property (nonatomic, assign) BOOL isPlay;
// 是否正在拖拽
@property (nonatomic, assign) BOOL isDraging;
// 是否水平拖拽手势
@property (nonatomic, assign) BOOL isGestureDraging;
// 选择视图
@property (nonatomic, strong) GAPlayerSelectView *selectView;
// 数据控制
@property (nonatomic, strong) GAPlayerViewModel *viewModel;
// 更改清晰度时记录的播放进度
@property (nonatomic, assign) CGFloat beforeChangeLocation;
// 加载框
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
// 广告提示
@property (nonatomic, strong) UIButton *adAlertView;

@property (nonatomic, assign) CGFloat realWidth;
@property (nonatomic, assign) CGFloat realHigh;

@end

@implementation GAPlayerView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
        self.beforeChangeLocation = 0;
        self.controlBarHidden = YES;
        [self registerForGestureEvent];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.playerView];
    [self addSubview:self.topView];
    [self addSubview:self.boomView];
    [self addSubview:self.selectView];
    [self.playerView addSubview:self.adAlertView];
    [self.playerView addSubview:self.loadingView];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupLayout];
    [self setupBrightnessLayout];
}

- (void)setupLayout {
    CGFloat width = self.realWidth;
    CGFloat high = self.realHigh;
    
    self.playerView.frame = CGRectMake(0, 0, width, high);
    self.selectView.frame = CGRectMake(0, 0, width, high);
    self.topView.frame = CGRectMake(0, 0, width, 44);
    self.boomView.isFullScreen = self.isFullScreen;
    self.boomView.frame = CGRectMake(0, high - 44, width, 44);
    self.loadingView.frame = CGRectMake((width - 30) * 0.5, (high - 30) * 0.5, 30, 30);
    self.adAlertView.frame = CGRectMake(width - 80 - 30, 20, 80, 25);
    [self.player makeProgressPlayerViewFrame:CGRectMake(0, 0, width, high)];
}

#pragma mark - public
- (void)thePlayerLoadsTheData:(NSDictionary *)dataDict {
    __weak typeof(self)weakSelf = self;
    [self.loadingView startAnimating];
    [self.viewModel thePlayerParsesTheData:dataDict successBlock:^(BOOL success, id object) {
        if (success) {
            weakSelf.viewModel.curItemModel = object;
            [weakSelf initializingPlayer];
            [weakSelf.boomView reloadClearityBtnWith:weakSelf.viewModel.curItemModel.currentClaritName];
            [weakSelf.boomView reloadSpeedBtnWith:weakSelf.viewModel.curItemModel.currentSpeed];
            [weakSelf.loadingView stopAnimating];
            [weakSelf makeProgressViewWith:weakSelf.viewModel.curItemModel.playUrlType];
            if (weakSelf.viewModel.curItemModel.playUrlType != kPlayUrlTypeBody) {
                [weakSelf playButtonAction];
            }
        } else {
            [weakSelf.loadingView startAnimating];
            NSLog(@"数据解析失败");
        }
    }];
}

// 改变播放器下载状态
- (void)changeThePlayerDownloadStatus:(NSString *)videoId downloadState:(NSInteger)downloadState {
//    if ([self.viewModel.curItemModel.videoId isEqualToString:videoId]) {
//
//    }
    [self.boomView reloadDownloadStateWith:downloadState];
}

#pragma mark - private
// 展示选择视图
- (void)showSelectViewWith:(NSArray *)selectData selectName:(NSString *)selectName{
    self.selectView.hidden = NO;
    [self.selectView setObject:selectData];
    [self.selectView outsideOption:selectName];
}

// 改变播放器清晰度
- (void)changeThePlayerClearity:(GAPlayerSelectVIewModel *)selectModel {
    self.beforeChangeLocation = self.viewModel.curItemModel.currentInterval;
    self.isDraging = YES;
    self.viewModel.curItemModel.currentClaritName = selectModel.selectName;
    self.viewModel.curItemModel.currentClaritUrl = selectModel.selectValue;
    [self.boomView reloadClearityBtnWith:selectModel.selectName];
    [self changeThePlayerPlaybackAddress];
    self.isDraging = NO;
}

// 改变播放器倍速
- (void)changeThePlayerSpeed:(GAPlayerSelectVIewModel *)selectModel {
    self.viewModel.curItemModel.currentSpeed = selectModel.selectName;
    [self.boomView reloadSpeedBtnWith:selectModel.selectName];
    [self.player switchingTimesSpeed:[selectModel.selectValue floatValue]];
}

// 根据播放的性质 处理播放器视图
- (void)makeProgressViewWith:(PlayUrlType)playUrlType {
    self.topView.hidden = playUrlType != kPlayUrlTypeBody;
    self.boomView.hidden = playUrlType != kPlayUrlTypeBody;
    if (playUrlType == kPlayUrlTypeBody) {
        [self startForGestureEvents];
    } else {
        [self cancelForGestureEvents];
    }
}

#pragma mark - GestureEvent
// 手势相关视图的 setup
- (void)setupBrightnessView {
    [self.playerView addSubview:self.brightnessView];
    [self.playerView addSubview:self.timeView];
}

- (void)setupBrightnessLayout {
    CGFloat width = self.realWidth;
    CGFloat height = self.realHigh;
    CGFloat playerTimeViewW = 150;
    CGFloat playerTimeViewH = 110;
    
    self.timeView.frame = CGRectMake((width - playerTimeViewW)/2, (height - playerTimeViewH)/2, playerTimeViewW, playerTimeViewH);
    CGFloat playerBrightnessViewW = 150;
    CGFloat playerBrightnessViewH = 110;
    self.brightnessView.frame = CGRectMake((width - playerBrightnessViewW)/2, (height - playerBrightnessViewH)/2, playerBrightnessViewW, playerBrightnessViewH);
}

// 注册手势
- (void)registerForGestureEvent {
    [self setupBrightnessView];
    [self setupBrightnessLayout];
    __weak typeof(self)weakSelf = self;
    [self registerForGestureEvents:^(GsetureType gsetureType,CGFloat moveValue) {
        if (gsetureType == kGsetureTypeLeftVertical) {
            [weakSelf brightnessGestureChange:moveValue];
        } else if (gsetureType == kGsetureTypeRightVertical) {
            [weakSelf volumeGestureChange:moveValue];
        } else if (gsetureType == kGsetureTypeHorizontal) {
            [weakSelf progressGestureChange:moveValue];
        } else if (gsetureType == kGsetureTypeSingleTap) {
            [weakSelf whetherToHideControlbar:weakSelf.controlBarHidden];
        } else if (gsetureType == kGsetureTypeDoubleTap) {
            [weakSelf playButtonAction];
        } else if (gsetureType == kGsetureTypeCancel || gsetureType == kGsetureTypeEnd) {
            if (weakSelf.isGestureDraging) {
                [weakSelf playerJumpsToTheSpecifiedTimePercentage:weakSelf.boomView.playProgressSliderView.value];
            }
            [weakSelf hideGestureView];
        }
    }];
}

// 亮度发生改变
- (void)brightnessGestureChange:(CGFloat)moveValue {
    CGFloat currentBright = [self.viewModel makeProgressGestureBrightnessChange:moveValue];
    self.brightnessView.hidden = NO;
    [self.playerView bringSubviewToFront:self.brightnessView];
    self.brightnessView.progress = currentBright;
}

// 音量发生改变
- (void)volumeGestureChange:(CGFloat)moveValue {
    CGFloat currentVolume = [self.viewModel makeProgressGestureVolumeChange:moveValue];
    [MPMusicPlayerController applicationMusicPlayer].volume = currentVolume;
}

// 进度发生改变
- (void)progressGestureChange:(CGFloat)moveValue {
    self.isGestureDraging = YES;
    self.timeView.hidden = NO;
    [self.playerView bringSubviewToFront:self.timeView];
    CGFloat currentValue = [self.viewModel makeProgressGestureProgressChange:moveValue currentWidth:self.realWidth currentValue:self.boomView.playProgressSliderView.value];
    self.timeView.progressValue = currentValue;
    self.timeView.timeString = [NSString stringWithFormat:@"%@/%@",[GAPlayerTool convertPlayTimeToString:self.viewModel.curItemModel.totalInterval * currentValue],[GAPlayerTool convertPlayTimeToString:self.viewModel.curItemModel.totalInterval]];
    [self.boomView reloadSilder:currentValue totalTime:self.viewModel.curItemModel.totalInterval buffeValue:-1];
}

- (void)whetherToHideControlbar:(BOOL)isHide {
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        if (isHide) {
            weakSelf.topView.transform = CGAffineTransformMakeTranslation(0, -50);
            weakSelf.boomView.transform = CGAffineTransformMakeTranslation(0, 50);
            weakSelf.topView.alpha = 0;
            weakSelf.boomView.alpha = 0;
        } else {
            weakSelf.topView.transform = CGAffineTransformIdentity;
            weakSelf.boomView.transform = CGAffineTransformIdentity;
            weakSelf.topView.alpha = 1;
            weakSelf.boomView.alpha = 1;
        }
    }];
    self.controlBarHidden = !isHide;
}

- (void)hideGestureView {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.brightnessView.hidden = YES;
        weakSelf.timeView.hidden = YES;
        weakSelf.isGestureDraging = NO;
    });
}

#pragma mark - viewAction
- (void)setupTopViewAction {
    __weak typeof(self)weakSelf = self;
    self.topView.clickBlock = ^{
        if (weakSelf.isFullScreen) {
            [weakSelf scaleButtonAction];
        } else {
            
        }
    };
}

- (void)setupBoomViewAction {
    __weak typeof(self)weakSelf = self;
    self.boomView.clickBlock = ^(BoomControlBarType barType) {
        if (barType == kBoomControlBarTypePlay) {
            [weakSelf playButtonAction];
            if (weakSelf.viewActionBlock) {
                weakSelf.viewActionBlock(barType, weakSelf.viewModel.curItemModel.videoId);
            }
        } else if (barType == kBoomControlBarTypeForword) {
            [weakSelf playerJumpsToTheSpecifiedTimeLocation:self.viewModel.curItemModel.currentInterval + FastForwardTime];
        } else if (barType == kBoomControlBarTypeClearity) {
            [weakSelf showSelectViewWith:weakSelf.viewModel.curItemModel.claritList selectName:weakSelf.viewModel.curItemModel.currentClaritName];
        } else if (barType == kBoomControlBarTypeScale) {
            [weakSelf scaleButtonAction];
        } else if (barType == kBoomControlBarTypeSpeed) {
            [weakSelf.viewModel makeProgressSpeedList:weakSelf.viewModel.curItemModel];
            [weakSelf showSelectViewWith:weakSelf.viewModel.curItemModel.speedList selectName:weakSelf.viewModel.curItemModel.currentSpeed];
        } else if (barType == kBoomControlBarTypeDownload || barType == kBoomControlBarTypeNote || barType == kBoomControlBarTypeChapter) {
            if (weakSelf.viewActionBlock) {
                weakSelf.viewActionBlock(barType, weakSelf.viewModel.curItemModel.videoId);
            }
        }
    };
    self.boomView.silderBlock = ^(BoomControlBarSliderType sliderType, CGFloat sliderValue) {
        if (sliderType == kBoomControlBarSliderTypeBeginAction) {
            weakSelf.isDraging = YES;
        } else if (sliderType == kBoomControlBarSliderTypeDidChanged) {
            [weakSelf.boomView reloadSilder:weakSelf.boomView.playProgressSliderView.value totalTime:weakSelf.viewModel.curItemModel.totalInterval buffeValue:-1];
        } else if (sliderType == kBoomControlBarSliderTypeEndAction) {
            weakSelf.isDraging = NO;
            [weakSelf playerJumpsToTheSpecifiedTimePercentage:sliderValue];
        } else if (sliderType == kBoomControlBarSliderTypeJumpAction) {
            weakSelf.isDraging = NO;
            [weakSelf playerJumpsToTheSpecifiedTimePercentage:sliderValue];
        }
    };
}

// 继续播放播放/暂停
- (void)playButtonAction {
    if (self.isPlay) {
        [self.player pause];
    } else {
        [self.player play];
        [self.loadingView startAnimating];
    }
    self.isPlay = !self.isPlay;
}

// 放大/缩小
- (void)scaleButtonAction {
    if (self.isFullScreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    } else {
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

// 播放器跳转到指定时间 value为百分比
- (void)playerJumpsToTheSpecifiedTimePercentage:(CGFloat)percentage {
    [self playerJumpsToTheSpecifiedTimeLocation:percentage * self.viewModel.curItemModel.totalInterval];
}

// 播放器跳转到指定时间 value为时长
- (void)playerJumpsToTheSpecifiedTimeLocation:(CGFloat)location {
    [self.player playFromNowOnWithSchedule:location];
}

#pragma mark - 播放器
// 初始化播放器
- (void)initializingPlayer{
    if (self.player) {
        [self.player stop];
    }
    self.topView.videoTitle = self.viewModel.curItemModel.hasVideoTitle;
    
    self.player = [[GAIJKPlayer alloc] initWith:self.playerView];
//    self.player = [[GAAVPlayer alloc] initWith:self.playerView];
    [self forPlayerTheAssignment];
    self.player.callBackDelegate = self;
    [self.player makeProgressPlayerViewFrame:CGRectMake(0, 0, self.realWidth, self.realHigh)];
    
    [self.playerView bringSubviewToFront:self.loadingView];
    [self.playerView bringSubviewToFront:self.adAlertView];
}

// 改变播放器播放地址
- (void)changeThePlayerPlaybackAddress {
//    [self makeProgressViewWith:self.viewModel.curItemModel.playUrlType];
//    [self initializingPlayer];
//    [self.player play];
    [self forPlayerTheAssignment];
    [self makeProgressViewWith:self.viewModel.curItemModel.playUrlType];
    [self.player play];
}

- (void)forPlayerTheAssignment {
    GAPlayerModel *playerModel = [self.viewModel makeProgressPlayerModelWith:self.viewModel.curItemModel];
    [self.player setThePlayerDataSource:playerModel];
}

#pragma mark - PlayerCallBackDelegate
// 播放进度回调
- (void)playbackProgressCallback:(NSTimeInterval)totalDuration
             currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
                playableDuration:(NSTimeInterval)playableDuration {
    if (self.viewModel.curItemModel.playUrlType == kPlayUrlTypeBeginAd) {
        NSString *countdown = [self.viewModel processAdCountdown:totalDuration currentPlaybackTime:currentPlaybackTime];
        [self.adAlertView setTitle:countdown forState:UIControlStateNormal];
    }
    if (totalDuration > 0 && !self.isDraging && !self.isGestureDraging) {
        self.viewModel.curItemModel.currentInterval = currentPlaybackTime;
        self.viewModel.curItemModel.totalInterval = totalDuration;
        [self.boomView reloadSilder:currentPlaybackTime/totalDuration totalTime:totalDuration buffeValue:playableDuration / totalDuration];
    }
}

// 播放状态回调
- (void)playbackStatusCallback:(PlayerState)playerState {
    [self.loadingView stopAnimating];
    if (playerState == kPlayerStateReady) {
        if (self.beforeChangeLocation && self.beforeChangeLocation > 0) {
            [self playerJumpsToTheSpecifiedTimeLocation:self.beforeChangeLocation];
            self.beforeChangeLocation = 0;
        }
    } else if (playerState == kPlayerStateCacheing) {
        [self.loadingView startAnimating];
        NSLog(@"currentThread%@",[NSThread currentThread]);
    } else if (playerState == kPlayerStateFinish) {
        [self singleVideoIsDone];
    }
}

- (void)singleVideoIsDone {
    if ([self.viewModel judgeVideoNeedContinueToPlayed:self.viewModel.curItemModel]) {
        [self changeThePlayerPlaybackAddress];
    }
}

- (void)adAlertClick {
    self.adAlertView.hidden = YES;
    [self singleVideoIsDone];
}

#pragma mark - set get

- (void)setIsPlay:(BOOL)isPlay {
    _isPlay = isPlay;
    self.boomView.isPlay = isPlay;
}

- (GAPlayControlBar_TopView *)topView {
    if (!_topView) {
        _topView = [[GAPlayControlBar_TopView alloc] init];
        [self setupTopViewAction];
    }
    return _topView;
}

- (GAPlayControlBar_BoomView *)boomView {
    if (!_boomView) {
        _boomView = [[GAPlayControlBar_BoomView alloc] init];
        [self setupBoomViewAction];
    }
    return _boomView;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] init];
        _playerView.backgroundColor = [UIColor blackColor];
    }
    return _playerView;
}

- (GAPlayerSelectView *)selectView {
    if (!_selectView) {
        _selectView = [[GAPlayerSelectView alloc] init];
        __weak typeof(self)weakSelf = self;
        _selectView.selectViewBlock = ^(GAPlayerSelectVIewModel *selectModel) {
            if ([selectModel.selectType isEqualToString:@"1"]) {
                [weakSelf changeThePlayerClearity:selectModel];
            } else {
                [weakSelf changeThePlayerSpeed:selectModel];
            }
        };
        _selectView.hidden = YES;
    }
    return _selectView;
}

- (GAPlayerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GAPlayerViewModel alloc] init];
    }
    return _viewModel;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _loadingView;
}

- (CGFloat)realHigh {
    if (self.isFullScreen) {
        return self.frame.size.width;
    } else {
        return self.frame.size.height;
    }
}

- (CGFloat)realWidth {
    if (self.isFullScreen) {
        return self.frame.size.height;
    } else {
        return self.frame.size.width;
    }
}

- (CMPlayerBrightnessView *)brightnessView {
    if (!_brightnessView) {
        _brightnessView = [[CMPlayerBrightnessView alloc] init];
        _brightnessView.hidden = YES;
    }
    return _brightnessView;
}

- (CMPlayerTimeView *)timeView {
    if (!_timeView) {
        _timeView = [[CMPlayerTimeView alloc] init];
        _timeView.hidden = YES;
    }
    return _timeView;
}

- (UIButton *)adAlertView {
    if (!_adAlertView) {
        _adAlertView = [[UIButton alloc] init];
        [_adAlertView setTitle:@"倒计时" forState:UIControlStateNormal];
        _adAlertView.titleLabel.font = [UIFont systemFontOfSize:14];
        _adAlertView.backgroundColor = [UIColor whiteColor];
        [_adAlertView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_adAlertView addTarget:self action:@selector(adAlertClick) forControlEvents:UIControlEventTouchUpInside];
        _adAlertView.hidden = NO;
    }
    return _adAlertView;
}

@end
