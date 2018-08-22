//
//  DownloadMemory.m
//  DownloadVC
//
//  Created by 宫傲 on 2018/6/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "DownloadMemory.h"
#import "MemoryModel.h"
#include <sys/mount.h>
#include <sys/stat.h>

@interface DownloadMemory ()
// 缓存字典
@property (nonatomic, strong) NSMutableDictionary *memoryDict;
// 剩余内存
@property (nonatomic, assign) int64_t freeTotalSize;
// 已用内存
@property (nonatomic, assign) int64_t usedTotalSize;
// 定时器
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation DownloadMemory

- (instancetype)init {
    if (self = [super init]) {
        NSString * downloadFolder = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/downloads"];
        self.usedTotalSize = [self fileSizeAtPath:downloadFolder];
        [self createTimer];
    }
    return self;
}

- (void)makeProgressFileId:(NSString *)fielId bytesWritten:(int64_t)bytesWritten {
    MemoryModel *memoryModel = [self getMemoryWithFileId:fielId];
    memoryModel.bytesWritten = memoryModel.bytesWritten + bytesWritten;
    self.usedTotalSize = self.usedTotalSize + bytesWritten;
    if (self.sizeBlock) {
        self.sizeBlock(self.usedTotalSize, self.freeTotalSize);
    }
}

- (int64_t)getSpeedWithFileId:(NSString *)fielId {
    @synchronized(self) {
        MemoryModel *memoryModel = self.memoryDict[fielId];
        return memoryModel.downloadSpeed;
    }
}

// 根据 fielId 获取 MemoryModel
- (MemoryModel *)getMemoryWithFileId:(NSString *)fielId {
    MemoryModel *memoryModel = self.memoryDict[fielId];
    if (!memoryModel) {
        memoryModel = [[MemoryModel alloc] init];
        [self.memoryDict setObject:memoryModel forKey:fielId];
    }
    return memoryModel;
}

// 计算指定文件的大小
- (int64_t)fileSizeAtPath:(NSString *)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    int64_t folderSize = 0;
    if ([manager fileExistsAtPath:filePath]){
        NSFileManager* manager = [NSFileManager defaultManager];
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:filePath] objectEnumerator];
        NSString* fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [filePath stringByAppendingPathComponent:fileName];
            struct stat st;
            if(lstat([fileAbsolutePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
                folderSize += st.st_size;
            }
        }
    }
    return folderSize;
}

#pragma mark - 定时器
- (void)createTimer {
    [self deallocTimer];
    __weak __typeof(self)weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer,DISPATCH_TIME_NOW,1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(self.timer, ^{
        [weakSelf judageDownloadSpeed];
    });
    dispatch_resume(self.timer);
}

- (void)deallocTimer {
    if (self.timer) {
        self.timer = nil;
    }
}

// 计算下载速度
- (void)judageDownloadSpeed {
    __weak __typeof(self)weakSelf = self;
    [self.memoryDict.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        @synchronized(weakSelf) {
            MemoryModel *memoryModel = weakSelf.memoryDict[key];
            memoryModel.downloadSpeed = memoryModel.bytesWritten;
            memoryModel.bytesWritten = 0;
        }
    }];
}

- (NSMutableDictionary *)memoryDict {
    if (!_memoryDict) {
        _memoryDict = [[NSMutableDictionary alloc] init];
    }
    return _memoryDict;
}

- (void)dealloc {
    [self deallocTimer];
}

@end
