//
//  GAHomeListTableViewCell.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAHomeListTableViewCell.h"
#import "GAHomeListModel.h"

@interface GAHomeListTableViewCell ()

@property (nonatomic, strong) UIImageView *listCellimageView;

@property (nonatomic, strong) UILabel *listCellTitleLabel;

@property (nonatomic, strong) UILabel *describeLabel;

@property (nonatomic, strong) UILabel *lineLabel;

@property (nonatomic, strong) GAHomeListModel *listModel;

@end

@implementation GAHomeListTableViewCell

#pragma mark - life circle
+ (GAHomeListTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"GAHomeListTableViewCell";
    GAHomeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        //这里使用系统自带的样式
        cell = [[GAHomeListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
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

- (void)setupViews {
    [self.contentView addSubview:self.listCellimageView];
    [self.contentView addSubview:self.describeLabel];
    [self.contentView addSubview:self.listCellTitleLabel];
    [self.contentView addSubview:self.lineLabel];
}

- (void)setupLayout {
    CGFloat kCellHigh = 90;
    CGFloat kDistance = 12;
    CGFloat kToptance = 10;
    
    CGSize imageSize = CGSizeMake(105, 76);
    
    self.listCellimageView.frame = CGRectMake(kDistance, (kCellHigh - imageSize.height) * 0.5, imageSize.width, imageSize.height);
    self.listCellTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.listCellimageView.frame)+ 15 , kToptance, ScreenWidth - (CGRectGetMaxX(self.listCellimageView.frame)+ 15) - kDistance, 20);
    self.describeLabel.frame = CGRectMake(CGRectGetMaxX(self.listCellimageView.frame)+ 15, kCellHigh - 20 - kToptance, ScreenWidth - (CGRectGetMaxX(self.listCellimageView.frame)+ 15) - kDistance, 20);
    self.lineLabel.frame = CGRectMake(CGRectGetMaxX(self.listCellimageView.frame)+ 15 , kCellHigh - 1, ScreenWidth - (CGRectGetMaxX(self.listCellimageView.frame)+ 15 ), 0.5);
}

- (void)setObject:(id)object {
    if ([object isKindOfClass:[GAHomeListModel class]]) {
        self.listModel = (GAHomeListModel *)object;
        [self setupData];
        [self setupLayout];
    }
}

- (void)setupData {
    [self.listCellimageView setImage:[UIImage imageNamed:self.listModel.videoImage]];
    self.describeLabel.text = self.listModel.videoDescribe;
    self.listCellTitleLabel.text = self.listModel.videoName;
    self.lineLabel.hidden = self.isHideLine;
}

- (UIImageView *)listCellimageView {
    if (!_listCellimageView) {
        _listCellimageView = [[UIImageView alloc] init];
        _listCellimageView.layer.masksToBounds = YES;
        //自适应图片宽高比例
        _listCellimageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _listCellimageView;
}

- (UILabel *)listCellTitleLabel {
    if (!_listCellTitleLabel) {
        _listCellTitleLabel = [[UILabel alloc] init];
        _listCellTitleLabel.font = [UIFont systemFontOfSize:14];
        _listCellTitleLabel.textColor = kMyColor(53, 50, 58);
    }
    return _listCellTitleLabel;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.font = [UIFont systemFontOfSize:14];
        _describeLabel.textColor = kMyColor(178, 175, 183);
    }
    return _describeLabel;
}

- (UILabel *)lineLabel {
    if (!_lineLabel) {
        _lineLabel = [[UILabel alloc] init];
        _lineLabel.backgroundColor = kMyColor(232, 230, 234);
    }
    return _lineLabel;
}

@end
