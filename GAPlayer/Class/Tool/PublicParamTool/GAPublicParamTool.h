//
//  GAPublicParamTool.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/27.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kIsPlaying @"isPlaying"

@interface GAPublicParamTool : NSObject

//是否正在播放
@property (nonatomic, assign) BOOL isPlaying;

+ (instancetype)sharedInstance;

@end
