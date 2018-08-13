//
//  GAPlayerTool.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/1.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerTool.h"

@implementation GAPlayerTool

/**
 * 转换时间
 */
+ (NSString *)convertPlayTimeToString:(double)time
{
    //转成秒数
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    [formatter setDateFormat:(time/3600>=1)? @"hh:mm:ss":@"mm:ss"];
    NSString *currentTimeStr = [formatter stringFromDate:currentDate];
    return currentTimeStr;
}

@end
