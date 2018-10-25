//
//  GAPublicParamTool.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/27.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPublicParamTool.h"

@implementation GAPublicParamTool

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GAPublicParamTool *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GAPublicParamTool alloc] init];
    });
    return sharedInstance;
}

@end
