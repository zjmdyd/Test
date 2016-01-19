//
//  ZJFooterView.m
//  HeartGuardForDoctor
//
//  Created by hanyou on 15/11/2.
//  Copyright © 2015年 HANYOU. All rights reserved.
//

#import "ZJFooterView.h"

@interface ZJFooterView ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation ZJFooterView

@synthesize backgroundColor = _backgroundColor;
@synthesize titleColor = _titleColor;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [ZJFooterView initWithFrame:frame title:title];
    
    if (self) {
        [self initSetting];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title superView:(UIView *)superView {
    self = [ZJFooterView initWithFrame:frame title:title];
    
    if (self) {
        [self initSetting];
        [superView addSubview:self];
    }
    return self;
}

+ (ZJFooterView *)initWithFrame:(CGRect)frame title:(NSString *)title {
    ZJFooterView *footView = [[ZJFooterView alloc] initWithFrame:frame];
    footView.title = title;
    return footView;
}

- (void)initSetting {
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame = CGRectMake(20, 15, self.frame.size.width - 40, self.frame.size.height - 30);
    self.button.backgroundColor = self.backgroundColor;
    self.button.layer.cornerRadius = 8;
    self.button.layer.masksToBounds = YES;
    self.button.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.button setTitle:_title forState:UIControlStateNormal];
    [self.button setTitleColor:self.titleColor forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
}

- (void)clickButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(footerViewDidClick:)]) {
        [self.delegate footerViewDidClick:self];
    }
}

#pragma mark - setter

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.button.backgroundColor = backgroundColor;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [self.button setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.button setTitle:title forState:UIControlStateNormal];
}

#pragma mark - getter

- (UIColor *)backgroundColor {
    if (!_backgroundColor) {
        _backgroundColor = [UIColor redColor];
    }
    return _backgroundColor;
}

- (UIColor *)titleColor {
    if (!_titleColor) {
        _titleColor = [UIColor whiteColor];
    }
    return _titleColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
