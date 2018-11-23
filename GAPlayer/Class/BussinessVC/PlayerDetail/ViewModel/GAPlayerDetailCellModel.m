//
//  GAPlayerDetailCellModel.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerDetailCellModel.h"
#import "GAPlayerDetailModel.h"
#import "NSObject+FBKVOController.h"

@interface GAPlayerDetailCellModel ()

@end

@implementation GAPlayerDetailCellModel


- (void)setObject:(id)object {
    if (object && [object isKindOfClass:[GAPlayerDetailModel class]]) {
        self.detailModel = object;
        [self removeObserver];
        [self addObserver];
        [self makeProgressPlayImage];
        [self makeProgressCourseName];
        [self makeProgressDownloadState];
        [self makeProgressPercentage];
        [self makeProgressFrame];
        [self makeProgressDownloadFrame];
    }
}

- (void)makeProgressPlayImage {
    self.playImageName = self.isCurrentSelect ? @"course_pause_normal" : @"course_play_normal";
}

- (void)makeProgressCourseName {
    self.courseNmae = self.detailModel.videoName;
}

- (void)makeProgressDownloadState {
    self.progressHide = YES;
    switch (self.downloadState) {
        case kDADownloadStateReady:
            self.downloadImageNmae = @"download_none_normal";
            self.stateName = @"未下载";
            self.stateColor = kMyColor(102, 217, 159);
            break;
        case kDADownloadStateDownloading:
            self.downloadImageNmae = @"downloadLoading_state_normal";
            self.stateName = @"下载中";
            self.progressHide = NO;
            [self makeProgressPercentage];
            self.stateColor = kMyColor(255, 98, 134);
            break;
        case kDADownloadStateCompleted:
            self.downloadImageNmae = @"download_success_normal";
            self.stateName = @"已离线";
            self.stateColor = kMyColor(151, 161, 170);
            break;
        case kDADownloadStateCancelled:
            self.downloadImageNmae = @"download_pause_normal";
            self.stateName = @"暂停中";
            self.stateColor = kMyColor(85, 172, 238);
            break;
        case kDADownloadStateFailed:
            self.downloadImageNmae = @"download_fail_normal";
            self.stateName = @"下载失败";
            self.stateColor = kMyColor(249, 130, 11);
            break;
        case kDADownloadStateWait:
            self.downloadImageNmae = @"download_wait_normal";
            self.stateName = @"等待下载";
            self.stateColor = kMyColor(85, 172, 238);
            break;
        default:
            self.downloadImageNmae = @"download_pause_normal";
            self.stateName = @"暂停中";
            self.stateColor = kMyColor(85, 172, 238);
            break;
    }
}

- (void)makeProgressPercentage {
    NSString *percentStr;
    if (self.detailModel.percentage > 0) {
        percentStr = [NSString stringWithFormat:@"%.f%%",self.detailModel.percentage * 100.0];
    } else {
        percentStr = @"0%";
    }
    self.percentStr = percentStr;
    [self makeProgressDownloadFrame];
}

- (void)makeProgressFrame {
    CGFloat playDistance = 15;
    CGFloat playButtonWidth = 30;
    self.playButtonF = CGRectMake(playDistance, 0, playButtonWidth, playButtonWidth);
    
    CGFloat downloadWidth = 60;
    CGFloat downloadDistance = 10;
    
    CGFloat maxTitleWidth = ScreenWidth - playDistance * 2 - playButtonWidth - downloadWidth - 2 * downloadDistance;
    self.courseLabelF = CGRectMake(CGRectGetMaxX(self.playButtonF) + playDistance, 15, maxTitleWidth, 30);
    
     self.progressViewF = CGRectMake(playDistance, 65, ScreenWidth - playDistance * 2 - downloadWidth - downloadDistance, 15);
    
    self.cellHigh = CGRectGetMaxY(self.progressViewF) + 15;
    self.lineF = CGRectMake(0, self.cellHigh - 0.5, ScreenWidth, 0.5);
    
    self.playButtonF = CGRectMake(playDistance, 15, playButtonWidth, playButtonWidth);
   
}

- (void)makeProgressDownloadFrame {
    CGFloat downloadWidth = 60;
    CGFloat downloadDistance = 10;
    self.stateButtonF = CGRectMake(ScreenWidth - downloadWidth - downloadDistance, 0, downloadWidth, self.cellHigh);
    if (self.progressHide) {
        self.downloadStateViewF = CGRectMake((downloadWidth - 20) * 0.5, (self.cellHigh - 5  - 20 - 6) * 0.5, 20, 18);
        self.stateLabelF = CGRectMake(0, CGRectGetMaxY(self.downloadStateViewF) + 5, downloadWidth, 20);
    } else {
        self.progressLabelF = CGRectMake((downloadWidth - 20) * 0.5, (self.cellHigh - 5  - 20 - 6  - 5) * 0.5, 20, 10);
        self.downloadStateViewF = CGRectMake((downloadWidth - 20) * 0.5, CGRectGetMaxY(self.progressLabelF) - 5, 20, 18);
        self.stateLabelF = CGRectMake(0, CGRectGetMaxY(self.downloadStateViewF) + 5, downloadWidth, 20);
    }
}

- (void)addObserver {
    NSLog(@"添加监听");
    __weak __typeof(self) weakself= self;
    [self.KVOController observe:self.detailModel keyPath:@"downloadState" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(NSObject *observer, GAPlayerDetailModel *detailModel, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        weakself.downloadState = [change[NSKeyValueChangeNewKey] integerValue];
        [weakself makeProgressDownloadState];
        if (weakself.downloadStateBlock) {
            weakself.downloadStateBlock();
        }
    }];
    
    [self.KVOController observe:self.detailModel keyPath:@"percentage" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(NSObject *observer, GAPlayerDetailModel *detailModel, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        CGFloat progress = [change[NSKeyValueChangeNewKey] floatValue];
        if (weakself.downloadState == kDADownloadStateCompleted) {
            return;
        }
        if (weakself.progress <= progress) {
            weakself.progress = progress;
            [weakself makeProgressPercentage];
            if (weakself.downloadProgressBlock) {
                weakself.downloadProgressBlock();
            }
        }
    }];
    
    [self.KVOController observe:self.detailModel keyPath:@"speed" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(NSObject *observer, GAPlayerDetailModel *detailModel, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        weakself.speed = [NSString stringWithFormat:@"%@",change[NSKeyValueChangeNewKey]];
        if (weakself.downloadSpeedBlock) {
            weakself.downloadSpeedBlock();
        }
    }];
    
}

- (void)setIsCurrentSelect:(BOOL)isCurrentSelect {
    _isCurrentSelect = isCurrentSelect;
    [self makeProgressPlayImage];
    if (self.playImageBlcok) {
        self.playImageBlcok();
    }
}

- (void)removeObserver {
    NSLog(@"删除监听");
    [self.KVOController unobserve:self.detailModel keyPath:@"downloadState"];
    [self.KVOController unobserve:self.detailModel keyPath:@"percentage"];
    [self.KVOController unobserve:self.detailModel keyPath:@"speed"];
}

- (void)dealloc {
    [self removeObserver];
}

@end
