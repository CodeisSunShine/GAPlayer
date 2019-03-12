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
#import "GAPlayerDetailBoomView.h"

@interface GAPlayerDetailViewController ()
// 播放器
@property (nonatomic, strong) GAPlayerView *playerView;
// viewModel
@property (nonatomic, strong) GAPlayerDetailViewModel *viewModel;
// tableView
@property (nonatomic, strong) GAPlayerDetailTableView *tableView;
// tableView
@property (nonatomic, strong) GAPlayerDetailBoomView *boomView;


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
    [self reloadUnFinishAndFinishCount];
    NSLog(@"home dir is %@",NSHomeDirectory());
}

- (void)setupView {
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.boomView];
}

- (void)setupLayout {
    __weak __typeof__(self) weakSelf = self;
    self.playerView.frame = CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenWidth / 16.0 * 9 + StatusBarHeight);
    
    //增加横竖屏回调
    [self.playerView registerLandscapeCallBack:^(UIInterfaceOrientation deviceOrientation, UIInterfaceOrientation statusBarOrientation) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (deviceOrientation == UIInterfaceOrientationPortrait) {
            strongSelf.playerView.isFullScreen = NO;
            strongSelf.playerView.frame =  CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenWidth / 16.0 * 9 + StatusBarHeight);
        } else {
            CGFloat ditance = isIPhoneXAbove ? StatusBarHeight : 0;
            strongSelf.playerView.isFullScreen = YES;
            strongSelf.playerView.frame = CGRectMake(0, ditance, ScreenHeight, ScreenWidth - ditance * 2);
            NSLog(@"StatusBarHeight%f width = %f  high = %f",StatusBarHeight,ScreenHeight,ScreenWidth - ditance * 2);
        }
    }];
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.playerView.frame), ScreenWidth, ScreenHeight - CGRectGetMaxY(self.playerView.frame) - BottomSafeAreaHeight - 44);
    self.boomView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame), ScreenWidth, 44);
    
}

- (void)setupData {
    __weak __typeof(self) weakself= self;
    [self.viewModel requestPlayerDetailData:nil successBlock:^(BOOL success, id  _Nonnull object) {
        [weakself.tableView setObject:object];
        GAPlayerDetailModel *detailModel = [weakself.viewModel getPlayerDetailModelWith:weakself.listModel.videoId];
        NSDictionary *playDict = [weakself.viewModel makeProgressPlayData:detailModel];
        [weakself.tableView changLectureWith:detailModel isPlay:NO];
        [weakself.playerView thePlayerLoadsTheData:playDict];
    }];
    
}

- (void)reloadUnFinishAndFinishCount {
    __weak __typeof(self) weakself= self;
    [self.viewModel requestUnFinishAndFinishData:nil successBlock:^(NSInteger finishCount, NSInteger unFinishCount) {
        weakself.boomView.finishCount = finishCount;
        weakself.boomView.unFinishCount = unFinishCount;
    }];
}

#pragma mark - tableview
// tableview 的操作回调
- (void)makeProgressTableViewBlock {
    __weak __typeof(self) weakself= self;
    self.tableView.actionBlock = ^(GAPlayerDetailModel *detailModel, PlayerDetailActionType actionType) {
        if (actionType == kPDActionTypeChangeSource) {
            NSDictionary *playDict = [weakself.viewModel makeProgressPlayData:detailModel];
            [weakself.playerView thePlayerLoadsTheData:playDict];
        } else if (actionType == kPDActionTypeChangeState) {
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
            GAPlayerDetailModel *playerModel = [weakself.viewModel getPlayerDetailModelWith:videoId];
            [weakself.tableView changLectureWith:playerModel isPlay:YES];
        }
    };
    
    self.playerView.playFinishBlock = ^(NSString *videoId) {
        GAPlayerDetailModel *playerModel = [weakself.viewModel getPlayerDetailModelWith:videoId];
        [weakself.tableView changLectureWith:playerModel.nextDetailModel isPlay:NO];
    };
}

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

- (GAPlayerDetailBoomView *)boomView {
    if (!_boomView) {
        _boomView = [[GAPlayerDetailBoomView alloc] init];
    }
    return _boomView;
}

- (void)dealloc {
    [self.playerView stopPlayerView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
