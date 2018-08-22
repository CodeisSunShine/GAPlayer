//
//  GAAVPlayer.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/13.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerProtocol.h"

@interface GAAVPlayer : NSObject <PlayerProtocol>

@property (nonatomic, weak) id <PlayerCallBackDelegate> callBackDelegate;

@property (nonatomic, assign) PlayerState playerState;

@property (nonatomic, assign) UIView *playView;

@end
