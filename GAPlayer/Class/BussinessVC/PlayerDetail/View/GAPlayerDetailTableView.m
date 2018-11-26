//
//  GAPlayerDetailTableView.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerDetailTableView.h"
#import "GAPlayerDetailTableViewCell.h"
#import "GAPlayerDetailCellModel.h"
#import "GAPlayerDetailModel.h"

@interface GAPlayerDetailTableView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) GAPlayerDetailCellModel *currentCellVModel;

@end

@implementation GAPlayerDetailTableView

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.tableView];
}

- (void)setupLayout {
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setObject:(id)object {
    if (object && [object isKindOfClass:[NSArray class]]) {
        [self setupLayout];
        [self setupDataWirh:object];
        [self.tableView reloadData];
    }
}

// 将model转化为viewModel
- (void)setupDataWirh:(NSArray *)dataArray {
    self.dataSource = [[NSMutableArray alloc] init];
    __weak typeof(self)weakSelf = self;
    [dataArray enumerateObjectsUsingBlock:^(GAPlayerDetailModel *detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
        GAPlayerDetailCellModel *cellModel = [[GAPlayerDetailCellModel alloc] init];
        [cellModel setObject:detailModel];
        [weakSelf makeProgressCellModelBlock:cellModel];
        [weakSelf.dataSource addObject:cellModel];
    }];
}

// 增加viewModel的回调
- (void)makeProgressCellModelBlock:(GAPlayerDetailCellModel *)cellModel {
    
    __weak typeof(self)weakSelf = self;
    cellModel.playOpertionBlock = ^(GAPlayerDetailCellModel * _Nonnull cellModel) {
        cellModel.detailModel.isActive = YES;
        [weakSelf changLectureWith:cellModel.detailModel];
    };
    
    cellModel.downloadOptionBlock = ^(GAPlayerDetailCellModel * _Nonnull cellModel) {
        if (weakSelf.actionBlock) {
            weakSelf.actionBlock(cellModel.detailModel, kPDActionTypeDonwload);
        }
    };
    
}

// 切换视频 将UI进行处理
- (void)changLectureWith:(GAPlayerDetailModel *)detailModel {
    GAPlayerDetailCellModel *lectureCellVModel = [self getLectureCellVModelWith:detailModel];
    if (!lectureCellVModel) return;
    PlayerDetailActionType actionType;
    if (lectureCellVModel != self.currentCellVModel) {
        self.currentCellVModel.isCurrentSelect = NO;
        self.currentCellVModel = lectureCellVModel;
        self.currentCellVModel.isCurrentSelect = YES;
        actionType = kPDActionTypeChangeSource;
    } else {
        actionType = kPDActionTypeChangeState;
        self.currentCellVModel.isCurrentSelect = !self.currentCellVModel.isCurrentSelect;
    }
    
    if (self.actionBlock) {
        self.actionBlock(detailModel, actionType);
    }
}

- (GAPlayerDetailCellModel *)getLectureCellVModelWith:(GAPlayerDetailModel *)detailModel {
    __block GAPlayerDetailCellModel *currentCellVModel;
    [self.dataSource enumerateObjectsUsingBlock:^(GAPlayerDetailCellModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.detailModel == detailModel) {
            currentCellVModel = obj;
            *stop = YES;
        }
    }];
    return currentCellVModel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GAPlayerDetailTableViewCell * cell = [GAPlayerDetailTableViewCell cellWithTableView:tableView];
    if (self.dataSource.count > indexPath.row) {
        GAPlayerDetailCellModel *cellModel = self.dataSource[indexPath.row];
        cell.isHideLine = indexPath.row == self.dataSource.count - 1;
        [cell setObject:cellModel];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GAPlayerDetailCellModel *cellModel = self.dataSource[indexPath.row];
    cellModel.detailModel.isActive = YES;
    [self changLectureWith:cellModel.detailModel];
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

@end
