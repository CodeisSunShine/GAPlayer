//
//  GAPlayerSelectTableViewCell.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAPlayerSelectTableViewCell : UITableViewCell

+ (GAPlayerSelectTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, assign) BOOL isLastLow;

- (void)setObject:(id)object;

@end
