//
//  TestView.m
//  Test
//
//  Created by ZJ on 1/15/16.
//  Copyright © 2016 ZJ. All rights reserved.
//

#import "TestView.h"

@interface TestView ()

@property (nonatomic, getter=isHidden) BOOL hidden;

@end

@implementation TestView

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    _hidden = hidden;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
