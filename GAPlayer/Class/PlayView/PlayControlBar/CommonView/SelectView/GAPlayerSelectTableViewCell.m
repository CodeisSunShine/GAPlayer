//
//  GAPlayerSelectTableViewCell.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerSelectTableViewCell.h"
#import "GAPlayerSelectVIewModel.h"

@interface GAPlayerSelectTableViewCell ()
@property (nonatomic,strong)UILabel * titleLbl;
@property (nonatomic,strong)UIImageView * bottomImgView;
@property (nonatomic,strong)GAPlayerSelectVIewModel *selectVIewModel;
@end

@implementation GAPlayerSelectTableViewCell

#pragma mark – life cycle
+ (GAPlayerSelectTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"GAPlayerSelectTableViewCell";
    GAPlayerSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        //这里使用系统自带的样式
        cell = [[GAPlayerSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

#pragma mark - setup
- (void)setupViews{
    
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.bottomImgView];
}

- (void)setObject:(id)object {
    if (object && [object isKindOfClass:[GAPlayerSelectVIewModel class]]) {
        self.selectVIewModel = (GAPlayerSelectVIewModel*)object;
        self.titleLbl.text = self.selectVIewModel.selectName;
        [self changeTitleLbColor:self.selectVIewModel.isSelect];
        __weak typeof(self) weakSelf = self;
        self.selectVIewModel.selectBlock = ^{
            [weakSelf changeTitleLbColor:weakSelf.selectVIewModel.isSelect];
        };
        [self setupFrames];
    }
}

- (void)changeTitleLbColor:(BOOL)isSelect {
    if (isSelect) {
        self.titleLbl.textColor = kMyColor(255, 141, 52);
    } else {
        self.titleLbl.textColor = kMyColor(208, 208, 208);
    }
}

- (void)setupFrames{
    self.titleLbl.frame = CGRectMake(0, 0, 200, 44);
    self.bottomImgView.frame = CGRectMake(0, 44 - 0.5, 200, 0.5);
}

#pragma mark - setter and getter
- (void)setIsLastLow:(BOOL)isLastLow{
    _isLastLow = isLastLow;
    if (_isLastLow) {
        self.bottomImgView.hidden = YES;
    } else {
        self.bottomImgView.hidden = NO;
    }
}

- (UILabel *)titleLbl{
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLbl.font = [UIFont systemFontOfSize:16];
        _titleLbl.textColor = [UIColor blackColor];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.numberOfLines = 2;
    }
    return _titleLbl;
}

- (UIImageView *)bottomImgView{
    if (!_bottomImgView) {
        _bottomImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _bottomImgView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.4];
    }
    return _bottomImgView;
}

@end
