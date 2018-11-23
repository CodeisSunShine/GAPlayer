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
- (GAPlayerDetailModel *)getDetailModelWithVideoId:(NSString *)videoId;

@end

NS_ASSUME_NONNULL_END
