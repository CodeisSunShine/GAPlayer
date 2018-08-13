//
//  GAPlayerSelectVIewModel.h
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/2.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GAPlayerSelectVIewModelSelectBlock)(void);

@interface GAPlayerSelectVIewModel : NSObject

@property (nonatomic, strong) GAPlayerSelectVIewModelSelectBlock selectBlock;

@property (nonatomic, strong) NSString *selectName;

@property (nonatomic, strong) NSString *selectValue;

@property (nonatomic, strong) NSString *selectType;

@property (nonatomic, assign) BOOL isSelect;

@end
