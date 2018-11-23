//
//  GAPlayerDetailViewModel.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerDetailViewModel.h"
#import "GAPlayerDetailModel.h"
#import "GAPlayerDetailCellModel.h"

#import "GACacheManager.h"
#import "GACacheModelTool.h"
#import "GADataBaseManager.h"

@interface GAPlayerDetailViewModel ()

// 缓存器
@property (nonatomic, strong) GACacheManager *cacheManager;

@property (nonatomic, strong) GACacheModel *cacheModel;
// 缓存数据库
@property (nonatomic, strong) GADataBaseManager *dataBaseManager;

@property (nonatomic, strong) NSMutableArray *playerDetailList;

@end

@implementation GAPlayerDetailViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self addDownloadCallBack];
    }
    return self;
}

- (void)requestPlayerDetailData:(NSDictionary *)dict successBlock:(void (^)(BOOL success, id object))successBlock {
    [self makeProgressData];
    [self matchingDownloadState];
    successBlock(YES,self.playerDetailList);
}

- (void)matchingDownloadState {
    __weak __typeof(self) weakself= self;
    [self.dataBaseManager queryTaskData:nil resultBlock:^(BOOL success, id object) {
        if (success) {
            NSArray *databaseList = object;
            for (NSInteger i = 0; i < databaseList.count; i++) {
                [weakself makeProgressDownloadDataWith:databaseList[i]];
            }
        }
    }];
}

- (void)makeProgressDownloadDataWith:(NSDictionary *)dict {
    [self.playerDetailList enumerateObjectsUsingBlock:^(GAPlayerDetailModel *detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([dict[@"videoId"] isEqualToString:detailModel.videoId]) {
            if (dict[@"downloadState"]) {
                detailModel.downloadState = [dict[@"downloadState"] integerValue];
                if (detailModel.downloadState == kDADownloadStateCompleted) {
                    detailModel.localUrl = dict[@"videoId"];
                }
            } else {
                detailModel.downloadState = kDADownloadStateReady;
            }
            
            *stop = YES;
        }
    }];
}

#pragma mark - 下载
- (void)addDownloadCallBack {
    __weak __typeof(self) weakself= self;
    [self.cacheManager addProgressBlock:^(NSString *downloadId, NSString *progress, int64_t speed) {
        GAPlayerDetailModel *detailModel = [weakself getPlayerDetailModelWith:downloadId];
        if (detailModel) {
            detailModel.percentage = [progress floatValue];
            detailModel.speed = speed;
        }
    } downloadStateBlock:^(NSString *downloadId, NSInteger downloadState) {
        GAPlayerDetailModel *detailModel = [weakself getPlayerDetailModelWith:downloadId];
        if (detailModel) {
            detailModel.downloadState = downloadState;
        }
    } finishBlock:^(NSString *downloadId, BOOL success, NSError *error) {
        GAPlayerDetailModel *detailModel = [weakself getPlayerDetailModelWith:downloadId];
        if (detailModel) {
            if (success) {
                detailModel.downloadState = kDADownloadStateCompleted;
            } else {
                detailModel.downloadState = kDADownloadStateFailed;
            }
        }
    } idClass:@"GAPlayerDetailViewModel"];
}

- (void)downloadTaskWith:(GAPlayerDetailModel *)detailModel {
    NSDictionary *dict = [self makeProgressDownloadDictWith:detailModel];
    [self.cacheManager addDownloadWith:dict callBlock:^(BOOL success, id object) {
        if (success) {
            NSLog(@"成功进入下载逻辑");
        } else {
            NSLog(@"下载失败  %@",object);
        }
    }];
}

- (NSDictionary *)makeProgressDownloadDictWith:(GAPlayerDetailModel *)detailModel {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"videoId"] = detailModel.videoId;
    dict[@"videoName"] = detailModel.videoName;
    dict[@"videoUrl"] = detailModel.videoUrl;
    return [dict copy];
}

