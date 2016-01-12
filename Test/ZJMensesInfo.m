//
//  ZJMensesInfo.m
//  Test
//
//  Created by ZJ on 12/30/15.
//  Copyright © 2015 ZJ. All rights reserved.
//

#import "ZJMensesInfo.h"
#import "ZJMenstrualDateInfo.h"

@implementation NSDate (CompareDate)

- (BOOL)isEqualToDate:(NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    NSString *str1 = [format stringFromDate:self];
    NSString *str2 = [format stringFromDate:date];
    if ([str1 isEqualToString:str2]) {
        return YES;
    }
    
    return NO;
}

+ (NSDateComponents *)getComponentsWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    return comps;
}

+ (NSDate *)getDateWithDaySpan:(NSInteger)daySpan sinceDate:(NSDate *)date {
    return [NSDate dateWithTimeInterval:24*3600*daySpan sinceDate:date];
}

- (NSInteger)getDaySpanSinceDate:(NSDate *)date {
    return [self timeIntervalSinceDate:date] / (3600*24);
}

@end

@interface ZJMensesInfo ()

/**
 *  黄体期持续天数
 */
@property (nonatomic, assign) NSInteger lutealDuration;

/**
 *  当月 月经信息总天数
 */
@property (nonatomic, assign) NSInteger mensesTotalDuration;

/**
 *  排卵日
 */
@property (nonatomic, strong, readonly) NSDate *ovumDay;

/**
 *  当日的类型
 */
@property (nonatomic, assign) MensesInfoType mensesInfoTypeOfToday;

@end

#define C1 0.45             //  周期推算法:占比

#define EmptyDuration 3     //  填充的天数
#define MensesDuration 7    //  月经默认持续天数
#define MensesCycle 28      //  月经默认周期
#define OvumDuration 5      //  排卵期默认天数

@implementation ZJMensesInfo

@synthesize mensesInfos = _mensesInfos;
@synthesize ovumDay = _ovumDay;

#pragma mark -  初始化方法

- (instancetype)init {
    self = [super init];
    if (self) {
        /*
            该对象的默认值设置不能用属性赋值,只能使用实例变量,因为调用setter方法会调用resetValue方法
         */
        _beganDate = [NSDate date];
        _mensesDuration = MensesDuration;
        _cycle = MensesCycle;
    }
    return self;
}

- (ZJMensesInfo *)initWithBeganDate:(NSDate *)beganDate mensesDuraton:(NSInteger)duration cycle:(NSInteger)cycle {
    self = [super init];
    if (self) {
        if (beganDate) {
            _beganDate = [NSDate getDateWithDaySpan:-8 sinceDate:[NSDate date]];//beganDate;//
        }else {
            _beganDate = [NSDate date];
        }
        
        if (duration > 0) {
            _mensesDuration = duration;
        }else {
            _mensesDuration = MensesDuration;
        }

        if (cycle > 0) {
            _cycle = cycle;
        }else {
            _cycle = MensesCycle;
        }
    }
    
    return self;
}

#pragma mark - setter

/**
    重新对_beganDate、_duration、_cycle任一值赋值，都调用resetValue方法
 */
- (void)setBeganDate:(NSDate *)beganDate {
    if (!beganDate) {
        _beganDate = [NSDate date];
    }
    _beganDate = beganDate;
    
    [self resetValue];
}

- (void)setMensesDuration:(NSInteger)mensesDuration {
    if (mensesDuration <= 0) {
        mensesDuration = MensesDuration;
    }
    _mensesDuration = mensesDuration;
    
    [self resetValue];
}

- (void)setCycle:(NSInteger)cycle {
    if (cycle <= 0) {
        cycle = MensesCycle;
    }
    _cycle = cycle;

    [self resetValue];
}

/**
 *  体温数组元素个数2个,当天体温和前一天体温
 *  @param temps 根据体温算出排卵概率
 */
- (void)setTemps:(NSArray *)temps {
    _temps = temps;
    
    if (_temps.count >= 2) {
        for (ZJMenstrualDateInfo *info in self.mensesInfos) {
            if (info.isToDay) {
                info.ovumProbability = [self getOvumProbability];
                break;
            }
        }
    }
}

#pragma mark - getter

- (NSArray *)mensesInfos {
    if (!_mensesInfos) {
        NSMutableArray *ary = [NSMutableArray array];
        
        for (int i = 0; i < self.mensesTotalDuration; i++) {
            ZJMenstrualDateInfo *info = [ZJMenstrualDateInfo new];
            [ary addObject:info];
            
            NSInteger count = 0;
            if (self.mensesInfoTypeOfToday == MensesInfoTypeOfMenstrual) {      // 经期
                count = _mensesDuration + OvumDuration + self.lutealDuration;
            }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfLuteal) {   // 黄体期
                count = _mensesDuration + OvumDuration;
            }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfOvumRelease) {  // 排卵期
                count = _mensesDuration + OvumDuration + self.lutealDuration + _mensesDuration;
            }
            
            count += EmptyDuration;
            info.date = [NSDate getDateWithDaySpan:(i - (self.mensesTotalDuration - count)) sinceDate:_beganDate];
            if (i < 3 || i >= self.mensesTotalDuration - 3) {
                info.type = MensesInfoTypeOfDefault;
            }else {
                info.type = [self getMensesInfoTypeWithDate:info.date];
            }
            info.isOvumDay = [info.date isEqualToDate:self.ovumDay];
            info.isToDay = [info.date isEqualToDate:[NSDate date]];
        }
        
        _mensesInfos = [ary copy];
    }
    return _mensesInfos;
}

