//
//  GAAVPlayer.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/13.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAAVPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "FBKVOController.h"
#import "NSObject+FBKVOController.h"
#import "NSObject+GABackgroundMonitoring.h"

@interface GAAVPlayer ()

//playerLayer
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
//当前播放的item
@property (nonatomic, strong) AVPlayerItem *currentItem;
//播放器player
@property (nonatomic, strong) AVPlayer *player;
//是否暂停
@property (nonatomic, assign) BOOL isPause;
//总时长
@property (nonatomic, assign) CGFloat totalTime;
//监听播放时间的监听者
@property (nonatomic, strong) id playbackTimeObserver;
//同意后台播放
@property (nonatomic, assign) BOOL allowBackPlay;
@property (nonatomic, assign) BOOL isBackground;

@end


@implementation GAAVPlayer

#pragma mark - public
// 初始化播放器
- (instancetype)initWith:(UIView *)playView {
    if (self = [super init]) {
        self.playView = playView;
        [self registerGroundMonitoring];
        [self createSession];
        self.allowBackPlay = YES;
    }
    return self;
}

// 改变播放器数据源
- (void)setThePlayerDataSource:(GAPlayerModel *)playerModel {
    if (self.player) {
        [self createAVPlayerItemWith:playerModel];
        [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    } else {
        [self createPlayerWith:playerModel];
    }
}

// 播放
- (void)play {
    [self.player play];
}

// 暂停
- (void)pause {
    [self.player pause];
}

// 关闭播放器
- (void)stop {
    [self releasePlayer];
}

// 切换倍速
- (void)switchingTimesSpeed:(CGFloat)speed {
    self.player.rate = speed;
}

// 从此刻开始播放
- (void)playFromNowOnWithSchedule:(CGFloat)seekTime {
    [self.player seekToTime:CMTimeMakeWithSeconds(seekTime, self.currentItem.currentTime.timescale)];
}

// 改变播放器view的frame
- (void)makeProgressPlayerViewFrame:(CGRect)frame {
    self.playerLayer.frame = frame;
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
        if (weakSelf.allowBackPlay) {
            if (isBackground) { // 进入后台
                weakSelf.playerLayer.player = nil;
                [weakSelf.playerLayer setPlayer:nil];
            } else { // 进入前台
                weakSelf.playerLayer.player = weakSelf.player;
            }
        } else {
            if (!isBackground && !weakSelf.isPause) {
                [weakSelf play];
            }
        }
    }];
}

#pragma mark - private
- (void)createSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

// 创建播放器
- (void)createPlayerWith:(GAPlayerModel *)playerModel {
    [self createAVPlayerItemWith:playerModel];
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    [self initTimeObserver];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    // 填充模式
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playView.layer insertSublayer:self.playerLayer atIndex:0];
}

// 创建播放Item
- (void)createAVPlayerItemWith:(GAPlayerModel *)playerModel {
    if (self.currentItem) {
        [self releasePlayerItem];
    }
    
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:playerModel.playURL]];
    self.currentItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    [self addPlayerItemObserver];
}

// 播放状态放生改变
- (void)thePlayerStateHasChanged:(AVPlayerStatus)status {
    PlayerState playerState = kPlayerStateUnkonw;
    if (status == AVPlayerStatusUnknown) {
        playerState = kPlayerStateCacheing;
        NSLog(@"AVPlayerStatusUnknown");
    } else if (status == AVPlayerItemStatusReadyToPlay) {
        playerState = kPlayerStateReady;
        NSLog(@"AVPlayerItemStatusReadyToPlay");
    } else if (status == AVPlayerItemStatusFailed) {
        playerState = kPlayerStateFailure;
        NSLog(@"AVPlayerItemStatusFailed");
    }
    self.playerState = playerState;
    [self makeProgressCallBackPlayerState:playerState];
}

// 销毁播放器
- (void)releasePlayer {
    if (self.player) {
        [self releasePlayerItem];
        [self removeTimeObserver];
        [self.playerLayer removeFromSuperlayer];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.player = nil;
    }
}

// 销毁playerItem
- (void)releasePlayerItem {
    if (self.currentItem) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        [self.player pause];
        [self removePlayerItemObserver];
        self.currentItem = nil;
    }
}

