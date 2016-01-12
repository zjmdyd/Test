//
//  ZJPickerView.m
//  HeartGuardForDoctor
//
//  Created by hanyou on 15/11/4.
//  Copyright © 2015年 HANYOU. All rights reserved.
//

#import "ZJPickerView.h"

@interface ZJPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIPickerView *pickerView;

@end

#define Alpha 0.4
#define PickerViewHeight 250

@implementation ZJPickerView

@synthesize topViewBackgroundColor = _topViewBackgroundColor;

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

- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView {
    self = [super initWithFrame:frame];
    if (self) {
        [superView addSubview:self];
        [self initSetting];
    }
    
    return self;
}

- (void)initSetting {
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.alpha = 0.0;

    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0];
    self.bgView.alpha = Alpha;
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
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, topView.bounds.size.height, self.bottomView.bounds.size.width, PickerViewHeight - topView.bounds.size.height)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.bottomView addSubview:self.pickerView];
}

- (void)clickButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pickerView:clickedButtonAtIndex:)]) {
        [self.delegate pickerView:self clickedButtonAtIndex:sender.tag];
    }
    
    [self setHid:YES];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component {
    if (self.dataSource && self.numberOfComponents > 0) {
        return [self.pickerView selectedRowInComponent:component];
    }
    return 0;
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    if (self.dataSource && self.numberOfComponents > 0) {
        [self.pickerView selectRow:row inComponent:component animated:animated];
    }
}

#pragma mark - reloadData

- (void)reloadComponent:(NSInteger)component {
    [self.pickerView reloadComponent:component];
}

- (void)reloadAllComponents {
    [self.pickerView reloadAllComponents];
}

#pragma mark - setter

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

- (NSInteger)numberOfComponents {
    return self.pickerView.numberOfComponents;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.dataSource numberOfComponentsInPickerView:self];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.dataSource pickerView:self numberOfRowsInComponent:component];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        [self.delegate pickerView:self didSelectRow:row inComponent:component];
    }
}

- (NSString *)pickerView:(ZJPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
        return [self.delegate pickerView:self titleForRow:row forComponent:component];
    }
    return nil;
}

#pragma mark - touchEvent

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isHidden) {
        [self setHid:YES];
    }
}

@end
