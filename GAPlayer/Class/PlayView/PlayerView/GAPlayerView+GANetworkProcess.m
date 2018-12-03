//
//  GAPlayerView+GANetworkProcess.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/30.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerView+GANetworkProcess.h"
#import "CENetMonitorManger.h"

@implementation GAPlayerView (GANetworkProcess)

#pragma mark - public
- (void)startNetworkProcess {
    [[CENetMonitorManger sharedInstance] addNetworkChangeBlock:^(NetworkMonitorType monitorType) {
        
    } idClass:@"CENetMonitorManger"];
}

- (void)stopNetworkProcess {
    [[CENetMonitorManger sharedInstance] removeNetMonitorBlcokWithIdClass:@"CENetMonitorManger"];
}

#pragma mark - private
- (void)makeProgressNetworkProcess:(NetworkMonitorType)monitorType {
    if (monitorType == kNetMonTypeUnAble) {
        
    } else if (monitorType == kNetMonTypeWWAN) {
        
    } else if (monitorType == kNetMonTypeWiFi) {
        
    }
}

@end
