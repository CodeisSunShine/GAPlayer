//
//  GAPlayerDetailViewController.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerDetailViewController.h"
#import "GAPlayerDetailViewModel.h"
#import "GAPlayerDetailTableView.h"
#import "DownloadError.h"
#import "GAPlayerView.h"
#import "GACacheManager.h"
#import "GACacheModelTool.h"
#import "GADataBaseManager.h"
#import "GAPlayerDetailModel.h"

@interface GAPlayerDetailViewController ()
// 播放器
@property (nonatomic, strong) GAPlayerView *playerView;
// viewModel
@property (nonatomic, strong) GAPlayerDetailViewModel *viewModel;
// tableView
@property (nonatomic, strong) GAPlayerDetailTableView *tableView;

@end

@implementation GAPlayerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupView];
    [self setupLayout];
    [self setupData];
    [self setupPlayerViewaAction];
    [self makeProgressTableViewBlock];
    NSLog(@"home dir is %@",NSHomeDirectory());
}

- (void)setupView {
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.tableView];
}

- (void)setupLayout {
    __weak __typeof(self) weakself= self;
    self.playerView.frame = CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenWidth / 16.0 * 9 + StatusBarHeight);
    
    //增加横竖屏回调
    [self.playerView registerLandscapeCallBack:^(UIInterfaceOrientation deviceOrientation, UIInterfaceOrientation statusBarOrientation) {
        if (deviceOrientation == UIInterfaceOrientationPortrait) {
            weakself.playerView.isFullScreen = NO;
            weakself.playerView.frame =  CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenWidth / 16.0 * 9 + StatusBarHeight);
        } else {
            weakself.playerView.isFullScreen = YES;
            weakself.playerView.frame = CGRectMake(0, StatusBarHeight, ScreenHeight, ScreenWidth - StatusBarHeight * 2);
            NSLog(@"StatusBarHeight%f",StatusBarHeight);
        }
    }];
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.playerView.frame), ScreenWidth, ScreenHeight - CGRectGetMaxY(self.playerView.frame) - BottomSafeAreaHeight);
    
}

- (void)setupData {
    __weak __typeof(self) weakself= self;
    [self.viewModel requestPlayerDetailData:nil successBlock:^(BOOL success, id  _Nonnull object) {
        [weakself.tableView setObject:object];
        GAPlayerDetailModel *detailModel = [weakself.viewModel getDetailModelWithVideoId:weakself.listModel.videoId];
        [weakself.tableView changLectureWith:detailModel];
        [weakself.playerView thePlayerLoadsTheData:detailModel.playDict];
    }];
    
}

#pragma mark - tableview
// tableview 的操作回调
- (void)makeProgressTableViewBlock {
    __weak __typeof(self) weakself= self;
    self.tableView.actionBlock = ^(GAPlayerDetailModel *detailModel, PlayerDetailActionType actionType) {
        if (actionType == kPDActionTypeSelect) {
            
        } else if (actionType == kPDActionTypePlay) {
            if (weakself.playerView.isPlay) {
                [weakself.playerView pausePlayer];
            } else {
                [weakself.playerView playPlayer];
            }
        } else if (actionType == kPDActionTypeDonwload) {
            [weakself.viewModel downloadTaskWith:detailModel];
        }
    };
}

#pragma mark - player
// 播放器 的操作回调
- (void)setupPlayerViewaAction {
    __weak __typeof(self) weakself= self;
    self.playerView.viewActionBlock = ^(PlayerViewActionType controlBarType, NSString *videoId) {
        if (controlBarType == kPVActionTypeBack) {
            [weakself dismissViewControllerAnimated:YES completion:nil];
        } else if (controlBarType == kPVActionTypePlay) {
            GAPlayerDetailModel *playerModel = [weakself.viewModel getDetailModelWithVideoId:videoId];
            [weakself.tableView changLectureWith:playerModel];
        }
    };
}

//- (NSDictionary *)makeProgressLocalDataDict {
//    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
//    dataDict[@"hasVideoTitle"] = self.listModel.videoName;
//    dataDict[@"lectureID"] = self.listModel.videoId;
//
//    NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] init];
//    dataDict[@"scheme"] = @"sd"; // 清晰度标识
//    videoDict[@"sd"] = [NSString stringWithFormat:@"%@%@/%@",kLocalPlayURL,self.cacheModel.filePath,self.listModel.videoName];
//    dataDict[@"isOnline"] = @"0";// 本地播放
//    // 播放地址数据
//    dataDict[@"video"] = [videoDict copy];
//    return [dataDict copy];
//}

- (BOOL)shouldAutorotate {
    return NO;
}

- (GAPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[GAPlayerView alloc] init];
    }
    return _playerView;
}

- (GAPlayerDetailViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GAPlayerDetailViewModel alloc] init];
    }
    return _viewModel;
}

- (GAPlayerDetailTableView *)tableView {
    if (!_tableView) {
        _tableView = [[GAPlayerDetailTableView alloc] init];
    }
    return _tableView;
}

- (void)dealloc {
    [self.playerView stopPlayerView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
