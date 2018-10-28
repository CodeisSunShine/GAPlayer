//
//  GAHttpSeverManager.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/22.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GAHttpSeverManager : NSObject

/**
 * 初始化
 */
+ (instancetype)sharedInstance;

/**
 * 启动httpserver
 */
- (void)startServer;

/**
 * 关闭httpserver
 */
- (void)stopServer;


@end
