//
//  GADataBaseManager.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GADataBaseManager.h"
#import "GAFMDBTool.h"

@interface GADataBaseManager()

@property (nonatomic, strong) GAFMDBTool *fmdbTool;

@end

@implementation GADataBaseManager

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GADataBaseManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GADataBaseManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - DataBaseInterface
// 查询任务数据
- (void)queryTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock {
    NSArray *results = [self.fmdbTool queryTaskDataWithString:[self makeProgressQuerySql:dict]];
    if (results) {
        resultBlock(YES,results.firstObject);
    } else {
        resultBlock(NO,nil);
    }
}

// 查询未完成的下载的任务
- (void)queryTheUnfinishedDownloadData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock {
    [self.fmdbTool queryTaskDataWithString:[self makeProgressQueryUnfinishedSql]];
}

// 插入任务数据
- (void)insertTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock {
    BOOL success = [self.fmdbTool insetTaskDataWithString:[self makeProgressInsertSql:dict]];
    resultBlock(success,nil);
}

// 删除任务数据
- (void)removeTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock {
    
}

// 修改任务数据
- (void)modifyTaskData:(NSDictionary *)dict resultBlock:(void (^)(BOOL success, id object))resultBlock {
    BOOL success = [self.fmdbTool modifyTaskDataWithString:[self makeProgressModifySql:dict]];
    resultBlock(success,nil);
}

#pragma mark - private
- (NSString *)makeProgressCreateTableSql {
    return @"CREATE TABLE IF NOT EXISTS download(videoId INTEGER PRIMARY KEY, percent TEXT NOT NULL, filePath TEXT NOT NULL, videoName TEXT NOT NULL, videoUrl TEXT NOT NULL, downloadState TEXT NOT NULL);";
}

- (NSString *)makeProgressQuerySql:(NSDictionary *)dict {
    return [NSString stringWithFormat:@"SELECT * FROM download where videoId = '%ld'",[dict[@"videoId"] integerValue]];
}

- (NSString *)makeProgressQueryUnfinishedSql {
    return @"SELECT * FROM download where downloadState != '3'";
}

- (NSString *)makeProgressInsertSql:(NSDictionary *)dict {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO download(videoId, percent, filePath, videoName, videoUrl, downloadState) VALUES ('%ld', '%@', '%@', '%@', '%@', '%@');",  [dict[@"videoId"] integerValue],dict[@"percent"],dict[@"filePath"],dict[@"videoName"],dict[@"videoUrl"],dict[@"downloadState"]];
    return insertSql;
}

- (NSString *)makeProgressModifySql:(NSDictionary *)dict {
    NSString *modifySql = [NSString stringWithFormat:@"UPDATE download SET downloadState = '%@' WHERE videoId = '%ld'",dict[@"downloadState"],[dict[@"videoId"] integerValue]];
    return modifySql;
}

- (GAFMDBTool *)fmdbTool {
    if (!_fmdbTool) {
        _fmdbTool = [[GAFMDBTool alloc] init];
        [_fmdbTool createTableWithSQLString:[self makeProgressCreateTableSql]];
    }
    return _fmdbTool;
}

@end
