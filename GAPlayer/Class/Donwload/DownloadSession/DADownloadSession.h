//
//  DADownloadSession.h
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DonwloadServiceProtocol.h"

@class DADownloadModel;

@interface DADownloadSession : NSObject <DonwloadServiceProtocol>

@property (nonatomic, weak) id <DADownloadSessionDelegate> sessionDelegate;

//下载模型
@property (nonatomic, strong, readonly) DADownloadModel *downloadModel;

/**
 初始化 DownloadSession
 
 @param downloadModel 下载模型
 @return DownloadSession
 */
- (instancetype)initWithDownloadModel:(DADownloadModel *)downloadModel;


@end
