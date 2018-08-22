//
//  GAPlayerViewModel.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerViewModel.h"
#import "GAPlayerSelectVIewModel.h"

@interface GAPlayerViewModel ()

@property (nonatomic, strong) NSArray *speedList;

@end

@implementation GAPlayerViewModel

- (void)thePlayerParsesTheData:(NSDictionary *)dataDict successBlock:(void(^)(BOOL success,id object))successBlock {
    if (dataDict) {
        [self makeProgressDataDict:dataDict successBlock:successBlock];
    } else {
        successBlock(NO,nil);
    }
}


- (void)makeProgressDataDict:(NSDictionary *)dataDict successBlock:(void(^)(BOOL success,id object))successBlock {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        GAPlayerItemModel *playerItemModel = [[GAPlayerItemModel alloc] init];
        playerItemModel.claritList = [self makeProgressClaritListWith:dataDict];
        playerItemModel.isDrag = dataDict[@"isDrag"];
        playerItemModel.isOnline = [dataDict[@"isOnline"] isEqualToString:@"1"];
        playerItemModel.hasVideoTitle = dataDict[@"hasVideoTitle"];
        playerItemModel.beginningAdUrl = dataDict[@"beginingAdUrl"];
        playerItemModel.endingAdUrl = dataDict[@"endingAdUrl"];
        if (playerItemModel.beginningAdUrl && playerItemModel.beginningAdUrl.length > 0) {
            playerItemModel.playUrlType = kPlayUrlTypeBeginAd;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (playerItemModel.claritList && playerItemModel.claritList.count > 0) {
                GAPlayerSelectVIewModel *selectVIewModel = playerItemModel.claritList[0];
                playerItemModel.currentClaritName = selectVIewModel.selectName;
                playerItemModel.currentClaritUrl = selectVIewModel.selectValue;
                playerItemModel.currentSpeed = @"1.0";
                successBlock(YES,playerItemModel);
            } else {
                successBlock(NO,nil);
            }
        });
    });
}

// 处理清晰度数组
- (NSArray *)makeProgressClaritListWith:(NSDictionary *)dataDict {
    NSString *scheme = dataDict[@"scheme"];
    NSDictionary *videoDict = dataDict[@"video"];
    NSArray *schemeClarit = [scheme componentsSeparatedByString:@"|"];
    NSMutableArray *claritList = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < schemeClarit.count; i++) {
        NSString *clarit = schemeClarit[i];
        NSString *playerUrl = videoDict[clarit];
        NSString *claritName = [self returnClaritName:clarit];
        GAPlayerSelectVIewModel *selectVIewModel = [self makeProgressSelectModelWith:claritName selectValue:playerUrl selectType:@"1"];
        if (selectVIewModel) {
            [claritList addObject:selectVIewModel];
        }
    }
    return claritList;
}

- (void)makeProgressSpeedList:(GAPlayerItemModel *)playerItemModel {
    if (playerItemModel.speedList && playerItemModel.speedList.count > 0) return;
    NSMutableArray *speedList = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.speedList.count; i++) {
        NSString *speed = self.speedList[i];
        GAPlayerSelectVIewModel *selectVIewModel = [self makeProgressSelectModelWith:speed selectValue:speed selectType:@"2"];
        [speedList addObject:selectVIewModel];
    }
    playerItemModel.speedList = speedList;
}


- (GAPlayerSelectVIewModel *)makeProgressSelectModelWith:(NSString *)selectName
                                             selectValue:(NSString *)selectValue
                                              selectType:(NSString *)selectType {
    if ((selectName && selectName.length > 0) && (selectValue && selectValue.length > 0)) {
        GAPlayerSelectVIewModel *selectVIewModel = [[GAPlayerSelectVIewModel alloc] init];
        selectVIewModel.selectName = selectName;
        selectVIewModel.selectValue = selectValue;
        selectVIewModel.selectType = selectType;
        return selectVIewModel;
    }
    return nil;
}

