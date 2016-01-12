//
//  ZJScrollView.h
//  Test
//
//  Created by ZJ on 1/12/16.
//  Copyright © 2016 ZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJScrollView;

@protocol ZJScrollViewDelegate <NSObject>

- (void)zjScrollView:(ZJScrollView *)zjScrollView didClickButtonAtIndex:(NSInteger)buttongIndex;

@end

@interface ZJScrollView : UIScrollView

- (instancetype)initWithSuperView:(UIView *)view imageNames:(NSArray *)imageNames;

/**
 *  注意代理属性名称,delegate已被占用
 */
@property (nonatomic, weak) id <ZJScrollViewDelegate> scrollDelegate;

/**
 *  是否支持循环滚动:默认为NO
 */
@property (nonatomic, getter=isCycleScrolledEnable) BOOL cycleScrolledEnable;


/**
 *  重新对imageNames赋值,buttomTitle页需要重新赋值
 */
@property (nonatomic, strong) NSArray *imageNames;

/*********************  启动页 ***********************/
///当是启动页时, cycleScrolledEnable应设为NO

@property (nonatomic, getter=isHiddenPageControl) BOOL hiddenPageControl;   // 默认是YES

/**
 *  当bottomTitle.count零时,bottomView为空
 */
@property (nonatomic, strong) NSArray *bottomTitles;
@property (nonatomic, strong) NSArray *bottomTitleColors;                   // 默认都为白色
@property (nonatomic, strong) NSArray *bottomTitleBackgroundColors;         // 默认都为红色

/**
 *  设置当前页的pageControl的颜色:默认为red
 */
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

/**
 *  设置非当前页的pageControl的颜色:默认为lightGray
 */
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;

@end