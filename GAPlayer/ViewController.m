//
//  ViewController.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/13.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "ViewController.h"
#import "GAPlayerView.h"

@interface ViewController ()

@property (nonatomic, strong) GAPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self playPlayerView];
}


- (void)playPlayerView {
    self.playerView = [[GAPlayerView alloc] init];
    self.playerView.frame = CGRectMake(0, 0, 375, 375.0/16*9);
    [self.playerView registerLandscapeCallBack:^(UIInterfaceOrientation deviceOrientation, UIInterfaceOrientation statusBarOrientation) {
        if (deviceOrientation == UIInterfaceOrientationPortrait) {
            self.playerView.isFullScreen = NO;
            self.playerView.frame = CGRectMake(0, 20, 375, 375.0/16*9);
        } else {
            self.playerView.isFullScreen = YES;
            self.playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width /16.0*9, [UIScreen mainScreen].bounds.size.width);
        }
    }];
    [self.view addSubview:self.playerView];
    //    NSString *jsonString = @"{\"hasVideoTitle\":\"前言\",\"isDrag\":1,\"lectureID\":6737,\"isOnline\":1,\"scheme\":\"sd|cif|hd\",\"video\":{\"cif\":\"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8\",\"hd\":\"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8\",\"sd\":\"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8\"},\"beginingAdUrl\": \"http://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4\",\"endingAdUrl\": \"http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4\"}";
    NSString *jsonString = @"{\"hasVideoTitle\":\"前言\",\"isDrag\":1,\"lectureID\":6737,\"isOnline\":1,\"scheme\":\"sd|cif|hd\",\"video\":{\"cif\":\"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8\",\"hd\":\"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8\",\"sd\":\"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8\"},\"beginingAdUrl\": \"\",\"endingAdUrl\": \"http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4\"}";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    [self.playerView thePlayerLoadsTheData:dic];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
