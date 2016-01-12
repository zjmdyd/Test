//
//  ZJDatePicker.h
//  SuperGym_Coach
//
//  Created by hanyou on 15/11/25.
//  Copyright © 2015年 hanyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJDatePicker;

@protocol ZJDatePickerDelegate <NSObject>

- (void)datePicker:(ZJDatePicker *)datePicker clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

typedef void(^completionHandle)(BOOL finish);

@interface ZJDatePicker : UIView

@property (nonatomic, weak) id <ZJDatePickerDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)superView datePickerMode:(UIDatePickerMode)mode;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;

@property (nonatomic, assign) UIDatePickerMode datePickerMode;

/**
 *  弹窗顶部view
 */
@property (nonatomic, strong) UIColor *topViewBackgroundColor;

/**
 *  弹窗左边button的titleColor
 */
@property (nonatomic, strong) UIColor *leftButtonTitleColor;

/**
 *  弹窗右边button的titleColor
 */
@property (nonatomic, strong) UIColor *rightButtonTitleColor;

- (void)setHid:(BOOL)hid;
- (void)setHid:(BOOL)hid comletion:(completionHandle)comletion;

- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end
