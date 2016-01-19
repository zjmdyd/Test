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
 *  弹窗顶部view背景色
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

/**
 *  弹窗中间提示框颜色
 */
@property (nonatomic, strong) UIColor *mentionTitleColor;

- (void)setHidden:(BOOL)hidden comletion:(completionHandle)comletion;

/**
 *  弹窗时需要显示提示文字时调用该方法
 *
 *  @param text 显示在弹出框正上方的文字
 */
- (void)showWithMentionText:(NSString *)text;
- (void)showWithMentionText:(NSString *)text completion:(completionHandle)completion;

- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end