#pragma mark - kvo
- (void)addPlayerItemObserver {
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:self.currentItem keyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(GAAVPlayer *aVPlayer, AVPlayerItem *currentItem, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        NSLog(@"监听值改变 ---------------------------  person status %@   NSKeyValueChangeNewKey == %@",self.currentItem,change[NSKeyValueChangeNewKey]);
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        [weakSelf thePlayerStateHasChanged:status];
    }];
    [self.KVOController observe:self.currentItem keyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(GAAVPlayer *aVPlayer, AVPlayerItem *currentItem, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        NSLog(@"监听值改变 ---------------------------  person loadedTimeRanges %@   NSKeyValueChangeNewKey == %@",self.currentItem,change[NSKeyValueChangeNewKey]);
    }];
    [self.KVOController observe:self.currentItem keyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(GAAVPlayer *aVPlayer, AVPlayerItem *currentItem, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
//        if (self.playerState != kPlayerStatePause && self.playerState != kPlayerStateFinish) {
//            self.playerState = kPlayerStateFailure;
//        }
    }];
    [self.KVOController observe:self.currentItem keyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(GAAVPlayer *aVPlayer, AVPlayerItem *currentItem, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        NSLog(@"监听值改变 ---------------------------  person playbackLikelyToKeepUp %@   NSKeyValueChangeNewKey == %@",self.currentItem,change[NSKeyValueChangeNewKey]);
    }];
    [self.KVOController observe:self.currentItem keyPath:@"duration" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(GAAVPlayer *aVPlayer, AVPlayerItem *currentItem, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        weakSelf.totalTime = (CGFloat)CMTimeGetSeconds(weakSelf.currentItem.duration);
    }];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
}

- (void)removePlayerItemObserver {
    if (self.currentItem) {
        [self.KVOController unobserve:self.currentItem keyPath:@"status"];
        [self.KVOController unobserve:self.currentItem keyPath:@"loadedTimeRanges"];
        [self.KVOController unobserve:self.currentItem keyPath:@"playbackBufferEmpty"];
        [self.KVOController unobserve:self.currentItem keyPath:@"playbackLikelyToKeepUp"];
        [self.KVOController unobserve:self.currentItem keyPath:@"duration"];
    }
}

#pragma mark
#pragma mark--播放完成
- (void)moviePlayDidEnd:(NSNotification *)notification {
    self.playerState = kPlayerStateFinish;
    [self makeProgressCallBackPlayerState:kPlayerStateFinish];
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
    }];
}

#pragma mark - TimeObserver
- (void)initTimeObserver {
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)  queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
        [weakSelf updatePlayerTime];
    }];
}

- (void)updatePlayerTime {
    if (self.playerState == kPlayerStatePlaying || self.playerState == kPlayerStateReady || self.playerState == kPlayerStateCacheing) {
        long long currentTime = self.currentItem.currentTime.value / self.currentItem.currentTime.timescale;
        long long playableTime = [self makeProgressPlayableTime];
        [self playerDurationCallBackWith:currentTime totalTime:self.totalTime playableTime:playableTime];
    }
}

- (long long)makeProgressPlayableTime {
    NSArray *loadedTimeRanges = [_currentItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    return startSeconds + durationSeconds;// 计算缓冲总进度
}

- (void)removeTimeObserver {
    if (self.playbackTimeObserver && self.player) {
        [self.player removeTimeObserver:self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
    }
}

#pragma mark - 代理回调
// 状态改变
- (void)makeProgressCallBackPlayerState:(PlayerState)playerState {
    if (self.callBackDelegate && [self.callBackDelegate respondsToSelector:@selector(playbackStatusCallback:)]) {
        [self.callBackDelegate playbackStatusCallback:playerState];
    }
}

// 进度改变
- (void)playerDurationCallBackWith:(long long)currentTime totalTime:(long long)totalTime playableTime:(long long)playableTime{
    if (self.callBackDelegate && [self.callBackDelegate respondsToSelector:@selector(playbackProgressCallback:currentPlaybackTime:playableDuration:)]) {
        [self.callBackDelegate playbackProgressCallback:totalTime currentPlaybackTime:currentTime playableDuration:playableTime];
    }
}

- (void)dealloc {
    [self releasePlayer];
}

@end
