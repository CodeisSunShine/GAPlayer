//
//  CENetMonitorManger.h
//  DongAoAcc
//
//  Created by 宫傲 on 2018/8/29.
//  Copyright © 2018年 wihan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 网络类型
 */
typedef NS_ENUM(NSUInteger, NetworkMonitorType) {
    /** 断网 */
    kNetMonTypeUnAble = 0,
    /** 移动网络 */
    kNetMonTypeWWAN,
    /** wifi */
    kNetMonTypeWiFi
};

/**
 * 网络变化的类型
 */
typedef NS_ENUM(NSUInteger, NetworkChangeType) {
    /** WiFi -> 移动网络 */
    kNetChaTypeWiToWW = 0,
    /** WiFi -> 断网 */
    kNetChaTypeWiToUA,
    /** 移动网络 -> 断网 */
    kNetChaTypeWWToUA,
    /** 断网 -> 移动网络 */
    kNetChaTypeUAToWW
};

typedef void(^CENetMonNetworkChangeBlock)(NetworkMonitorType monitorType);

@interface CENetMonitorManger : NSObject

@property (nonatomic, assign) BOOL allowWwanDownload;

+ (instancetype)sharedInstance;

/**
 * 开启监听
 */
- (void)startMonitor;

/**
 * 添加网络变化回调
 */
- (void)addNetworkChangeBlock:(CENetMonNetworkChangeBlock)networkChangeBlock
                      idClass:(NSString *)idClass;

/**
 * 删除回调
 */
- (void)removeNetMonitorBlcokWithIdClass:(NSString *)idClass;

/**
 * 获取当前网络环境
 */
- (NetworkMonitorType)acquisitionNetworkEnvironment;

@end
