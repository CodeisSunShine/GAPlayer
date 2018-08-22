//
//  DANetworkStateTool.m
//  DownloadFramework
//
//  Created by 宫傲 on 2018/5/8.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "DANetworkStateTool.h"

@interface DANetworkStateTool ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation DANetworkStateTool

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DANetworkStateTool *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DANetworkStateTool alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    }
    return self;
}

- (BOOL)checkCurrentNetworkEnable {
    return [self.reachability currentReachabilityStatus] == NotReachable;
}

@end
