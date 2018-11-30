//
//  GAPlayerDetailViewModel.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GAPlayerDetailModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^PlayerDetailFinishCountBlock)(NSInteger finishCount, NSInteger unFinishCount);

@interface GAPlayerDetailViewModel : NSObject

/**
 * 拉取详情数据
 */
- (void)requestPlayerDetailData:(NSDictionary *)dict successBlock:(void (^)(BOOL success, id object))successBlock;

/**
 * 将指定进行下载
 */
- (void)downloadTaskWith:(GAPlayerDetailModel *)detailModel;

/**
 * 通过videoId获取GAPlayerDetailModel
 */
- (GAPlayerDetailModel *)getPlayerDetailModelWith:(NSString *)videoId;

/**
 * 获取播放视频需要的播放字典
 */
- (NSDictionary *)makeProgressPlayData:(GAPlayerDetailModel *)detailModel;

/**
 * 拉取下载和未下载的数据
 */
- (void)requestUnFinishAndFinishData:(NSDictionary *)dict successBlock:(PlayerDetailFinishCountBlock)successBlock;

@end

NS_ASSUME_NONNULL_END
