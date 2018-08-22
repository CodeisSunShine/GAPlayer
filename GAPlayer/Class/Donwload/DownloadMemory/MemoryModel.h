//
//  MemoryModel.h
//  DownloadVC
//
//  Created by 宫傲 on 2018/6/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryModel : NSObject

@property (nonatomic, copy) NSString *fileId;

/**
 * 本次回调写入沙盒的大小
 */
@property (nonatomic, assign) int64_t bytesWritten;

/**
 * 下载速度
 */
@property (nonatomic, assign) int64_t downloadSpeed;

@end
