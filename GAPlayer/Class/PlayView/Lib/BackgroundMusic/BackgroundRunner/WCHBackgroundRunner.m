//
//  WCHBackgroundRunner.m
//  MDMAgent
//
//  Created by wihan on 13-3-25.
//  Copyright (c) 2013年 wihan. All rights reserved.
//

#import "WCHBackgroundRunner.h"

@interface WCHBackgroundRunner ()

@property (nonatomic, strong) AVAudioPlayer *backgroundPlayer;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (nonatomic, strong) NSTimer *loopTimer;

@property (nonatomic, assign) BOOL isPlay;

@end

@implementation WCHBackgroundRunner

- (id)init {
    self = [super init];
    if (self) {
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [[AVAudioSession sharedInstance] setActive:YES error:nil];

        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"mute" ofType:@"mp3"];
        NSURL *audioURL = [[NSURL alloc] initFileURLWithPath:audioPath];
        self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        self.backgroundPlayer.delegate = self;
        [self.backgroundPlayer setVolume:0.8];
        self.backgroundPlayer.numberOfLoops = -1;
        [self.backgroundPlayer prepareToPlay];
    }
    
    return self;
}

- (void)dealloc {
    [self.backgroundPlayer stop];
}

- (void)runnerDidEnterBackground {
    if (self.isPlay) {
        return;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];

    self.isPlay = YES;
    [self.backgroundPlayer play];
    
    if (self.loopTimer != nil)
    {
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }

    self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(action)
                                                userInfo:nil
                                                 repeats:YES];
   
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
}

- (void)action{
    if (self.actionBlock) {
        self.actionBlock();
    }
    NSLog(@"一直在打印......");
}

- (void)runnerWillEnterForeground {
    if (!self.isPlay) {
        return;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowAirPlay error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.isPlay = NO;
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
    [self.backgroundPlayer stop];
    
    if (self.loopTimer != nil)
    {
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
}

- (void)tik{
    
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
    
}

@end
