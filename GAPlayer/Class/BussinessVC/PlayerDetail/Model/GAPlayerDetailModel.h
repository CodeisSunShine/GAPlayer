//
//  GAPlayerDetailModel.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GAPlayerDetailModel : NSObject

@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, copy) NSString *videoName;

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) NSDictionary *playDict;

@property (nonatomic, assign) NSInteger downloadState;

/**
 * 下载百分比
 */
@property (nonatomic, assign) CGFloat percentage;

/**
 * 下载速度
 */
@property (nonatomic, copy) NSString *speed;

@property (nonatomic, assign) BOOL isActive;

@end

NS_ASSUME_NONNULL_END
