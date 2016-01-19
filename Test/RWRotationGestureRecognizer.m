//
//  RWRotationGestureRecognizer.m
//  KnobControl
//
//  Created by YunTu on 15/2/5.
//  Copyright (c) 2015年 RayWenderlich. All rights reserved.
//

#import "RWRotationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation RWRotationGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if(self) {
        self.maximumNumberOfTouches = 1;
        self.minimumNumberOfTouches = 1;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self updateTouchAngleWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self updateTouchAngleWithTouches:touches];
}

- (void)updateTouchAngleWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];  //the view the gesture is attached to.
    
    self.touchAngle = [self calculateAngleToPoint:touchPoint];
}

- (CGFloat)calculateAngleToPoint:(CGPoint)point
{
    // Offset by the center
    CGPoint centerOffset = CGPointMake(point.x - CGRectGetMidX(self.view.bounds),   //(x, y)由touchPoint与中心点之间的距离
                                       point.y - CGRectGetMidY(self.view.bounds));
    return atan2(centerOffset.y, centerOffset.x);   //反正切，得到弧度值
}

@end
