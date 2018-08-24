//
//  GAPlayerView+GestureAction.m
//  IJKPlayer-Demo
//
//  Created by 宫傲 on 2018/8/6.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAPlayerView+GestureAction.h"

#define VerticalAngle 1.7
#define HorizontalAngle 1

@implementation GAPlayerView (GestureAction)

// 注册手势
- (void)registerForGestureEvents:(void(^)(GsetureType gsetureType,CGFloat moveValue))gsetureBlock {
    self.gsetureBlock = gsetureBlock;
    [self addSingleAndDoubleStrikeGestures];
    [self startForGestureEvents];
}

// 开启手势
- (void)startForGestureEvents {
    self.needGseture = YES;
}

// 取消手势
- (void)cancelForGestureEvents {
    self.needGseture = NO;
}

// 增加单双击手势
- (void)addSingleAndDoubleStrikeGestures {
    UITapGestureRecognizer *singleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapClick)];
    [self addGestureRecognizer:singleTapGes];
    
    UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapClick)];
    doubleTapGes.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGes];
    
    [singleTapGes requireGestureRecognizerToFail:doubleTapGes];
}

- (void)singleTapClick {
    [self gsetureCallBlock:kGsetureTypeSingleTap movementValue:0];
}

- (void)doubleTapClick {
    [self gsetureCallBlock:kGsetureTypeDoubleTap movementValue:0];
}

#pragma mark - touche
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.gsetureType = kGsetureTypeNone;
    self.beginPoint = [[touches anyObject] locationInView:self];
//    NSLog(@"beginPoint x = %f ----- y = %f",self.beginPoint.x,self.beginPoint.y);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint movePoint = [touch locationInView:self];
    [self handleMovingGesturesWith:self.beginPoint movePoint:movePoint];
    
//    NSLog(@"movePoint x = %f ----- y = %f",movePoint.x,movePoint.y);
    self.beginPoint = movePoint;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self gsetureCallBlock:kGsetureTypeCancel movementValue:0];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self gsetureCallBlock:kGsetureTypeEnd movementValue:0];
}

// 根据滑动 判断手势类型
- (void)handleMovingGesturesWith:(CGPoint)beginPoint movePoint:(CGPoint)movePoint {
    CGFloat moveY = movePoint.y - self.beginPoint.y;
    CGFloat moveX = movePoint.x - self.beginPoint.x;
    GsetureType gsetureType;
    CGFloat movementValue = 0.0;
    CGFloat fabsY = fabs(moveY);
    CGFloat fabsX = fabs(moveX);
    CGFloat angle = fabsY / (CGFloat)fabsX;
    
    if ((VerticalAngle < angle) && (fabsY > 0)) {
        if ([self decideIfLeftHandGestureWith:beginPoint]) {
            gsetureType = kGsetureTypeLeftVertical;
        } else {
            gsetureType = kGsetureTypeRightVertical;
        }
        movementValue = moveY;
    } else if ((HorizontalAngle > angle) && (fabsX > 0)) {
        gsetureType = kGsetureTypeHorizontal;
        movementValue = moveX;
    } else {
        gsetureType = kGsetureTypeNone;
    }
    
    if (gsetureType == kGsetureTypeNone) {
        [self gsetureCallBlock:kGsetureTypeCancel movementValue:0];
    } else {
        if (self.gsetureType == kGsetureTypeNone) {
            self.gsetureType = gsetureType;
            [self gsetureCallBlock:gsetureType movementValue:movementValue];
        } else {
            if (self.gsetureType == gsetureType) {
                [self gsetureCallBlock:gsetureType movementValue:movementValue];
            } else {
                [self gsetureCallBlock:kGsetureTypeCancel movementValue:0];
                NSLog(@"手势前后不一致,取消手势");
            }
        }
    }
}

- (void)gsetureCallBlock:(GsetureType)gsetureType movementValue:(CGFloat)movementValue {
    if (self.needGseture) {
        if (self.gsetureBlock) {
            self.gsetureBlock(gsetureType, movementValue);
        }
    }
}

- (BOOL)decideIfLeftHandGestureWith:(CGPoint)beginPoint {
    if (self.isFullScreen) {
        return (self.beginPoint.x < [UIScreen mainScreen].bounds.size.height/2);
    } else {
        return (self.beginPoint.x < [UIScreen mainScreen].bounds.size.width/2);
    }
}

@end
