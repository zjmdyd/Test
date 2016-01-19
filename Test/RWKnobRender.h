//
//  RWKnobRender.h
//  KnobControl
//
//  Created by YunTu on 15/2/4.
//  Copyright (c) 2015年 RayWenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RWKnobRender : NSObject

#pragma mark - Properties associated with all parts of the renderer
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat lineWidth;    //弧线的宽度

#pragma mark - Properties associated with the background track
@property (nonatomic, readonly, strong) CAShapeLayer *trackLayer;   //轨道层
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;

#pragma mark - Properties associated with the pointer element
@property (nonatomic, readonly, strong) CAShapeLayer *pointerLayer; //指针层
@property (nonatomic, assign) CGFloat pointerAngle;
@property (nonatomic, assign) CGFloat pointerLength;    //指针的长度

//
- (void)updateWithBounds:(CGRect)bounds;
- (void)setPointerAngle:(CGFloat)pointerAngle animated:(BOOL)animated;

@end
