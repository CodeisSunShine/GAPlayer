//
//  GAHomeListViewController.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAHomeListViewController.h"
#import "GAPlayerDetailViewController.h"
#import "GAHomeListModel.h"

@interface GAHomeListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation GAHomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    [self setupLayout];
    [self setupData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
}

- (void)setupLayout {
    self.tableView.frame = CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenHeight - StatusBarHeight);
}

- (void)setupData {
    NSArray *urls = @[@"http://cache.utovr.com/201508270528174780.m3u8",@"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8",@"http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4",@"http://lzaiuw.changba.com/userdata/video/940071102.mp4"];
    NSArray *names = @[@"SunShine.m3u8",@"AppleDemo.m3u8",@"Love.mp4",@"sad.mp4"];
    NSArray *ids = @[@"111",@"222",@"333",@"444"];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < urls.count; i++) {
        GAHomeListModel *listModel = [[GAHomeListModel alloc] init];
        listModel.videoUrl = urls[i];
        listModel.videoName = names[i];
        listModel.videoId = ids[i];
        [dataSource addObject:listModel];
    }
    self.dataSource = dataSource;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"UITableViewCell";
    GAHomeListModel *listModel = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        //这里使用系统自带的样式
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = listModel.videoName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GAHomeListModel *listModel = self.dataSource[indexPath.row];
    GAPlayerDetailViewController *playerDetailVC = [[GAPlayerDetailViewController alloc] init];
    playerDetailVC.listModel = listModel;
    [self presentViewController:playerDetailVC animated:YES completion:nil];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 44 ; //44为任意值
    }
    return _tableView;
}

@end
