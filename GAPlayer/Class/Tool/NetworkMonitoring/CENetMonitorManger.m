//
//  CENetMonitorManger.m
//  DongAoAcc
//
//  Created by 宫傲 on 2018/8/29.
//  Copyright © 2018年 wihan. All rights reserved.
//

#import "CENetMonitorManger.h"
#import "AFNetworking.h"

static NSString *const kNetworkChangeCallBackKey = @"NetworkChange";

typedef NSMutableDictionary<NSString *, id> NMCallbacksDictionary;

@interface CENetMonitorManger ()

//当前的网络环境
@property (nonatomic, assign) NetworkMonitorType currentNetworkType;

// 回调数据源
@property (nonatomic, strong, nonnull) NSMutableDictionary *callbackBlocks;

@property (nonatomic, assign) BOOL isFirstLauch;

@end

@implementation CENetMonitorManger

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CENetMonitorManger *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CENetMonitorManger alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.currentNetworkType = [self makeProgressMonitorTypeWith:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus];
        self.isFirstLauch = YES;
    }
    return self;
}

- (void)startMonitor {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    //当网络状态改变的时候，就会调用
    __weak typeof(self)weakSelf = self;
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [weakSelf theNetworkEnvironmentChanged:[self makeProgressMonitorTypeWith:status]];
    }];
    //开始监控
    [mgr startMonitoring];
}

// 网络发生变化处理
- (void)theNetworkEnvironmentChanged:(NetworkMonitorType)networkType {
    if (networkType == kNetMonTypeUnAble) {
        if (self.currentNetworkType == kNetMonTypeWiFi) {
            [self networkChangeCallBack:kNetChaTypeWiToUA];
        } else if (self.currentNetworkType == kNetMonTypeWWAN) {
            [self networkChangeCallBack:kNetChaTypeWWToUA];
        }
    } else if (networkType == kNetMonTypeWWAN) {
        if (self.currentNetworkType == kNetMonTypeWiFi) {
            [self networkChangeCallBack:kNetChaTypeWiToWW];
        } else if (self.currentNetworkType == kNetMonTypeUnAble) {
            [self networkChangeCallBack:kNetChaTypeUAToWW];
        }
    }
    
//    if (self.isFirstLauch) {
//        self.isFirstLauch = NO;
//        [[CECacheManager sharedInstance] queryingTheDatabaseUnfinishedDownloadTask];
//    }
    
    self.currentNetworkType = networkType;
}

// 添加网络变化回调
- (void)addNetworkChangeBlock:(CENetMonNetworkChangeBlock)networkChangeBlock
                      idClass:(NSString *)idClass {
    __weak __typeof(self) weakself= self;
    @synchronized(self) {
        NMCallbacksDictionary *callbacksDictionary = [[NMCallbacksDictionary alloc] init];
        [callbacksDictionary setObject:networkChangeBlock forKey:kNetworkChangeCallBackKey];
        [weakself.callbackBlocks setObject:callbacksDictionary forKey:idClass];
    }
}

// 删除回调
- (void)removeNetMonitorBlcokWithIdClass:(NSString *)idClass {
    if (idClass.length > 0) {
        NMCallbacksDictionary *callbacksDictionary = self.callbackBlocks[idClass];
        if (callbacksDictionary) {
            [self.callbackBlocks removeObjectForKey:idClass];
        }
    }
}

// 网络状态变化的回调
- (void)networkChangeCallBack:(NetworkChangeType)changeType {
    [self.callbackBlocks.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *blockDict = self.callbackBlocks[obj];
        CENetMonNetworkChangeBlock networkChangeBlock = blockDict[kNetworkChangeCallBackKey];
        if (networkChangeBlock) {
            networkChangeBlock(changeType);
        }
    }];
}

//获取网络环境
- (NetworkMonitorType)acquisitionNetworkEnvironment {
    return [self makeProgressMonitorTypeWith:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus];
}

- (NetworkMonitorType)makeProgressMonitorTypeWith:(AFNetworkReachabilityStatus)status {
    NetworkMonitorType networkType;
    switch (status) {
        case AFNetworkReachabilityStatusUnknown://未知网络
        case AFNetworkReachabilityStatusNotReachable://没有网络
        {
            NSLog(@"没有网络（断网）");
            networkType = kNetMonTypeUnAble;
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN://手机自带网络
        {
            NSLog(@"手机自带网络");
            networkType = kNetMonTypeWWAN;
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi://WIFI
        {
            NSLog(@"WIFI");
            networkType = kNetMonTypeWiFi;
        }
            break;
    }
    return networkType;
}

- (NSMutableDictionary *)callbackBlocks {
    if (!_callbackBlocks) {
        _callbackBlocks = [[NSMutableDictionary alloc] init];
    }
    return _callbackBlocks;
}

@end
