//
//  M3U8Parser.h
//  AvPlayerDemo
//
//  Created by work-li on 16/4/13.
//  Copyright © 2016年 pljhonglu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3U8Parser : NSObject

/**
 * 存储m3u8的临时文件字符串 　m3u8文件内部url
 */
@property (nonatomic, strong) NSString *originM3U8String;

/**
 * ts 集合字段
 */
@property (nonatomic, strong) NSMutableArray *tsMutableArray;

/**
 * ts 时间序列集合
 */
@property (nonatomic, strong) NSMutableArray *tsTimeArray;

/**
 * m3u8文件的URI
 */
@property (nonatomic, strong) NSString *m3u8URI;

/**
 * m3u8 的网络地址
 */
@property (nonatomic, strong) NSString *m3u8NetAddress;

/**
 * 获取M3U8的视频ID
 */
@property (nonatomic, strong) NSString *vedioId;


/**
 * 是否需要解密,如果m3u8 文件的uri 存在则需要解密，否则不需要解密
 */
@property (nonatomic, assign) BOOL isCryption;


#pragma mark - 对应的app
/**
 当前播放文件对应的app
 */
@property (nonatomic, strong) NSString *app;


/**
 当前播放文件对应的type
 */
@property (nonatomic, strong) NSString *type;

/**
 当前播放文件对应的vedioId
 */
@property (nonatomic, strong) NSString *vid;


/**
 当前播放器的机密后的key
 */
@property (nonatomic, strong) NSString *key;

#pragma mark - 对应的m3u8播放的网络地址

/**
 * 查找出错的ts字段
 * @param errTime 当前出错的时间
 */
- (NSString *)findErrorTsByTime:(NSInteger)errTime;

@end