/**
 *  获取类型
 */
- (MensesInfoType)getMensesInfoTypeWithDate:(NSDate *)date {
    NSInteger span = [date getDaySpanSinceDate:_beganDate] % (_mensesDuration + self.lutealDuration + OvumDuration);
    if (span >= 0) {
        if (span < _mensesDuration) {
            return MensesInfoTypeOfMenstrual;
        }else if (span < _mensesDuration + OvumDuration) {
            return MensesInfoTypeOfOvumRelease;
        }else {
            return MensesInfoTypeOfLuteal;
        }
    }else {
        NSInteger span2 = labs(span);
        if (span2 <= self.lutealDuration) {
            return MensesInfoTypeOfLuteal;
        }else if (span2 <= self.lutealDuration + OvumDuration) {
            return MensesInfoTypeOfOvumRelease;
        }else {
            return MensesInfoTypeOfMenstrual;
        }
    }
}

- (NSInteger)lutealDuration {
    if (_lutealDuration <= 0) {
        _lutealDuration = _cycle - _mensesDuration - OvumDuration;
    }
    return _lutealDuration;
}

/**
 *  总天数
 */
- (NSInteger)mensesTotalDuration {
    if (_mensesTotalDuration <= 0) {
        if (self.mensesInfoTypeOfToday == MensesInfoTypeOfOvumRelease) {
            _mensesTotalDuration = (EmptyDuration + _mensesDuration + self.lutealDuration) * 2 + OvumDuration;
        }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfLuteal) {
            _mensesTotalDuration = (EmptyDuration + _mensesDuration + OvumDuration) * 2 + self.lutealDuration;
        }else {
            _mensesTotalDuration = (EmptyDuration + self.lutealDuration + OvumDuration) * 2 + _mensesDuration;
        }
    }
    return _mensesTotalDuration;
}

- (MensesInfoType)mensesInfoTypeOfToday {
    NSInteger span = [_beganDate getDaySpanSinceDate:[NSDate date]] % (_mensesDuration + self.lutealDuration + OvumDuration); // 月经开始时间离今天有几天
    if (span > 0) {     // 今天 --> 月经开始时间
        if (span < self.lutealDuration) {
            _mensesInfoTypeOfToday = MensesInfoTypeOfLuteal;
        }else if (span < self.lutealDuration + OvumDuration) {
            _mensesInfoTypeOfToday = MensesInfoTypeOfOvumRelease;
        }
    }else {             // 经期 --> 今天
        NSInteger sp = labs(span);
        if (sp < _mensesDuration) {
            _mensesInfoTypeOfToday = MensesInfoTypeOfMenstrual;
        }else if (sp < _mensesDuration + OvumDuration) {
            _mensesInfoTypeOfToday = MensesInfoTypeOfOvumRelease;
        }else {
            _mensesInfoTypeOfToday = MensesInfoTypeOfLuteal;
        }
    }
    
    return _mensesInfoTypeOfToday;
}

- (NSDate *)ovumDay {
    if (!_ovumDay) {
        _ovumDay = [NSDate getDateWithDaySpan:_mensesDuration + OvumDuration/2 sinceDate:_beganDate];
    }
    return _ovumDay;
}

/**
 *  @param date  排卵期内某日的date
 *  @param index 计算P2的时候需要, 计算P1不需要
 *
 *  @return P1 + P2
 */
- (float)getOvumProbability {
    float P1 = [self getCycleProbility];                        // 根据排卵周期推算
    float P2 = [self getTempProbilityWithCycleProbility:P1];    // 根据体温推算
    
    return P1 + P2;
}

- (float)getCycleProbility {
    float P1 = 0;
    
    NSDateComponents *comps = [NSDate getComponentsWithDate:[NSDate date]];
    NSDateComponents *compsOvum = [NSDate getComponentsWithDate:self.ovumDay];
    
    long span = labs(comps.day - compsOvum.day);
    if (span <= OvumDuration) {
        P1 = C1 - span*0.1;
        if (P1 < FLT_EPSILON) {
            return 0;
        }
    }
    
    return P1;
}

/**
 *  当天体温Tnow, 前一天体温Tbefore
 */
- (float)getTempProbilityWithCycleProbility:(float)P1 {
    float P2 = 0;
    
    float tBefore = [_temps[0] floatValue];
    float tNow = [_temps[1] floatValue];
    float span = tNow - tBefore;
    
    if (span > 0.4) {
        span = 0.4;
    }
    span -= 0.1;
    if (span > 0) {
        P2 = P1*(span*3);
    }
    
    return P2;
}

- (void)resetValue {
    _ovumDay = nil;
    _mensesInfos = nil;
    _lutealDuration = 0;
    _mensesTotalDuration = 0;
}

/*
排卵概率算法(结果单位:百分比):
周期推算法:占比c1=45%
体温推算法:占比c2=45%
P=P1+P2

周期推算法(结果单位:百分比):
本次月经第一天d1(已知,用户每次输入,或用上次输入根据周期推算,至少有一次输入)
月经周期n(已知,首次必须输入)
排卵日D= d1+n-14
当前排卵日期now
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
 span = Tnow - Tbefore;
 if(span>0.4)
 {
    span=0.4
 }
 span—;
 if(span>0)
 {
    P2 = P1*(span*3)  [P2 > 0]
 }
 else
 {
    P2=0%
 }
 */
@end
