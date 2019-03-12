//
//  GACacheModelTool.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GACacheModel.h"

@interface GACacheModelTool : NSObject

+ (void)makeProgressCacheModelWith:(NSDictionary *)dict callBlock:(void (^)(BOOL success, id object))callBlock;

+ (NSDictionary *)makeProgressDataBaseDictWith:(GACacheModel *)cacheModel;

+ (NSString *)makeProgressDownloadStateStringWith:(DADownloadState)downloadState;

+ (NSArray *)getCacheModelListWithDatabaseDictList:(NSArray *)dictList;

+ (GACacheModel *)getCacheModelWithDatabaseDict:(NSDictionary *)databaseDict;

@end
