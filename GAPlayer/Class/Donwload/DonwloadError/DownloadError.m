//
//  DownloadError.m
//  DownloadFramework
//
//  Created by 宫傲 on 2018/6/12.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "DownloadError.h"

@implementation DownloadError

- (instancetype)initWithFinishCode:(DADownloadFinishCode)finishCode {
    return [self initWithinishCode:finishCode customeReason:[self makeProgressFinishCodeWith:finishCode]];
}

- (instancetype)initWithinishCode:(DADownloadFinishCode)finishCode
                    customeReason:(NSString *)customeReason {
    if (self = [super init]) {
        self.finishCode = finishCode;
        self.customeReason = customeReason;
    }
    return self;
}

- (instancetype)initWithinishCode:(DADownloadFinishCode)finishCode
                            error:(NSError *)error {
    if (self = [super init]) {
        self.finishCode = finishCode;
        self.systemError = error;
        self.customeReason = [self makeProgressFinishCodeWith:finishCode];
    }
    return self;
}

- (NSString *)makeProgressFinishCodeWith:(DADownloadFinishCode)finishCode {
    if (self.finishCode == kDADownloadFinishCodeNotReachable) {
        return @"无效网络";
    } else if (self.finishCode == kDADownloadFinishCodeItemLose) {
        return @"Item丢失";
    } else if (self.finishCode == kDADownloadFinishCodeMoveFail) {
        return @"切片转移失败";
    } else if (finishCode == kDADownloadFinishCodeIncomplete) {
        return @"下载任务不完整";
    } else if (finishCode == kDADownloadFinishCodeParseFailure) {
        return @"下载地址解析失败";
    } else if (finishCode == kDADownloadFinishCodeFailToRoot) {
        return @"创建下载根目录失败";
    }
    return @"";
}

@end
