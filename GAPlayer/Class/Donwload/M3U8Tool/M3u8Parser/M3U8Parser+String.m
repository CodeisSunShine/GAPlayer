//
//  M3U8Parser+String.m
//  AvPlayerDemo
//
//  Created by work-li on 16/4/13.
//  Copyright © 2016年 pljhonglu. All rights reserved.
//

#import "M3U8Parser+String.h"

@implementation M3U8Parser (String)

/**
 * 根据传递的m3u8 data 数据初始化实例
 * @param: m3u8data
 */
- (instancetype)initWithM3U8Data:(NSData *)m3u8data
{
    NSString *m3u8string = [[NSString alloc] initWithData:m3u8data encoding:NSUTF8StringEncoding];
    return [self initWithM3U8String:m3u8string];
}

/**
 * 根据传递的m3u8 string 数据初始化实例
 * @param: m3u8string
 */
- (instancetype)initWithM3U8String:(NSString *)m3u8String
{
    self = [super init];
    if (self) {
        self.originM3U8String = m3u8String;
        self.isCryption = NO;
        [self parserM3u8Content];
    }
    return self;
}

#pragma mark - 解析m3u8文件的内容，最终输出的是ts集合及uri路径
/**
 * 通过此方法，最终得到原始文件的ts集合及URI路径
 */
- (void)parserM3u8Content
{
    if (self.originM3U8String.length <= 0) {
        return;
    }
    [self.tsMutableArray removeAllObjects];
    [self.tsTimeArray removeAllObjects];
    //根据换行符，得到当前文本的集合
    NSArray *m3u8Arr = [self.originM3U8String componentsSeparatedByString:@"\n"];
    if ([m3u8Arr count] > 0) {
        [m3u8Arr enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //是否包含"EXT"前缀，如果不包含判断是否包含.ts,如果包含.ts则加入ts 集合
            if ([obj rangeOfString:M3U8PrefixName].location == NSNotFound) {
                //找到对应的ts字段集合
                if ([obj rangeOfString:M3U8TSSuffixName].location != NSNotFound) {
                    [self.tsMutableArray addObject:obj];
                }
            }
            else //如果包含"EXT"前缀，则把对应的uri 路径提取出来
            {
                //提取时间序列
                if ([obj rangeOfString:M3U8TSTimeSequence].location != NSNotFound) {
                    NSArray *timeArr = [obj componentsSeparatedByString:@","];
                    [timeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *timeStr = obj;
                        if (timeStr.length > 0 && [timeStr rangeOfString:M3U8TSTimeSequence].location != NSNotFound)
                        {
                            NSArray *arr = [timeStr componentsSeparatedByString:@":"];
                            [self.tsTimeArray addObject:arr[1]];
                        }
                    }];
                }
                //找到对应的URI
                if([obj rangeOfString:M3U8URI].location != NSNotFound)
                {
                    NSArray *keyURIArr = [obj componentsSeparatedByString:@","];
                    [keyURIArr enumerateObjectsUsingBlock:^(NSString *  _Nonnull uriObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([uriObj hasPrefix:M3U8URI] == YES) {
                            
                            self.m3u8URI = [uriObj substringWithRange:NSMakeRange(4, uriObj.length - 4)];
                            self.m3u8URI = [self.m3u8URI stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            self.isCryption = YES;
                        }
                    }];
                }
            }
        }];
    }
}



@end
