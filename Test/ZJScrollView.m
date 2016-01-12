//
//  ZJScrollView.m
//  Test
//
//  Created by ZJ on 1/12/16.
//  Copyright © 2016 ZJ. All rights reserved.
//

#import "ZJScrollView.h"

@interface ZJScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *subviews;

@end

#define Width self.bounds.size.width
#define Height self.bounds.size.height

@implementation ZJScrollView

- (instancetype)initWithSuperView:(UIView *)superView imageNames:(NSArray *)imageNames {
    self = [super initWithFrame:superView.bounds];
    
    if (self) {
        [superView addSubview:self];
        self.imageNames = imageNames;
    }
    return self;
}

#pragma mark - setter

- (void)setImageNames:(NSArray *)imageNames {
    for (id view in self.subviews) {
        [view removeFromSuperview];
    }
    [self.subviews removeAllObjects];
    NSMutableArray *ary = [NSMutableArray arrayWithArray:imageNames];
    if (self.isCycleScrolledEnable) {
        if (ary.count) {
            [ary insertObject:ary.lastObject atIndex:0];
            [ary removeLastObject];
        }
    }
    _imageNames = [ary copy];

    self.contentSize = CGSizeMake(_imageNames.count*Width, 0);
    
    for (int i = 0; i < _imageNames.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_imageNames[i]]];
        iv.frame = CGRectMake(i*Width, 0, Width, Height);
        iv.tag = i;
        [self addSubview:iv];
        [self.subviews addObject:iv];
    }
    
    if (self.isCycleScrolledEnable) {
        [self setContentOffset:CGPointMake(Width, 0) animated:NO];
    }else {
        [self setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    //加入pageController
    if (!self.pageControl) {
        self.delegate = self;
        self.pagingEnabled = YES;

        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, Height-40, Width, 20)];
        self.hiddenPageControl = YES;   // 默认隐藏
        self.pageControl.numberOfPages = self.imageNames.count;
        self.pageControl.userInteractionEnabled = NO;
        self.pageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor;
        self.pageControl.pageIndicatorTintColor = self.pageIndicatorTintColor;
        [self.superview addSubview:self.pageControl];
    }else {
        [self.superview bringSubviewToFront:self.pageControl];
    }
}

- (void)setCycleScrolledEnable:(BOOL)cycleScrolledEnable {
    if (cycleScrolledEnable != self.isCycleScrolledEnable) {
        _cycleScrolledEnable = cycleScrolledEnable;
        
        self.imageNames = [_imageNames mutableCopy];
        if (_cycleScrolledEnable) {
            self.bottomTitles = nil;
            [self resetImageNames];
        }else {
            if (self.bottomTitles.count) {
                self.bottomTitles = [_bottomTitles mutableCopy];
            }
        }
    }
}

#pragma mark - 启动页

/**
 *  设置底部button的title
 *  @param bottomTitles 底部button的titles
 */
- (void)setBottomTitles:(NSArray *)bottomTitles {
    _bottomTitles = bottomTitles;
    
    if (_bottomTitles.count) {
        [self createBottomView];
    }
}

- (void)setHiddenPageControl:(BOOL)hiddenPageControl {
    self.pageControl.hidden = hiddenPageControl;
}

- (UIColor *)currentPageIndicatorTintColor {
    if (!_currentPageIndicatorTintColor) {
        _currentPageIndicatorTintColor = [UIColor redColor];
    }
    
    return _currentPageIndicatorTintColor;
}

- (UIColor *)pageIndicatorTintColor {
    if (!_pageIndicatorTintColor) {
        _pageIndicatorTintColor = [UIColor lightGrayColor];
    }
    
    return _pageIndicatorTintColor;
}

- (void)clickButton:(UIButton *)sender {
    if ([self.scrollDelegate respondsToSelector:@selector(zjScrollView:didClickButtonAtIndex:)]) {
        [self.scrollDelegate zjScrollView:self didClickButtonAtIndex:sender.tag];
    }
}

