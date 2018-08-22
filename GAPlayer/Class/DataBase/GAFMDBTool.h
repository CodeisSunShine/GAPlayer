//
//  GAFMDBTool.h
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/20.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAFMDBTool : NSObject

- (void)createTableWithSQLString:(NSString *)sqlString;

- (BOOL)insetTaskDataWithString:(NSString *)sqlString;

- (NSArray *)queryTaskDataWithString:(NSString *)sqlString;

- (BOOL)deleteTaskDataWithString:(NSString *)sqlString;

- (BOOL)modifyTaskDataWithString:(NSString *)sqlString;

@end
