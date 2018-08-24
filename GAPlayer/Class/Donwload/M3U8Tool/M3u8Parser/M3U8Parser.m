//
//  M3U8Parser.m
//  AvPlayerDemo
//
//  Created by work-li on 16/4/13.
//  Copyright © 2016年 pljhonglu. All rights reserved.
//

#import "M3U8Parser.h"

#define kNotFoundErrorTS    @"没有找到出错的ts"

@implementation M3U8Parser


///**
// * 是否需要解密,如果m3u8 文件的uri 存在则需要解密，否则不需要解密
// */
//- (BOOL)isCryption
//{
//    if (self.m3u8URI.length > 0) {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}

#pragma mark - set/get private method
- (NSMutableArray *)tsUrlMutableArray
{
    if (_tsUrlMutableArray == nil) {
        _tsUrlMutableArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tsUrlMutableArray;
}

- (NSMutableArray *)tsNameMutableArray {
    if (_tsNameMutableArray == nil) {
        _tsNameMutableArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tsNameMutableArray;
}

/**
 * 记录当前每个ts 的时间序列集合
 */
- (NSMutableArray *)tsTimeArray
{
    if (!_tsTimeArray) {
        _tsTimeArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tsTimeArray;
}


/**
 * 根据ts播放时间序列，查找出错的ts字段
 * @param: errTime 当前出错的时间
 */
- (NSString *)findErrorTsByTime:(NSInteger)errTime
{
    if (self.tsTimeArray.count > 0) {
        
        __block  NSInteger tmpTotalTime = 0;
        __block  NSInteger errIndex = -1;
        [self.tsTimeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *tmp = obj;
            tmpTotalTime += [tmp intValue];
            if (tmpTotalTime >= errTime) {
                
                errIndex = idx;
                *stop = YES;
            }
        }];
//        if (errIndex < self.tsMutableArray.count && errIndex >= 0) {
//            return self.tsMutableArray[errIndex];
//        }
//        else
//        {
//            return kNotFoundErrorTS;
//        }
        
        
    }
    return kNotFoundErrorTS;
}


@end
