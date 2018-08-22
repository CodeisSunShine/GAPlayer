//
//  DownloadError.h
//  DownloadFramework
//
//  Created by 宫傲 on 2018/6/12.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DADownloadCommon.h"

@interface DownloadError : NSObject

@property (nonatomic, strong) NSError *systemError;

@property (nonatomic, copy) NSString *customeReason;

@property (nonatomic, assign) DADownloadFinishCode finishCode;

/**
 * 根据 finishCode 创建错误原因 customeReason为默认原因
 */
- (instancetype)initWithFinishCode:(DADownloadFinishCode)finishCode;

/**
 * 根据 finishCode 和 customeReason 创建错误原因
 */
- (instancetype)initWithinishCode:(DADownloadFinishCode)finishCode
                    customeReason:(NSString *)customeReason;

/**
 * 根据 finishCode 和 error 创建错误原因 customeReason为默认原因
 */
- (instancetype)initWithinishCode:(DADownloadFinishCode)finishCode
                            error:(NSError *)error;

@end