- (GAPlayerDetailModel *)getPlayerDetailModelWith:(NSString *)videoId {
    __block GAPlayerDetailModel *currentDetailModel;
    if (videoId && videoId.length > 0) {
        [self.playerDetailList enumerateObjectsUsingBlock:^(GAPlayerDetailModel *detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([detailModel.videoId isEqualToString:videoId]) {
                currentDetailModel = detailModel;
            }
        }];
    }
    return currentDetailModel;
}

- (GAPlayerDetailModel *)getDetailModelWithVideoId:(NSString *)videoId {
    __block GAPlayerDetailModel *currentDetailModel;
    [self.playerDetailList enumerateObjectsUsingBlock:^(GAPlayerDetailModel *detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([detailModel.videoId isEqualToString:videoId]) {
            currentDetailModel = detailModel;
            *stop = YES;
        }
    }];
    return currentDetailModel;
}

#pragma mark - 假数据赋值
- (void)makeProgressData {
    NSArray *names = @[@"SunShine.m3u8",@"AppleDemo.m3u8",@"Love.mp4",@"sad.mp4"];
    NSArray *ids = @[@"111",@"222",@"333",@"444"];
    NSArray *urls = @[@"http://cache.utovr.com/201508270528174780.m3u8",@"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8",@"http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4",@"http://lzaiuw.changba.com/userdata/video/940071102.mp4"];
    self.playerDetailList = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < names.count; i++) {
        GAPlayerDetailModel *detailModel = [[GAPlayerDetailModel alloc] init];
        detailModel.videoName = names[i];
        detailModel.videoId = ids[i];
        detailModel.videoUrl = urls[i];
        
        NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
        parameter[@"videoId"] = detailModel.videoId;
        [self.dataBaseManager queryTaskData:parameter resultBlock:^(BOOL success, id object) {
            NSDictionary *dict = (NSDictionary *)object;
            if (dict[@"downloadState"]) {
                detailModel.downloadState = [dict[@"downloadState"] integerValue];
            } else {
                detailModel.downloadState = kDADownloadStateReady;
            }
            detailModel.localUrl = dict[@"filePath"];
            detailModel.percentage = [dict[@"percent"] floatValue];
        }];
        
        [self makeProgressPlayData:detailModel];
        [self.playerDetailList addObject:detailModel];
    }
}

- (void)makeProgressPlayData:(GAPlayerDetailModel *)detailModel {
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    dataDict[@"hasVideoTitle"] = detailModel.videoName;
    dataDict[@"lectureID"] = detailModel.videoId;
    
    NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] init];
    if ([detailModel.videoId isEqualToString:@"222"]) {
        dataDict[@"scheme"] = @"sd|cif|hd"; // 清晰度标识
        
        videoDict[@"sd"] = @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8";
        videoDict[@"cif"] = @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8";
        videoDict[@"hd"] = @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8";
        
        // 头部广告
        dataDict[@"beginingAdUrl"] = @"http://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4";
        // 尾部广告
        dataDict[@"endingAdUrl"] = @"http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4";
    } else {
        dataDict[@"scheme"] = @"sd"; // 清晰度标识
        videoDict[@"sd"] = detailModel.videoUrl;
    }
    
    dataDict[@"isOnline"] = @"1";// 在线播放
    
    if (detailModel.downloadState == kDADownloadStateCompleted) {
        dataDict[@"scheme"] = @"sd"; // 清晰度标识
        videoDict[@"sd"] = detailModel.localUrl;
        dataDict[@"isOnline"] = @"0";
    }
    
    // 播放地址数据
    dataDict[@"video"] = [videoDict copy];
    detailModel.playDict = dataDict;
}

- (GACacheManager *)cacheManager {
    if (!_cacheManager) {
        _cacheManager = [[GACacheManager alloc] init];
    }
    return _cacheManager;
}

- (GADataBaseManager *)dataBaseManager {
    if (!_dataBaseManager) {
        _dataBaseManager = [GADataBaseManager sharedInstance];
    }
    return _dataBaseManager;
}

- (void)dealloc
{
    [self.cacheManager removeDonwloadBlcokWithIdClass:@"GAPlayerDetailViewModel"];
}

@end
