//
//  ZJDatePicker.m
//  SuperGym_Coach
//
//  Created by hanyou on 15/11/25.
//  Copyright © 2015年 hanyou. All rights reserved.
//

#import "ZJDatePicker.h"

@interface ZJDatePicker ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

#define Alpha 0.4
#define PickerViewHeight 250

@implementation ZJDatePicker

@synthesize date = _date;

#pragma mark - init

/**
 *  当只调用init方法, 也会调用initFrame方法,
 *  则对象的frame初始值为CGRectZero
 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 || frame.size.height == 0) {
        frame = [UIScreen mainScreen].bounds;
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetting];
    }
    return self;
}

- (instancetype)initWithSuperView:(UIView *)superView datePickerMode:(UIDatePickerMode)mode {
    self = [super initWithFrame:superView.frame];
    if (self) {
        _datePickerMode = mode;
        [superView addSubview:self];
        [self initSetting];
    }
    
    return self;
}

- (void)initSetting {
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.alpha = 0.0;
    
    self.bgView = [[UIView alloc] initWithFrame:self.frame];
    self.bgView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0];
    self.bgView.alpha = 0.4;
    [self addSubview:self.bgView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, PickerViewHeight)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    topView.backgroundColor = self.topViewBackgroundColor;
    [self.bottomView addSubview:topView];
    
    NSArray *titles = @[@"取消", @"确定"];
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(i*(topView.frame.size.width - 50), 0, 50, topView.frame.size.height);
        if (i == 0) {
            [btn setTitleColor:self.leftButtonTitleColor forState:UIControlStateNormal];
        }else {
            [btn setTitleColor:self.rightButtonTitleColor forState:UIControlStateNormal];
        }
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:btn];
    }
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, topView.bounds.size.height, self.bounds.size.width, PickerViewHeight - topView.bounds.size.height)];
    self.datePicker.datePickerMode = _datePickerMode;
    [self.bottomView addSubview:self.datePicker];
}

- (void)clickButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(datePicker:clickedButtonAtIndex:)]) {
        [self.delegate datePicker:self clickedButtonAtIndex:sender.tag];
    }
    
    [self setHid:YES];
}

#pragma mark - setter

- (void)setDate:(NSDate *)date {
    _date = date;
    self.datePicker.date = date;
}

- (void)setMinDate:(NSDate *)minDate {
    _minDate = minDate;
    self.datePicker.minimumDate = minDate;
}

- (void)setMaxDate:(NSDate *)maxDate {
    _maxDate = maxDate;
    self.datePicker.maximumDate = maxDate;
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode {
    _datePickerMode = datePickerMode;
    self.datePicker.datePickerMode = datePickerMode;
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated {
    [self.datePicker setDate:date animated:animated];
}

- (void)setHid:(BOOL)hid {
    if (hid) {   //
        __block CGRect frame = self.bottomView.frame;
        [UIView animateWithDuration:0.5 animations:^{
            frame.origin.y += PickerViewHeight;
            self.bottomView.frame = frame;
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.hidden = hid;
        }];
    }else {
        self.hidden = hid;
        __block CGRect frame = self.bottomView.frame;
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
            frame.origin.y -= PickerViewHeight;
            self.bottomView.frame = frame;
        }];
    }
}

- (void)setHid:(BOOL)hid comletion:(completionHandle)comletion {
    [self setHid:hid];
    
    if (comletion) {
        comletion(YES);
    }
}

#pragma mark - getter

- (UIColor *)topViewBackgroundColor {
    if (!_topViewBackgroundColor) {
        _topViewBackgroundColor = [UIColor colorWithRed:0.82 green:0.73 blue:0.68 alpha:0.28];
    }
    return _topViewBackgroundColor;
}

- (UIColor *)leftButtonTitleColor {
    if (!_leftButtonTitleColor) {
        _leftButtonTitleColor = [UIColor blackColor];
    }
    return _leftButtonTitleColor;
}

- (UIColor *)rightButtonTitleColor {
    if (!_rightButtonTitleColor) {
        _rightButtonTitleColor = [UIColor colorWithRed:0.83 green:0.15 blue:0.13 alpha:1];
    }
    return _rightButtonTitleColor;
}

/**
 *  当date未赋初始值时,date = nil;
 */
- (NSDate *)date {
    if (!_date) {
        _date = self.datePicker.date;
    }
    return _date;
}

#pragma mark - touchEvent

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isHidden) {
        [self setHid:YES];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
