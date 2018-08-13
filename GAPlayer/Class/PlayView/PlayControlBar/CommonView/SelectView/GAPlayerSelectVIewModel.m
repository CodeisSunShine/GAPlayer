//
//  GAPlayerSelectVIewModel.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerSelectVIewModel.h"

@implementation GAPlayerSelectVIewModel

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    if (self.selectBlock) {
        self.selectBlock();
    }
}

@end
