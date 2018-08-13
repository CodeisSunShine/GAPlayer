//
//  GAPlayerSelectView.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerSelectView.h"
#import "GAPlayerSelectTableViewCell.h"

@interface GAPlayerSelectView () <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *dataSource;

@property (nonatomic, strong) GAPlayerSelectVIewModel *lastModel;

@end

@implementation GAPlayerSelectView

#pragma mark - life circle
- (instancetype)init {
    
    self = [super init];
    if (self) {
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        [self setupViews];
    }
    return self;
}

#pragma mark - setup
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupFrames];
}

- (void)setupFrames{
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat tableViewW = 200;
    CGFloat tableViewH = 0.f;
    if (self.dataSource && self.dataSource.count > 0) {
        tableViewH = self.dataSource.count * 44;
    }
    
    if (tableViewH > self.frame.size.height - 44) {
        tableViewH = self.frame.size.height - 44;
    }
    
    self.tableView.frame = CGRectMake((width - tableViewW)/2, (height - tableViewH)/2, tableViewW, tableViewH);
}

- (void)setupViews{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self addSubview:self.tableView];
}

- (void)setObject:(id)object {
    if (self.dataSource && self.dataSource.count > 0) {
        self.lastModel.isSelect = NO;
        self.dataSource = nil;
        self.lastModel = nil;
    }
    self.dataSource = object;
    [self setupFrames];
    [self.tableView reloadData];
}

- (void)outsideOption:(NSString *)selectName {
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        GAPlayerSelectVIewModel *model = self.dataSource[i];
        if ([selectName isEqualToString:model.selectName]) {
            model.isSelect = YES;
            if (self.lastModel) {
                self.lastModel.isSelect = NO;
            }
            self.lastModel = model;
        }
        break;
    }
}

- (void)tapClick:(UIGestureRecognizer *)ges {
    self.hidden = YES;
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    /**
     *判断如果点击的是tableView的cell，就把手势给关闭了 不是点击cell手势开启
     **/
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource && self.dataSource.count) {
        return self.dataSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GAPlayerSelectTableViewCell * cell = [GAPlayerSelectTableViewCell cellWithTableView:tableView];
    if (self.dataSource && self.dataSource.count) {
        GAPlayerSelectVIewModel *model = self.dataSource[indexPath.row];
        if (indexPath.row == self.dataSource.count -1) {
            cell.isLastLow = YES;
        } else {
            cell.isLastLow = NO;
        }
        [cell setObject:model];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GAPlayerSelectVIewModel *model = self.dataSource[indexPath.row];
    model.isSelect = YES;
    self.lastModel.isSelect = NO;
    self.lastModel = model;
    if (self.selectViewBlock) {
        self.selectViewBlock(model);
    }
    self.hidden = YES;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

@end
