//
//  DANetworkStateTool.h
//  DownloadFramework
//
//  Created by 宫傲 on 2018/5/8.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface DANetworkStateTool : NSObject

+ (instancetype)sharedInstance;

- (BOOL)checkCurrentNetworkEnable;

@end