#pragma mark - getter

- (NSMutableArray *)subviews {
    if (!_subviews) {
        _subviews = [NSMutableArray array];
    }
    
    return _subviews;
}

- (NSArray *)bottomTitleColors {
    if (!_bottomTitleColors) {
        NSMutableArray *ary = [NSMutableArray array];
        for (int i = 0; i < _bottomTitles.count; i++) {
            [ary addObject:[UIColor whiteColor]];
        }
        _bottomTitleColors = [ary copy];
    }
    
    return _bottomTitleColors;
}

- (NSArray *)bottomTitleBackgroundColors {
    if (!_bottomTitleBackgroundColors) {
        NSMutableArray *ary = [NSMutableArray array];
        for (int i = 0; i < _bottomTitles.count; i++) {
            [ary addObject:[UIColor redColor]];
        }
        _bottomTitleBackgroundColors = [ary copy];
    }
    
    return _bottomTitleBackgroundColors;
}

#pragma mark - private method

- (void)createBottomView {
    for (UIImageView *iv in self.subviews) {
        if (iv.tag == self.imageNames.count - 1) {
            iv.userInteractionEnabled = YES;
            CGFloat offsetX = 30;
            CGFloat width = (self.bounds.size.width - offsetX*3)/2;
            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, self.pageControl.frame.origin.y - 50, Width - offsetX*2, 50)];
            [iv addSubview:bottomView];
            for (int i = 0; i < _bottomTitles.count; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.tag = i;
                btn.frame = CGRectMake(i*(width + offsetX), 5, width, 40);
                [btn setTitle:_bottomTitles[i] forState:UIControlStateNormal];
                [btn setTitleColor:self.bottomTitleColors[i] forState:UIControlStateNormal];
                [btn setBackgroundColor:self.bottomTitleBackgroundColors[i]];
                [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
                [bottomView addSubview:btn];
            }
            break;
        }
    }
}

/**
 *  还原到数组初始状态
 */
- (void)resetImageNames {
    NSMutableArray *ary = [NSMutableArray arrayWithArray:_imageNames];
    if (ary.count) {
        [ary addObject:ary.firstObject];
        [ary removeObjectAtIndex:0];
    }
    _imageNames = [ary copy];
}

- (void)setFrame {
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *view = self.subviews[i];
        view.frame = CGRectMake(i*Width, 0, Width, Height);
    }
}

//向右
- (void)pageMoveToRight {
    UIView *tempView = [self.subviews lastObject];
    [self.subviews removeObjectAtIndex:self.subviews.count-1];
    [self.subviews insertObject:tempView atIndex:0];
    [self setFrame];
}

//向左
- (void)pageMoveToLeft {
    UIView *tempView = [self.subviews firstObject];
    [self.subviews removeObjectAtIndex:0];
    [self.subviews insertObject:tempView atIndex:self.subviews.count];
    [self setFrame];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isCycleScrolledEnable == NO) {
        NSInteger index = scrollView.contentOffset.x / Width;
        self.pageControl.currentPage = index;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.isCycleScrolledEnable == NO) {
        return;
    }
    CGFloat pageWidth = scrollView.bounds.size.width;
    
    int page = floor((scrollView.contentOffset.x - pageWidth - pageWidth / 2) / pageWidth) + 1; // 向下取整
    if(page > 0) {              //向左
        [self pageMoveToLeft];
        self.pageControl.currentPage = (++self.pageControl.currentPage)%self.imageNames.count;
    } else if (page < 0) {      //向右

        [self pageMoveToRight];
        self.pageControl.currentPage = (--self.pageControl.currentPage+self.pageControl.numberOfPages)%self.imageNames.count;
    } else {}                   //不变
    
    [scrollView setContentOffset:CGPointMake(pageWidth, 0) animated:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
