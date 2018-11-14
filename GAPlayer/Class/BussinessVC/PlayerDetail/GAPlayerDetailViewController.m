//
//  GAPlayerDetailViewController.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerDetailViewController.h"
#import "DADonwloadHandle.h"
#import "DADownloadModel.h"
#import "DownloadError.h"
#import "GAPlayerView.h"
#import "GACacheManager.h"
#import "GACacheModelTool.h"
#import "GADataBaseManager.h"

@interface GAPlayerDetailViewController ()

@property (nonatomic, strong) GAPlayerView *playerView;

@property (nonatomic, strong) GACacheManager *cacheManager;

@property (nonatomic, strong) UIButton *donwloadButton;

@property (nonatomic, strong) UIButton *playLocalButton;

@property (nonatomic, strong) UIButton *playLineButton;

@property (nonatomic, strong) GACacheModel *cacheModel;

// 缓存数据库
@property (nonatomic, strong) GADataBaseManager *dataBaseManager;

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
    [self addDownloadCallBack];
    NSLog(@"home dir is %@",NSHomeDirectory());
}

- (void)setupView {
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.playLineButton];
    [self.view addSubview:self.donwloadButton];
    [self.view addSubview:self.playLocalButton];
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
    
    
    self.donwloadButton.frame = CGRectMake(50, CGRectGetMaxY(self.playerView.frame) + 100, 120, 30);
    self.playLocalButton.frame = CGRectMake(ScreenWidth - 50 - 120, CGRectGetMaxY(self.playerView.frame) + 100, 120, 30);
    self.playLineButton.frame = CGRectMake(ScreenWidth - 50 - 120, CGRectGetMaxY(self.playLocalButton.frame) + 50, 120, 30);
}

- (void)setupData {
    __weak __typeof(self) weakself= self;
    NSDictionary *dict = @{@"videoId":self.listModel.videoId};
    [self.dataBaseManager queryTaskData:dict resultBlock:^(BOOL success, id object) {
        if (success && object) {
            [weakself makeProgressAddNewCacheModel:object];
        }
    }];
}

- (void)makeProgressAddNewCacheModel:(NSDictionary *)dataDict  {
    __weak __typeof(self) weakself= self;
    [GACacheModelTool makeProgressCacheModelWith:dataDict callBlock:^(BOOL success, id object) {
        if (success) {
            weakself.cacheModel = (GACacheModel *)object;
            [weakself reloadDownloadButton];
        } else {
        }
    }];
}

- (void)setupPlayerViewaAction {
    __weak __typeof(self) weakself= self;
    self.playerView.viewActionBlock = ^(PlayerViewActionType controlBarType, NSString *videoId) {
        if (controlBarType == kPVActionTypeBack) {
            [weakself dismissViewControllerAnimated:YES completion:nil];
        }
    };
}

- (void)addDownloadCallBack {
    __weak __typeof(self) weakself= self;
    [self.cacheManager addProgressBlock:^(NSString *downloadId, NSString *progress, int64_t speed) {
        
    } downloadStateBlock:^(NSString *downloadId, NSInteger downloadState) {
        if ([downloadId isEqualToString:weakself.listModel.videoId]) {
            weakself.cacheModel.downloadState = downloadState;
            [weakself reloadDownloadButton];
        }
    } finishBlock:^(NSString *downloadId, BOOL success, NSError *error) {
        if ([downloadId isEqualToString:weakself.listModel.videoId]) {
            if (success) {
                weakself.cacheModel.downloadState = kDADownloadStateCompleted;
            } else {
                weakself.cacheModel.downloadState = kDADownloadStateFailed;
            }
            [weakself reloadDownloadButton];
        }
    } idClass:@"GAPlayerDetailViewController"];
}

- (void)reloadDownloadButton {
    if (self.cacheModel) {
        [self.donwloadButton setTitle:[GACacheModelTool makeProgressDownloadStateStringWith:self.cacheModel.downloadState] forState:UIControlStateNormal];
    }
}

