//
//  GAPlayerSelectView.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAPlayerSelectVIewModel.h"

typedef void(^GAPlayerSelectViewBlock)(GAPlayerSelectVIewModel *selectModel);

@interface GAPlayerSelectView : UIView

@property (nonatomic, strong) GAPlayerSelectViewBlock selectViewBlock;

- (void)setObject:(id)object;

- (void)outsideOption:(NSString *)selectName;

@end
