//
//  ViewController.m
//  Test
//
//  Created by ZJ on 12/30/15.
//  Copyright © 2015 ZJ. All rights reserved.
//

#import "ViewController.h"

#import "ZJMensesInfo.h"
#import "ZJMenstrualDateInfo.h"

#import "ZJPickerView.h"
#import "ZJDatePicker.h"
#import "ZJFooterView.h"

#import "ZJScrollView.h"

#import "TestView.h"
#import "ZJSearchingView.h"

@interface ViewController ()<ZJPickerViewDataSource, ZJPickerViewDelegate, ZJScrollViewDelegate> {
    ZJPickerView *_pickerView;
    NSMutableArray *_values;
    
    ZJDatePicker *_datePicker;
    ZJFooterView *_footView;
    
    TestView *_testView;
    
    ZJSearchingView *_searchView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SEL s = sel_registerName("test7");
    [self performSelector:s withObject:nil afterDelay:0.0];
/*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, 100, 100)];
    label.text = @"刚刚";
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor redColor];
    [self.view.layer addSublayer:label.layer];  //文字不会添加上去
 */
}

- (NSInteger)numberOfComponentsInPickerView:(ZJPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(ZJPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _values.count;
}

- (NSString *)pickerView:(ZJPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%@", _values[row]];
}

- (IBAction)showPickerView:(UIButton *)sender {
    if (_pickerView.isHidden) {
        __weak ZJPickerView *picker = _pickerView;
        [_pickerView showWithMentionText:@"选择" completion:^(BOOL finish) {
            [picker selectRow:3 inComponent:0 animated:YES];
            _pickerView.leftButtonTitleColor = [UIColor orangeColor];
        }];
    }
    if (_datePicker.isHidden) {
        [_datePicker showWithMentionText:@"时间" completion:^(BOOL finish) {
            _datePicker.leftButtonTitleColor = [UIColor greenColor];
        }];
    }
    
    if (_testView) {
        _testView.hidden = !_testView.isHidden;
    }
    
    if (_searchView) {
        _searchView.searching = !_searchView.isSearching;
        
        if (_searchView.isSearching) {
            _searchView.contents = (__bridge id _Nullable)([UIImage imageNamed:@"CALayer"].CGImage);
            _searchView.lineColor = [UIColor blueColor];
            _searchView.lineWidth = 5;
        }else {
            _searchView.contents = @"hah";//(__bridge id _Nullable)([UIImage imageNamed:@"star"].CGImage);
            _searchView.lineColor = [UIColor redColor];
            _searchView.fontSize = 36;
            _searchView.lineWidth = 5;
        }
    }
}

- (void)test1 {
    ZJMensesInfo *info = [[ZJMensesInfo alloc] initWithBeganDate:[NSDate date] mensesDuraton:7 cycle:28];
    info.temps = @[@0, @0];

    for (int i = 0; i < info.mensesInfos.count; i++) {
        ZJMenstrualDateInfo *obj = info.mensesInfos[i];
        NSLog(@"%d, %d, %@, %zd, i = %d, %f", obj.isToDay, obj.isOvumDay, obj.date, obj.type, i, obj.ovumProbability);
    }
}

- (void)test2 {
    _pickerView = [[ZJPickerView alloc] initWithSuperView:self.view dateSource:self delegate:self];

    _values = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [_values addObject:@(i)];
    }
}

- (void)test3 {
    _datePicker = [[ZJDatePicker alloc] initWithSuperView:self.view datePickerMode:UIDatePickerModeDate];
}

- (void)test4 {
    _footView = [[ZJFooterView alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 70) title:@"确定" superView:self.view];
}

- (void)test5 {
    ZJScrollView *sc = [[ZJScrollView alloc] initWithSuperView:self.view imageNames:@[@"1", @"2", @"3"]];
    sc.bottomTitles = @[@"哈哈哈", @"呵呵呵呵"];
    sc.hiddenPageControl = NO;
    sc.cycleScrolledEnable = NO;
    sc.scrollDelegate = self;
}

- (void)zjScrollView:(ZJScrollView *)zjScrollView didClickButtonAtIndex:(NSInteger)buttongIndex {
    NSLog(@"index = %zd", buttongIndex);
    if (buttongIndex == 1) {
        zjScrollView.imageNames = @[@"3", @"2", @"1"];
        zjScrollView.bottomTitles = @[@"哈哈哈", @"呵呵呵呵"];
    }
}

- (void)test6 {
    _testView = [[TestView alloc] initWithFrame:CGRectMake(100, 100, 150, 150)];
    _testView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_testView];
}

- (void)test7 {
    CGImageRef img = [UIImage imageNamed:@"star"].CGImage;
    _searchView = [[ZJSearchingView alloc] initWithFrame:CGRectMake(100, 100, 150, 150) content:(__bridge id)(img)];
    _searchView.clockwise = NO;
    [self.view addSubview:_searchView];
}

/*
- (void)resetValue {
    _ovumDay = nil;
    _mensesDates = nil;
    _ovumDateInfos = nil;
}
 */
/*
排卵概率算法(结果单位:百分比):
周期推算法:占比c1=45%
体温推算法:占比c2=45%
P=P1+P2

周期推算法(结果单位:百分比):
本次月经第一天d1(已知,用户每次输入,或用上次输入根据周期推算,至少有一次输入)
月经周期n(已知,首次必须输入)
排卵日D= d1+n-14
当前日期now
if(|now-D|<=5)
{
    P1=c1-|now-D|*10%
    if(P1<0)
    {
        P1=0%;
    }
}
else
{
    P1=0%;
}
 */
/*
体温推算法(结果单位:百分比):
本次月经第一天d1(同周期推算法)
月经周期n(同周期推算法)
月经开始的每天体温(T1......T15)
月经期平均体温Tavg=avg(T1+T2+T3+T4+T5)
当天体温Tnow
前一天体温Tbefore
排卵概率P1(由周期推算法得出)
span=Tnow-Tbefore;
if(span>0.4)
{
    span=0.4
}
span—;
if(span>0)
{
    P2=P1*(span*3)  [P2>0]
}
else
{
    P2=0%
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
