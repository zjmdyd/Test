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
@property (nonatomic, strong) UIView *topView;      // bottomView的topView
@property (nonatomic, strong) UILabel *mentionLabel;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, getter=isHidden) BOOL hidden;

@end

#define Alpha 0.4
#define PickerViewHeight 250

@implementation ZJDatePicker

@synthesize date = _date;
@synthesize topViewBackgroundColor = _topViewBackgroundColor;
@synthesize leftButtonTitleColor = _leftButtonTitleColor;
@synthesize rightButtonTitleColor = _rightButtonTitleColor;

#pragma mark - init

/**
 *  当只调用init方法, 也会调用initFrame方法,
 *  则对象的frame初始值为CGRectZero
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetting];
    }
    return self;
}

- (instancetype)initWithSuperView:(UIView *)superView datePickerMode:(UIDatePickerMode)mode {
    self = [super initWithFrame:superView.bounds];
    if (self) {
        _datePickerMode = mode;
        [superView addSubview:self];
        [self initSetting];
    }
    
    return self;
}

- (void)initSetting {
    _hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.0;
    
    self.bgView = [[UIView alloc] initWithFrame:self.frame];
    self.bgView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0];
    self.bgView.alpha = 0.4;
    [self addSubview:self.bgView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, PickerViewHeight)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    self.topView.backgroundColor = self.topViewBackgroundColor;
    [self.bottomView addSubview:self.topView];
    
    NSArray *titles = @[@"取消", @"确定"];
    CGFloat width = 50;
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(i*(self.topView.frame.size.width - width), 0, width, self.topView.frame.size.height);
        if (i == 0) {
            [btn setTitleColor:self.leftButtonTitleColor forState:UIControlStateNormal];
        }else {
            [btn setTitleColor:self.rightButtonTitleColor forState:UIControlStateNormal];
        }
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:btn];
    }
    
    self.mentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, 0, self.topView.frame.size.width - 2*width, self.topView.frame.size.height)];
    self.mentionLabel.font = [UIFont systemFontOfSize:15];
    self.mentionLabel.textAlignment = NSTextAlignmentCenter;
    self.mentionLabel.textColor = self.mentionTitleColor;
    [self.topView addSubview:self.mentionLabel];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.topView.bounds.size.height, self.bounds.size.width, PickerViewHeight - self.topView.bounds.size.height)];
    self.datePicker.datePickerMode = _datePickerMode;
    [self.bottomView addSubview:self.datePicker];
}

- (void)clickButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(datePicker:clickedButtonAtIndex:)]) {
        [self.delegate datePicker:self clickedButtonAtIndex:sender.tag];
    }
    
    self.hidden = YES;
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

- (void)setTopViewBackgroundColor:(UIColor *)topViewBackgroundColor {
    _topViewBackgroundColor = topViewBackgroundColor;
    self.topView.backgroundColor = _topViewBackgroundColor;
}

- (void)setLeftButtonTitleColor:(UIColor *)leftButtonTitleColor {
    _leftButtonTitleColor = leftButtonTitleColor;
    UIButton *btn = [self.topView.subviews objectAtIndex:0];
    [btn setTitleColor:_leftButtonTitleColor forState:UIControlStateNormal];
}

- (void)setRightButtonTitleColor:(UIColor *)rightButtonTitleColor {
    _rightButtonTitleColor = rightButtonTitleColor;
    UIButton *btn = [self.topView.subviews objectAtIndex:1];
    [btn setTitleColor:_rightButtonTitleColor forState:UIControlStateNormal];
}

- (void)setHidden:(BOOL)hidden {
    _hidden = hidden;
    
    if (hidden) {   //
        __block CGRect frame = self.bottomView.frame;
        [UIView animateWithDuration:0.5 animations:^{
            frame.origin.y += PickerViewHeight;
            self.bottomView.frame = frame;
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [super setHidden:hidden];
        }];
    }else {
        [super setHidden:hidden];
        __block CGRect frame = self.bottomView.frame;
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
            frame.origin.y -= PickerViewHeight;
            self.bottomView.frame = frame;
        }];
    }
}

- (void)setHidden:(BOOL)hidden comletion:(completionHandle)comletion {
    self.hidden = hidden;
    
    if (comletion) {
        comletion(YES);
    }
}

#pragma mark - showWithText

- (void)showWithMentionText:(NSString *)text {
    __block ZJDatePicker *picker = self;
    [self setHidden:NO comletion:^(BOOL finish) {
        picker.mentionLabel.text = text;
    }];
}

- (void)showWithMentionText:(NSString *)text completion:(completionHandle)completion {
    __block ZJDatePicker *picker = self;
    [self setHidden:NO comletion:^(BOOL finish) {
        picker.mentionLabel.text = text;
        
        completion(YES);
    }];
}

#pragma mark - getter 设置初始值

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
        self.hidden = YES;
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