- (void)playLocalClick {
    if (self.cacheModel && self.cacheModel.downloadState == kDADownloadStateCompleted) {
        [self.playerView thePlayerLoadsTheData:[self makeProgressLocalDataDict]];
    } else {
        NSLog(@"未下载完成");
    }
}

- (void)downloadClick {
    __weak __typeof(self) weakself= self;
    if (self.cacheModel) {
        [self.cacheManager downloadIsControlledAccordingToVideoId:self.cacheModel.videoId callBlock:^(BOOL success, id object) {
            
        }];
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"videoId"] = self.listModel.videoId;
        dict[@"videoName"] = self.listModel.videoName;
        dict[@"videoUrl"] = self.listModel.videoUrl;
        [self.cacheManager addDownloadWith:[dict copy] callBlock:^(BOOL success, id object) {
            if (success) {
                NSLog(@"成功进入下载逻辑");
                weakself.cacheModel = object;
            } else {
                NSLog(@"下载失败  %@",object);
            }
        }];
    }
}

- (void)playLineClick {
    [self.playerView thePlayerLoadsTheData:[self makeProgressLineDataDict]];
}

- (NSDictionary *)makeProgressLineDataDict {
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    dataDict[@"hasVideoTitle"] = self.listModel.videoName;
    dataDict[@"lectureID"] = self.listModel.videoId;
    
    NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] init];
    if ([self.listModel.videoId isEqualToString:@"222"]) {
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
        videoDict[@"sd"] = self.listModel.videoUrl;
    }
    dataDict[@"isOnline"] = @"1";// 在线播放
    
    // 播放地址数据
    dataDict[@"video"] = [videoDict copy];
    return [dataDict copy];
}


- (NSDictionary *)makeProgressLocalDataDict {
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    dataDict[@"hasVideoTitle"] = self.listModel.videoName;
    dataDict[@"lectureID"] = self.listModel.videoId;
    
    NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] init];
    dataDict[@"scheme"] = @"sd"; // 清晰度标识
    videoDict[@"sd"] = [NSString stringWithFormat:@"%@%@/%@",kLocalPlayURL,self.cacheModel.filePath,self.listModel.videoName];
    dataDict[@"isOnline"] = @"0";// 本地播放
    // 播放地址数据
    dataDict[@"video"] = [videoDict copy];
    return [dataDict copy];
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

- (UIButton *)donwloadButton {
    if (!_donwloadButton) {
        _donwloadButton = [[UIButton alloc] init];
        [_donwloadButton setTitle:@"下载" forState:UIControlStateNormal];
        [_donwloadButton addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
        _donwloadButton.backgroundColor = [UIColor grayColor];
        [_donwloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _donwloadButton;
}

- (UIButton *)playLocalButton {
    if (!_playLocalButton) {
        _playLocalButton = [[UIButton alloc] init];
        [_playLocalButton setTitle:@"播放本地视频" forState:UIControlStateNormal];
        [_playLocalButton addTarget:self action:@selector(playLocalClick) forControlEvents:UIControlEventTouchUpInside];
        _playLocalButton.backgroundColor = [UIColor grayColor];
        [_playLocalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _playLocalButton;
}

- (UIButton *)playLineButton {
    if (!_playLineButton) {
        _playLineButton = [[UIButton alloc] init];
        [_playLineButton setTitle:@"播放在线视频" forState:UIControlStateNormal];
        [_playLineButton addTarget:self action:@selector(playLineClick) forControlEvents:UIControlEventTouchUpInside];
        _playLineButton.backgroundColor = [UIColor grayColor];
        [_playLineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _playLineButton;
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

- (void)dealloc {
    [self.playerView stopPlayerView];
    [self.cacheManager removeDonwloadBlcokWithIdClass:@"GAPlayerDetailViewController"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
