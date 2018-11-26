//
//  GAPlayerDetailTableViewCell.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/11/21.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerDetailTableViewCell.h"
#import "GAPlayerDetailCellModel.h"
@interface GAPlayerDetailTableViewCell ()

// 课程
@property (nonatomic, strong) UILabel *courseLabel;
// 下载进度
@property (nonatomic, strong) UILabel *speedLabel;
// 下载状态
@property (nonatomic, strong) UILabel *stateLabel;
// 下载状态
@property (nonatomic, strong) UIButton *stateButton;
// 下载状态视图
@property (nonatomic, strong) UIImageView *downloadStateView;
// icon
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) GAPlayerDetailCellModel *cellVModel;

@property (nonatomic, strong) UIImageView *bottomLineView;

@end

static NSString *cGAPlayerDetailTableViewCell = @"GAPlayerDetailTableViewCell";

@implementation GAPlayerDetailTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    GAPlayerDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cGAPlayerDetailTableViewCell];
    if (!cell) {
        cell = [[GAPlayerDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cGAPlayerDetailTableViewCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.playButton];
    [self.contentView addSubview:self.courseLabel];
    [self.contentView addSubview:self.stateButton];
    [self.contentView addSubview:self.bottomLineView];
    
    [self.stateButton addSubview:self.speedLabel];
    [self.stateButton addSubview:self.downloadStateView];
    [self.stateButton addSubview:self.stateLabel];
    [self.contentView addSubview:self.progressView];
}

- (void)setupLayout {
    self.playButton.frame = self.cellVModel.playButtonF;
    self.courseLabel.frame = self.cellVModel.courseLabelF;
    self.stateButton.frame = self.cellVModel.stateButtonF;
    self.speedLabel.frame = self.cellVModel.speedLabelF;
    self.downloadStateView.frame = self.cellVModel.downloadStateViewF;
    self.stateLabel.frame = self.cellVModel.stateLabelF;
    self.bottomLineView.frame = self.cellVModel.lineF;
    self.progressView.frame = self.cellVModel.progressViewF;
}


- (void)setObject:(id)object {
    if (object && [object isKindOfClass:[GAPlayerDetailCellModel class]]) {
        self.cellVModel = object;
        __weak typeof(self)weakSelf = self;
        self.cellVModel.playImageBlcok = ^{
            [weakSelf setupData];
        };
        
        self.cellVModel.downloadStateBlock = ^{
            [weakSelf setupData];
            [weakSelf setupLayout];
        };
        
        self.cellVModel.downloadProgressBlock = ^{
            [weakSelf setupData];
            [weakSelf setupLayout];
        };

        self.cellVModel.downloadSpeedBlock = ^{
            [weakSelf setupData];
            [weakSelf setupLayout];
        };
        
        [self setupLayout];
        [self setupData];
    }
}

- (void)setupData {
    self.courseLabel.text = self.cellVModel.courseNmae;
    self.downloadStateView.image = [UIImage imageNamed:self.cellVModel.downloadImageNmae];
    self.stateLabel.text = self.cellVModel.stateName;
    self.stateLabel.textColor = self.cellVModel.stateColor;
    self.speedLabel.text = self.cellVModel.speed;
    // 下载中的状态才显示下载进度
    self.speedLabel.hidden = self.cellVModel.progressHide;
    self.progressView.progress = self.cellVModel.progress;
    [self.playButton setImage:[UIImage imageNamed:self.cellVModel.playImageName] forState:UIControlStateNormal];
}

- (void)downloadStateDidChanged {
    if (self.cellVModel.downloadOptionBlock) {
        self.cellVModel.downloadOptionBlock(self.cellVModel);
    }
}

- (void)playClick {
    if (self.cellVModel.playOpertionBlock) {
        self.cellVModel.playOpertionBlock(self.cellVModel);
    }
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"course_play_normal"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"course_pause_normal"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UILabel *)courseLabel {
    if (!_courseLabel) {
        _courseLabel = [[UILabel alloc]init];
        _courseLabel.textColor = [UIColor blackColor];
        _courseLabel.font = [UIFont systemFontOfSize:15];
        _courseLabel.numberOfLines = 0;
    }
    return _courseLabel;
}

- (UIButton *)stateButton {
    if (!_stateButton) {
        _stateButton = [[UIButton alloc]init];
        [_stateButton addTarget:self action:@selector(downloadStateDidChanged) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stateButton;
}

- (UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc]init];
        _speedLabel.textColor = kMyColor(255, 98, 134);
        _speedLabel.font = [UIFont systemFontOfSize:8];
        _speedLabel.textAlignment = 1;
    }
    return _speedLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc]init];
        _stateLabel.font = [UIFont systemFontOfSize:12];
        _stateLabel.textAlignment = 1;
    }
    return _stateLabel;
}

- (UIImageView *)downloadStateView {
    if (!_downloadStateView) {
        _downloadStateView = [[UIImageView alloc]init];
        _downloadStateView.userInteractionEnabled = NO;
    }
    return _downloadStateView;
}

- (UIImageView *)bottomLineView {
    
    if (_bottomLineView == nil) {
        _bottomLineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = kMyColor(232, 230, 234);
    }
    return _bottomLineView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = kMyColor(255, 141, 52);  // 已走过的颜色
        _progressView.trackTintColor    = kMyColor(202, 198, 210);  // 未走过的颜色
    }
    return _progressView;
}

@end
