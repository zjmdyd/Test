//
//  ZJPickerView.h
//  HeartGuardForDoctor
//
//  Created by hanyou on 15/11/4.
//  Copyright © 2015年 HANYOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJPickerView;

@protocol ZJPickerViewDataSource <NSObject>

@required

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(ZJPickerView *)pickerView;

// returns the # of rows in each component..
- (NSInteger)pickerView:(ZJPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

@protocol ZJPickerViewDelegate <NSObject>

@optional

- (NSString *)pickerView:(ZJPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (void)pickerView:(ZJPickerView *)pickerView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)pickerView:(ZJPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

typedef void(^completionHandle)(BOOL finish);

@interface ZJPickerView : UIView

@property (nonatomic, weak) id <ZJPickerViewDataSource> dataSource;
@property (nonatomic, weak) id <ZJPickerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView;

@property(nonatomic, readonly) NSInteger numberOfComponents;

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

- (void)reloadComponent:(NSInteger)component;
- (void)reloadAllComponents;

- (NSInteger)selectedRowInComponent:(NSInteger)component;
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;

@end


