//
//  DownloadMemory.h
//  DownloadVC
//
//  Created by 宫傲 on 2018/6/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DownloadMemorySizeBlock)(int64_t usedTotalSize,int64_t freeTotalSize);

@interface DownloadMemory : NSObject

/**
 * 内存改变回调
 */
@property (nonatomic, strong) DownloadMemorySizeBlock sizeBlock;

/**
 * 根据 fielId 获取下载速度
 */
- (int64_t)getSpeedWithFileId:(NSString *)fielId;

/**
 * 记录 下载存入
 */
- (void)makeProgressFileId:(NSString *)fielId bytesWritten:(int64_t)bytesWritten;

@end
