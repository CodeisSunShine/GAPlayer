//
//  ViewController.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/13.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "ViewController.h"
#import "GAPlayerView.h"
#import "DADonwloadHandle.h"
#import "DADownloadModel.h"
#import "DownloadError.h"

@interface ViewController ()

@property (nonatomic, strong) GAPlayerView *playerView;

@property (nonatomic, strong) id <DonwloadServiceProtocol> downloader;

@property (nonatomic, strong) UIButton *donwloadButton;

@property (nonatomic, strong) UIButton *playLocalButton;

@property (nonatomic, assign) BOOL isDownloading;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupLayout];
    [self play];
}

- (void)setupView {
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.donwloadButton];
    [self.view addSubview:self.playLocalButton];
}

- (void)setupLayout {
    self.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 16.0 * 9);
    [self.playerView registerLandscapeCallBack:^(UIInterfaceOrientation deviceOrientation, UIInterfaceOrientation statusBarOrientation) {
        if (deviceOrientation == UIInterfaceOrientationPortrait) {
            self.playerView.isFullScreen = NO;
            self.playerView.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_WIDTH / 16*9);
        } else {
            self.playerView.isFullScreen = YES;
            self.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH / 16.0*9, SCREEN_WIDTH);
        }
    }];
    self.donwloadButton.frame = CGRectMake(50, CGRectGetMaxY(self.playerView.frame) + 100, 120, 30);
    self.playLocalButton.frame = CGRectMake(SCREEN_WIDTH - 50 - 120, CGRectGetMaxY(self.playerView.frame) + 100, 120, 30);
}

- (void)play {
    [self.playerView thePlayerLoadsTheData:[self makeProgressDataDict]];
}

- (void)downloadClick {
    if (!self.isDownloading) {
        [self startDownload];
    } else {
        [self pauseDownload];
    }
}

- (void)startDownload {
    if (!self.downloader) {
        DADonwloadHandle *handle = [[DADonwloadHandle alloc] init];
        __weak typeof(self)weakSelf = self;
        [handle downloadWithDownloadUrls:@[@"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8"] andLocalUrl:@"downloads" downloadId:@"6737" andAnalysisURLBlock:^(BOOL success, id<DonwloadServiceProtocol> downloader, DownloadError *error) {
            if (success) {
                weakSelf.downloader = downloader;
                weakSelf.downloader.sessionDelegate = weakSelf;
                [weakSelf.downloader start];
            }
        }];
    } else {
        [self.downloader start];
    }
}

- (void)pauseDownload {
    [self.downloader pauseDownload];
}

- (void)playLocalClick {
    
}

#pragma mark - delegate
//开始下载将下载进度传出
- (void)sessionDownloadProgressWithDownloadModel:(DADownloadModel *)downloadModel {
    [self.donwloadButton setTitle:[NSString stringWithFormat:@"%@",downloadModel.progress] forState:UIControlStateNormal];
}

//下载结束
- (void)sessionDownloadFailureWithDownloadModel:(DADownloadModel *)downloadModel downloadError:(DownloadError *)error {
    if (error.finishCode == kDADownloadFinishCodeSuccess) {
        [self.donwloadButton setTitle:@"下载完成" forState:UIControlStateNormal];
        self.playLocalButton.userInteractionEnabled = YES;
    } else {
        [self.donwloadButton setTitle:@"下载失败" forState:UIControlStateNormal];
    }
}

- (NSDictionary *)makeProgressDataDict {
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    dataDict[@"hasVideoTitle"] = @"测试";
    dataDict[@"lectureID"] = @"6737";
    dataDict[@"scheme"] = @"sd|cif|hd"; // 清晰度标识
    
    NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] init];
    videoDict[@"sd"] = @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8";
    videoDict[@"cif"] = @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8";
    videoDict[@"hd"] = @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8";
    // 播放地址数据
    dataDict[@"video"] = [videoDict copy];
    // 头部广告
    dataDict[@"beginingAdUrl"] = @"http://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4";
    // 尾部广告
    dataDict[@"endingAdUrl"] = @"http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4";
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
        _playLocalButton.userInteractionEnabled = NO;
    }
    return _playLocalButton;
}



@end
