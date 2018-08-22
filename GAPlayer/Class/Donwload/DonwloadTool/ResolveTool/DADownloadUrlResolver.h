//
//  DADownloadUrlResolver.h
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/13.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DADownloadUrlResolver : NSObject

+ (void)analysisDownloadUrls:(NSArray *)downloadUrls
                    localUrl:(NSString *)localFileUrl
                 finishBlock:(void(^)(BOOL success, id object))finishBlock;

@end
