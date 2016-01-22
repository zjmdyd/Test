//
//  RWKnobControl.m
//  KnobControl
//
//  Created by YunTu on 15/2/3.
//  Copyright (c) 2015年 RayWenderlich. All rights reserved.
//

#import "RWKnobControl.h"
#import "RWKnobRender.h"
#import "RWRotationGestureRecognizer.h"

@implementation RWKnobControl{
    RWKnobRender *_knobRenderer;
    RWRotationGestureRecognizer *_gestureRecognizer;
}

// dynamic修饰符告诉编译器不用考虑这些属性的存取，因为下面会手动的为这些属性添加getter和setter方法
@dynamic lineWidth;
@dynamic startAngle;
@dynamic endAngle;
@dynamic pointerLength;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _minimumValue = 0.0;
        _maximumValue = 1.0;
        _value = 0.0;
        _continuous = YES;
        
        _gestureRecognizer = [[RWRotationGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleGesture:)];
        [self addGestureRecognizer:_gestureRecognizer];
        
        [self createKnobUI];
    }
    return self;
}

- (void)createKnobUI {
    _knobRenderer = [[RWKnobRender alloc] init];
    [_knobRenderer updateWithBounds:self.bounds];
    _knobRenderer.color = self.tintColor;   //在此设置得不到想要的效果，因为这句代码是在self.tintColor改变之前执行,所以要达到想要的效果，必须调用
                                            //tintColorDidChange方法，在此方法里面再执行颜色的赋值操作

    // Set some defaults
    _knobRenderer.startAngle = -M_PI * 11 / 8.0;
    _knobRenderer.endAngle = M_PI * 3 / 8.0;
    _knobRenderer.pointerAngle = _knobRenderer.startAngle;
    _knobRenderer.lineWidth = 2.0;
    _knobRenderer.pointerLength = 6.0;
    
    // Add the layers
    [self.layer addSublayer:_knobRenderer.trackLayer];
    [self.layer addSublayer:_knobRenderer.pointerLayer];
}

#pragma mark - API Methods
- (void)setValue:(CGFloat)value animated:(BOOL)animated {
    if(value != _value) {
        [self willChangeValueForKey:@"value"];
        // Save the value to the backing ivar
        // Make sure we limit it to the requested bounds
        _value = MIN(self.maximumValue, MAX(self.minimumValue, value));
        
        // Now let's update the knob with the correct angle
        CGFloat angleRange = self.endAngle - self.startAngle;
        CGFloat valueRange = self.maximumValue - self.minimumValue;
        CGFloat angleForValue = (_value - self.minimumValue) / valueRange * angleRange + self.startAngle;
        [_knobRenderer setPointerAngle:angleForValue animated:animated];
        [self didChangeValueForKey:@"value"];
    }
}

#pragma mark - Property overrides
- (void)setValue:(CGFloat)value {
    // Chain with the animation method version
    [self setValue:value animated:NO];
}

- (void)tintColorDidChange {
    _knobRenderer.color = self.tintColor;
}//实时更新视图外观

#pragma mark - render related property

- (CGFloat)lineWidth {
    return _knobRenderer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _knobRenderer.lineWidth = lineWidth;
}

- (CGFloat)startAngle {
    return _knobRenderer.startAngle;
}

- (void)setStartAngle:(CGFloat)startAngle {
    _knobRenderer.startAngle = startAngle;
}

- (CGFloat)endAngle {
    return _knobRenderer.endAngle;
}

- (void)setEndAngle:(CGFloat)endAngle {
    _knobRenderer.endAngle = endAngle;
}

- (CGFloat)pointerLength {
    return _knobRenderer.pointerLength;
}

- (void)setPointerLength:(CGFloat)pointerLength {
    _knobRenderer.pointerLength = pointerLength;
}

#pragma mark - Gesture

- (void)handleGesture:(RWRotationGestureRecognizer *)gesture {
    // Notify of value change
    if (self.continuous) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        // Only send an update if the gesture has completed
        if(_gestureRecognizer.state == UIGestureRecognizerStateEnded
           || _gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    
    // 1. Mid-point angle
    CGFloat midPointAngle = (2 * M_PI + self.endAngle - self.startAngle) / 2 + self.startAngle;   //算中间值得到pi/2, 中间值没有发生改变
    NSLog(@"st = %f, end = %f, mid = %f", self.startAngle, self.endAngle, midPointAngle);
    
    // 2. Ensure the angle is within a suitable range(控制在2pi之内)
    CGFloat boundedAngle = gesture.touchAngle;      //与手势关联起来的代码
    
    NSLog(@"bb = %f", boundedAngle);
    if(boundedAngle > midPointAngle) {  //如果大于pi/2
        boundedAngle -= 2 * M_PI;
    } else if (boundedAngle < (midPointAngle - 2 * M_PI)) {
        boundedAngle += 2 * M_PI;
    }
    NSLog(@"eb1 = %f", boundedAngle);
    
    // 3. Bound the angle to within the suitable range
    boundedAngle = MIN(self.endAngle, MAX(self.startAngle, boundedAngle));
    NSLog(@"eb2 = %f\n\n", boundedAngle);
    
    // 4. Convert the angle to a value
    CGFloat angleRange = self.endAngle - self.startAngle;
    CGFloat valueRange = self.maximumValue - self.minimumValue;
    CGFloat valueForAngle = (boundedAngle - self.startAngle) / angleRange * valueRange + self.minimumValue;
    
    // 5. Set the control to this value
    self.value = valueForAngle;
}


@end


