// 处理亮度改变的数据
- (CGFloat)makeProgressGestureBrightnessChange:(CGFloat)moveValue {
    CGFloat originBright = [UIScreen mainScreen].brightness;
    CGFloat difference;
    if (moveValue < 0) {
        difference = 0.02;
    } else {
        difference = -0.02;
    }
    CGFloat currentBright = [self makeProgressBrightness:difference originBright:originBright];
    return currentBright;
}

// 处理亮度
- (CGFloat)makeProgressBrightness:(CGFloat)moveValue originBright:(CGFloat)originBright {
    
    CGFloat currentBright = originBright;
    currentBright += moveValue;
    currentBright = currentBright > 1 ? 1 : currentBright;
    currentBright = currentBright < 0 ? 0 : currentBright;
    return currentBright;
}


// 处理音量改变的数据
- (CGFloat)makeProgressGestureVolumeChange:(CGFloat)moveValue {
    CGFloat volume = [MPMusicPlayerController applicationMusicPlayer].volume;
    return volume - moveValue / 1000;
}

// 处理进度改变的数据
- (CGFloat)makeProgressGestureProgressChange:(CGFloat)moveValue
                                currentWidth:(CGFloat)currentWidth
                                currentValue:(CGFloat)currentValue {
    return currentValue + moveValue / currentWidth;
}

// 处理当前播放地址
- (NSString *)makeProgressCurrentPlayerUrl:(GAPlayerItemModel *)playerItemModel {
    NSString *playerUrl = @"";
    if (playerItemModel.playUrlType == kPlayUrlTypeBody) {
        playerUrl = playerItemModel.currentClaritUrl;
    } else if (playerItemModel.playUrlType == kPlayUrlTypeBeginAd) {
        playerUrl = playerItemModel.beginningAdUrl;
    } else if (playerItemModel.playUrlType == kPlayUrlTypeEndAd) {
        playerUrl = playerItemModel.endingAdUrl;
    }
    return playerUrl;
}

// 判断是否有视频需要继续播放
- (BOOL)judgeVideoNeedContinueToPlayed:(GAPlayerItemModel *)playerItemModel {
    PlayUrlType playUrlType = playerItemModel.playUrlType;
    BOOL isContinue = NO;
    if (playUrlType == kPlayUrlTypeBeginAd) {
        if ([self judgeWhetherActiveAddress:playerItemModel.currentClaritUrl]) {
            playerItemModel.playUrlType = kPlayUrlTypeBody;
            isContinue = YES;
        } else {
            if ([self judgeWhetherActiveAddress:playerItemModel.endingAdUrl]) {
                playerItemModel.playUrlType = kPlayUrlTypeEndAd;
                isContinue = YES;
            }
        }
    } else if (playUrlType == kPlayUrlTypeBody) {
        if ([self judgeWhetherActiveAddress:playerItemModel.endingAdUrl]) {
            playerItemModel.playUrlType = kPlayUrlTypeEndAd;
            isContinue = YES;
        }
    }
    return isContinue;
}

// 判断播放地址是否有效
- (BOOL)judgeWhetherActiveAddress:(NSString *)playerUrl {
    if (playerUrl && playerUrl.length > 0) {
        return YES;
    }
    return NO;
}

- (NSString *)processAdCountdown:(NSTimeInterval)totalDuration currentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    NSString *countdown = [NSString stringWithFormat:@"倒计时(%.f)",totalDuration - currentPlaybackTime];
    return countdown;
}

// 根据对应的key值获取清晰度
- (NSString *)returnClaritName:(NSString *)claritKey {
    if ([claritKey isEqualToString:@"sd"]) {
        return @"流畅";
    } else if ([claritKey isEqualToString:@"cif"]) {
        return @"标清";
    } else if ([claritKey isEqualToString:@"hd"]) {
        return @"超清";
    }
    return @"";
}

- (GAPlayerModel *)makeProgressPlayerModelWith:(GAPlayerItemModel *)playerItemModel {
    GAPlayerModel *playerModel = [[GAPlayerModel alloc] init];
    playerModel.playURL = [self makeProgressCurrentPlayerUrl:playerItemModel];
    return playerModel;
}


- (NSArray *)speedList {
    if (!_speedList) {
        _speedList = @[@"1.0",@"1.2",@"1.5",@"1.8",@"11.0"];
    }
    return _speedList;
}

@end
