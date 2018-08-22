//
//  GAHttpSeverManager.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/22.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GAPlayerItemModel;

@interface GAHttpSeverManager : NSObject

+ (instancetype)sharedInstance;

/**
 * 启动httpserver
 */
- (void)startServer;

/**
 * 关闭httpserver
 * 1.退出播放器
 * 2.进入后台
 */
- (void)stopServer;

- (void)playResourcePreparation:(GAPlayerItemModel *)playerItemModel;

@end
