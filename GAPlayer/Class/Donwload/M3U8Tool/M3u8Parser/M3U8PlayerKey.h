//
//  M3U8PlayerKey.h
//  AvPlayerDemo
//
//  Created by work-li on 16/4/8.
//  Copyright © 2016年 pljhonglu. All rights reserved.
//

#ifndef M3U8PlayerKey_h
#define M3U8PlayerKey_h


/**
 * 正常的访问协议
 */
#define M3U8NORMALHTTPSCHEME    @"http"

/**
 * 正常的安全访问协议
 */
#define M3U8NORMALHTTPSECUTITYSCHEME @"https"

/**
 * 替换URI的Key
 */
#define M3U8PlayerHTTPSKey      @"streaming"

/**
 * 替换http 与 https模式的schema
 */
#define M3U8PlayerHTTPSChema    @"streaming"


/**
 * m3u8 文件中开头的前缀
 */
#define M3U8PrefixName      @"#EXT"

/**
 * m3u8 时间序列前缀
 */
#define M3U8TSTimeSequence  @"#EXTINF"

/**
 * ts的后缀名
 */
#define M3U8TSSuffixName     @"ts"

/**
 * 文件中的URI 标识
 */
#define M3U8URI             @"URI"

/**
 * m3u8 后缀名
 */
#define M3U8SuffixName      @"m3u8"


#endif /* M3U8PlayerKey_h */
