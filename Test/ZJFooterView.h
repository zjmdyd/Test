//
//  ZJFooterView.h
//  HeartGuardForDoctor
//
//  Created by hanyou on 15/11/2.
//  Copyright © 2015年 HANYOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJFooterView;

@protocol ZJFooterViewDelegate <NSObject>

- (void)footerViewDidClick:(ZJFooterView *)footView;

@end

@interface ZJFooterView : UIView

@property (nonatomic, weak) id <ZJFooterViewDelegate> delegate;

/**
 *  适用于作为tableView的footerView
 */
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

/**
 *  适用于作为vc.view的footerView
 */
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title superView:(UIView *)superView;

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *titleColor;

@end
