//
//  WCHBackgroundRunner.h
//  MDMAgent
//
//  Created by wihan on 13-3-25.
//  Copyright (c) 2013年 wihan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef void(^Actions)();
@interface WCHBackgroundRunner : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) Actions actionBlock;

- (void)runnerDidEnterBackground;
- (void)runnerWillEnterForeground;

@end
