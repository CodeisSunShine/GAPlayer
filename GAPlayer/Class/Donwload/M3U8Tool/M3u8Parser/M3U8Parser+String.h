//
//  M3U8Parser+String.h
//  AvPlayerDemo
//
//  Created by work-li on 16/4/13.
//  Copyright © 2016年 pljhonglu. All rights reserved.
//

#import "M3U8Parser.h"
#import "M3U8PlayerKey.h"

@interface M3U8Parser (String)

/**
 * 根据传递的m3u8 data 数据初始化实例
 * @param m3u8data m3u8data
 */
- (instancetype)initWithM3U8Data:(NSData *)m3u8data;

/**
 * 根据传递的m3u8 string 数据初始化实例
 * @param m3u8String m3u8string
 */
- (instancetype)initWithM3U8String:(NSString *)m3u8String rootUrl:(NSString *)rootUrl;



@end
