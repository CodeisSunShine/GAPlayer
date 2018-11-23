//
//  GAHomeListViewController.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/17.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAHomeListViewController.h"
#import "GAPlayerDetailViewController.h"
#import "GAHomeListTableViewCell.h"
#import "GAHomeListModel.h"

@interface GAHomeListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIButton *donwloadButton;

@end

@implementation GAHomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    [self setupLayout];
    [self setupData];
    [self.tableView reloadData];
    self.view.backgroundColor = kMyColor(247, 249, 251);
    self.title = @"视频列表";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.donwloadButton];
}

- (void)setupLayout {
    self.tableView.frame = CGRectMake(0,StatusBarHeight + NavBarHeight + 20, ScreenWidth, ScreenHeight - StatusBarHeight - NavBarHeight - 44 - 20);
    self.donwloadButton.frame = CGRectMake(0, ScreenHeight - 44 - BottomSafeAreaHeight, ScreenWidth, 44);
}

- (void)setupData {
    NSArray *names = @[@"SunShine.m3u8",@"AppleDemo.m3u8",@"Love.mp4",@"sad.mp4"];
    NSArray *ids = @[@"111",@"222",@"333",@"444"];
    NSArray *images = @[@"Sunshine",@"Apple",@"Love",@"Sad"];
    NSArray *describes = @[@"单独的m3u8视频",@"片头+m3u8视频+片尾",@"mp4视频",@"mp4视频"];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < names.count; i++) {
        GAHomeListModel *listModel = [[GAHomeListModel alloc] init];
        listModel.videoName = names[i];
        listModel.videoId = ids[i];
        listModel.videoImage = images[i];
        listModel.videoDescribe = describes[i];
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
    GAHomeListTableViewCell * cell = [GAHomeListTableViewCell cellWithTableView:tableView];
    if (self.dataSource.count > indexPath.row) {
        GAHomeListModel *listModel = self.dataSource[indexPath.row];
        cell.isHideLine = indexPath.row == self.dataSource.count - 1;
        [cell setObject:listModel];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GAHomeListModel *listModel = self.dataSource[indexPath.row];
    GAPlayerDetailViewController *playerDetailVC = [[GAPlayerDetailViewController alloc] init];
    playerDetailVC.listModel = listModel;
    [self presentViewController:playerDetailVC animated:YES completion:nil];
}

- (void)jumpToDownloadList {
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 90.0;
        UIView *view = [[UIView alloc] init];
        view.backgroundColor        = [UIColor clearColor];
        _tableView.tableFooterView  = view;
        _tableView.backgroundColor  = kMyColor(247, 249, 251);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIButton *)donwloadButton {
    if (!_donwloadButton) {
        _donwloadButton = [[UIButton alloc] init];
        [_donwloadButton setTitle:@"下载列表" forState:UIControlStateNormal];
        [_donwloadButton addTarget:self action:@selector(jumpToDownloadList) forControlEvents:UIControlEventTouchUpInside];
        _donwloadButton.backgroundColor = kMyColor(253, 141, 63);
    }
    return _donwloadButton;
}

@end
