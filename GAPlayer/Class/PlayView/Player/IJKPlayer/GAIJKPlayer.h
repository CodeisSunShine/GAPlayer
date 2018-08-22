//
//  GAIJKPlayer.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/1.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAPlayerModel.h"
#import "PlayerProtocol.h"

@interface GAIJKPlayer : NSObject <PlayerProtocol>

@property (nonatomic, weak) id <PlayerCallBackDelegate> callBackDelegate;

@property (nonatomic, assign) PlayerState playerState;

@property (nonatomic, assign) UIView *playView;

@end
