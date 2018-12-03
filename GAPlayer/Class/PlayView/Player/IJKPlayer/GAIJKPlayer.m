//
//  GAIJKPlayer.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/1.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAIJKPlayer.h"
#import "NSObject+FBKVOController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "NSObject+GABackgroundMonitoring.h"

@interface GAIJKPlayer ()

//@property (nonatomic, strong) id <IJKMediaPlayback> player;

@property (nonatomic, strong) id <IJKMediaPlayback> player;

@property (nonatomic, assign) BOOL isPause;

@property (nonatomic, strong) IJKFFOptions *options;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) BOOL timerRuning;
//同意后台播放
@property (nonatomic, assign) BOOL allowBackPlay;
@property (nonatomic, assign) BOOL isBackground;

@end

@implementation GAIJKPlayer

#pragma mark - init
- (instancetype)initWith:(UIView *)playView {
    if (self = [super init]) {
        self.playView = playView;
        [self initializeTheTimer];
        [self reloadPlayerDuration];
        [self registerGroundMonitoring];
        self.allowBackPlay = YES;
    }
    return self;
}

#pragma mark - public
// 添加播放器数据源
- (void)setThePlayerDataSource:(GAPlayerModel *)playerModel {
    [self createPlayerWith:playerModel];
}

// 播放
- (void)play {
    if (self.isPause) {
        [self.player play];
    } else {
        [self.player prepareToPlay];
    }
    [self startTimer];
    self.isPause = NO;
}

// 暂停
- (void)pause {
    if (!self.isPause) {
        self.isPause = YES;
        [self.player pause];
        [self pauseTimer];
    }
}

// 关闭
- (void)stop {
    [self releasePlayer];
}

// 切换倍速
- (void)switchingTimesSpeed:(CGFloat)speed {
    self.player.playbackRate = speed;
}

// 从此刻开始播放
- (void)playFromNowOnWithSchedule:(CGFloat)schedule {
    [self makeProgressCallBackPlayerState:kPlayerStateCacheing];
    self.player.currentPlaybackTime = schedule;
}

- (void)makeProgressPlayerViewFrame:(CGRect)frame {
    self.player.view.frame = frame;
}

- (void)setVideoPlayTheBackground:(BOOL)isBackPlay {
    if (self.allowBackPlay == isBackPlay) return;
    if (self.isBackground) return;
    self.allowBackPlay = isBackPlay;
}

#pragma mark - 前/后台 播放器处理
- (void)registerGroundMonitoring {
    __weak typeof(self)weakSelf = self;
    [self registergroundBlock:^(BOOL isBackground) {
        weakSelf.isBackground = isBackground;
        if (!weakSelf.allowBackPlay) {
            if (isBackground) {
                if (!weakSelf.isPause) {
                    [self.player pause];
                }
            } else {
                if (!weakSelf.isPause) {
                    [self.player play];
                }
            }
        }
    }];
}

#pragma mark - private
- (void)createPlayerWith:(GAPlayerModel *)playerModel {
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
    
    [self releasePlayer];
    self.options = [IJKFFOptions optionsByDefault];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:playerModel.playURL] withOptions:self.options];
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    [self.player setPauseInBackground:NO];
    // 是否自动播放
    self.player.shouldAutoplay = YES;
    [self.playView addSubview:self.player.view];
    [self initializesThePlayerNotification];
}

// 初始化监听
- (void)initializesThePlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaIsPreparedToPlayDidChange:)name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackStateDidChange:)    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
}

// 删除监听
- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
}

#pragma mark - Notification method
- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = _player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
        [self makeProgressCallBackPlayerState:kPlayerStateReady];
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
        [self makeProgressCallBackPlayerState:kPlayerStateCacheing];
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

// 播放结束
- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            [self makeProgressCallBackPlayerState:kPlayerStateFinish];
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            //现在是用户退出状态
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            //现在是播放错误状态
        case IJKMPMovieFinishReasonPlaybackError:
            [self makeProgressCallBackPlayerState:kPlayerStateFailure];
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

// 播放状态发生改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped: {
            [self makeProgressCallBackPlayerState:kPlayerStateStop];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            [self makeProgressCallBackPlayerState:kPlayerStatePlaying];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            [self makeProgressCallBackPlayerState:kPlayerStatePause];
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

// 销毁播放器
- (void)releasePlayer {
    if (self.player) {
        [self pauseTimer];
        [self.player pause];
        [self.player shutdown];
        [self removeMovieNotificationObservers];
        [self.player.view removeFromSuperview];
        self.player = nil;
        self.options = nil;
    }
}

- (void)reloadPlayerDuration {
    if (!self.isPause) {
    }
    [self performSelector:@selector(reloadPlayerDuration) withObject:nil afterDelay:1];
}

#pragma mark - 定时器
- (void)initializeTheTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 0.5 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playerDurationCallBack];
        });
    });
    
}

- (void)startTimer {
    if (self.timer && !self.timerRuning) {
        self.timerRuning = YES;
        dispatch_resume(self.timer);
    }
}

- (void)pauseTimer {
    if (self.timer && self.timerRuning) {
        dispatch_suspend(self.timer);
        self.timerRuning = NO;
    }
}

- (void)destructionTimer {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

#pragma mark - 代理回调
// 进度改变
- (void)playerDurationCallBack {
    if (self.callBackDelegate && [self.callBackDelegate respondsToSelector:@selector(playbackProgressCallback:currentPlaybackTime:playableDuration:)]) {
        [self.callBackDelegate playbackProgressCallback:self.player.duration currentPlaybackTime:self.player.currentPlaybackTime playableDuration:self.player.playableDuration];
    }
}

// 状态改变
- (void)makeProgressCallBackPlayerState:(PlayerState)playerState {
    // 如果是正常播放完成 则强制将播放进度变为总进度
    if (playerState == kPlayerStateFinish) {
        if (self.callBackDelegate && [self.callBackDelegate respondsToSelector:@selector(playbackProgressCallback:currentPlaybackTime:playableDuration:)]) {
            [self.callBackDelegate playbackProgressCallback:self.player.duration currentPlaybackTime:self.player.playableDuration playableDuration:self.player.playableDuration];
        }
    }
    
    if (self.callBackDelegate && [self.callBackDelegate respondsToSelector:@selector(playbackStatusCallback:)]) {
        [self.callBackDelegate playbackStatusCallback:playerState];
    }
}

- (void)dealloc {
    [self destructionTimer];
    [self removeMovieNotificationObservers];
}

@end
