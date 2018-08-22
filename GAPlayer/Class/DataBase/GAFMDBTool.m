//
//  GAFMDBTool.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/20.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAFMDBTool.h"
#import "FMDB.h"

#define Player_NAME @"GAPlayer.sqlite"

@interface GAFMDBTool()

@property (nonatomic, strong) FMDatabase *database;

@end

@implementation GAFMDBTool

- (instancetype)init {
    if (self = [super init]) {
        [self initFMDatabase];
    }
    return self;
}

- (void)initFMDatabase {
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:Player_NAME];
    self.database = [FMDatabase databaseWithPath:fileName];
    [self.database open];
}

- (void)createTableWithSQLString:(NSString *)sqlString {
    [self.database executeUpdate:sqlString];
}

- (BOOL)insetTaskDataWithString:(NSString *)sqlString {
    return [self.database executeUpdate:sqlString];
}

- (NSArray *)queryTaskDataWithString:(NSString *)sqlString {
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [self.database executeQuery:sqlString];
    while ([set next]) {
        [arrM addObject:set.resultDictionary];
    }
    return arrM;
}

- (BOOL)deleteTaskDataWithString:(NSString *)sqlString {
    return [self.database executeUpdate:sqlString];
}

- (BOOL)modifyTaskDataWithString:(NSString *)sqlString {
    return [self.database executeUpdate:sqlString];
}


@end
