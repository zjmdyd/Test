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

- (NSDateComponents *)components {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    
    return comps;
}

+ (NSDate *)getDateWithDaySpan:(NSInteger)daySpan sinceDate:(NSDate *)date {
    return [NSDate dateWithTimeInterval:24*3600*daySpan sinceDate:date];
}

- (NSInteger)getDaySpanSinceDate:(NSDate *)date {
    float span = [self timeIntervalSinceDate:date] / (3600*24);

    if (span > 0) {
        if (span + 0.5 > ceil(span)) {
            span = ceil(span);
        }
    }else {
        if (span - 0.5 < floorf(span)) {
            span = floorf(span);
        }
    }

    return (NSInteger)span;
}

@end

@interface ZJMensesInfo ()

/**
 *  黄体期持续天数:月经后 一般为2天，根据月经持续时间和前7后8计算
 */
@property (nonatomic, assign) NSInteger lutealDurationAfterMenses;

/**
 *  当月 月经信息总天数
 */
@property (nonatomic, assign) NSInteger mensesTotalDuration;

/**
 *  当日的类型
 */
@property (nonatomic, assign) MensesInfoType mensesInfoTypeOfToday;

/**
 *  排卵日:月经后
 */
@property (nonatomic, strong, readonly) NSDate *ovumDayAfterMenses;

/**
 *  每月的月经信息
 */
@property (nonatomic, strong) NSArray *mensesInfoOfMonth;

@end

#define C1 0.45             //  周期推算法:占比

#define EmptyDuration 3     //  填充的天数
#define MensesDuration 7    //  月经默认持续天数
#define MensesCycle 28      //  月经默认周期
#define OvumDuration 10     //  排卵期默认天数
#define LutealDuration 9    //  黄体期天数:月经前的

@implementation ZJMensesInfo

@synthesize mensesInfos = _mensesInfos;
@synthesize ovumDayAfterMenses = _ovumDayAfterMenses;

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
        _mensesDuration = duration>0 ? duration:MensesDuration;
        _cycle = (cycle>0 && cycle<LutealDuration) ? cycle:MensesCycle;
        _beganDate = [self transformBeganDate:[NSDate getDateWithDaySpan:3 sinceDate:[NSDate date]]];
    }

    return self;
}

- (NSDate *)transformBeganDate:(NSDate *)beganDate {
    if (!beganDate) {
        return [NSDate date];
    }
    
    NSDate *today = [NSDate date];
    NSDateComponents *comp1 = [beganDate components];
    NSDateComponents *comp2 = [today components];
    if (comp1.month != comp2.month && comp1.year == comp2.year) {
        NSInteger span = [today getDaySpanSinceDate:beganDate];
        NSDate *date = [NSDate getDateWithDaySpan:(span/self.cycle)*self.cycle sinceDate:beganDate];
        return [self transformBeganDate:[NSDate getDateWithDaySpan:labs(span)/span*self.cycle sinceDate:date]];
    }
    
    return beganDate;
}

#pragma mark - setter

/**
 重新对_beganDate、_duration、_cycle任一值赋值，都调用resetValue方法
 */
- (void)setBeganDate:(NSDate *)beganDate {
    if (!beganDate) {
        beganDate = [NSDate date];
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
 *  体温数组元素个数:2个,当天体温和前一天体温
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

/**
 *  下一个排卵日D= d1+n-14
 *  概率计算根据这个日期来计算
 */
- (NSDate *)ovumDayAfterMenses {
    if (!_ovumDayAfterMenses) {
        _ovumDayAfterMenses = [NSDate getDateWithDaySpan:self.cycle-14 sinceDate:_beganDate];
    }
    return _ovumDayAfterMenses;
}

/**
 *  前七后八,包含月经当天共9天
 */
- (NSInteger)lutealDurationAfterMenses {
    _lutealDurationAfterMenses = LutealDuration - self.mensesDuration;
    
    return _lutealDurationAfterMenses;
}

- (NSArray *)mensesInfos {
    if (!_mensesInfos) {
        NSMutableArray *ary = [NSMutableArray array];
        NSInteger count = 0;

        // 算出经期(包含经期)后面的总天数,
        if (self.mensesInfoTypeOfToday == MensesInfoTypeOfMenstrual) {                  // 经期
            count = self.mensesDuration + self.lutealDurationAfterMenses + OvumDuration;
        }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfLutealAfterMenses) {    // 黄体期(月经后)
            count = self.mensesDuration + self.lutealDurationAfterMenses + OvumDuration + LutealDuration;
        }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfOvumRelease) {          // 排卵期
            count = self.mensesDuration;
        }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfLutealBeforeMenses) {   // 黄体期(月经前)
            count = self.mensesDuration + self.lutealDurationAfterMenses + OvumDuration;
        }
       
        count += EmptyDuration;
        
        for (int i = 0; i < self.mensesTotalDuration; i++) {
            ZJMenstrualDateInfo *info = [ZJMenstrualDateInfo new];
            [ary addObject:info];
            
            info.date = [NSDate getDateWithDaySpan:(i - (self.mensesTotalDuration - count)) sinceDate:_beganDate];
            if (i < 3 || i >= self.mensesTotalDuration - 3) {
                info.type = MensesInfoTypeOfDefault;
            }else {
                info.type = [self getMensesInfoTypeWithDate:info.date];
            }
            
            if (labs([info.date getDaySpanSinceDate:_beganDate]) == self.cycle-14) {
                info.isOvumDay = YES;
            }
            info.isToDay = [info.date isEqualToDate:[NSDate date]];
        }
        
        _mensesInfos = [ary mutableCopy];
    }
    return _mensesInfos;
}

/**
 *  获取某个日期的MensesType
 */
- (MensesInfoType)getMensesInfoTypeWithDate:(NSDate *)date {
    NSInteger span = [date getDaySpanSinceDate:_beganDate];
    if (span >= 0) {    /// _beganDate --> date，从月经开始时间向后数
        if (span < self.mensesDuration) {
            return MensesInfoTypeOfMenstrual;
        }else if (span < self.mensesDuration + self.lutealDurationAfterMenses) {
            return MensesInfoTypeOfLutealAfterMenses;
        }else if (span < self.mensesDuration + self.lutealDurationAfterMenses + OvumDuration) {
            return MensesInfoTypeOfOvumRelease;
        }else if (span < self.mensesDuration + self.lutealDurationAfterMenses + OvumDuration + LutealDuration) {
            return MensesInfoTypeOfLutealBeforeMenses;
        }else {
            return MensesInfoTypeOfMenstrual;
        }
    }else {         /// date --> _beganDate，从月经开始时间向前数
        NSInteger span2 = labs(span);
        if (span2 <= LutealDuration) {                       // 9
            return MensesInfoTypeOfLutealBeforeMenses;
        }else if (span2 <= LutealDuration + OvumDuration) {  // 19
            return MensesInfoTypeOfOvumRelease;
        }else if (span2 <= LutealDuration + OvumDuration + self.lutealDurationAfterMenses) { // 21
            return MensesInfoTypeOfLutealAfterMenses;
        }else {
            return MensesInfoTypeOfMenstrual;
        }
    }
}

/**
 *  总天数
 */
- (NSInteger)mensesTotalDuration {
    if (_mensesTotalDuration <= 0) {
        if (self.mensesInfoTypeOfToday == MensesInfoTypeOfLutealAfterMenses) {
            _mensesTotalDuration = LutealDuration*2 + self.mensesDuration + OvumDuration + self.lutealDurationAfterMenses;
        }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfOvumRelease) {          /// OK
            _mensesTotalDuration =  self.mensesDuration*2 + self.lutealDurationAfterMenses + OvumDuration + LutealDuration;
        }else if (self.mensesInfoTypeOfToday == MensesInfoTypeOfLutealBeforeMenses) {   /// OK
            _mensesTotalDuration =  self.lutealDurationAfterMenses*2 + OvumDuration*2 + LutealDuration + self.mensesDuration;
        }else {                                                                         /// OK
            _mensesTotalDuration = OvumDuration*2 + LutealDuration +self.lutealDurationAfterMenses + self.mensesDuration;
        }
        
        _mensesTotalDuration += 2*EmptyDuration;
    }
    
    return _mensesTotalDuration;
}

/**
 *  当天的MensesType
 */
- (MensesInfoType)mensesInfoTypeOfToday {
    /// 月经开始时间离今天有几天
    if (_mensesInfoTypeOfToday <= 0) {
        NSInteger span = [_beganDate getDaySpanSinceDate:[NSDate date]];
        if (span > 0) {     // 今天 --> 月经开始时间, 从月经开始时间向后数
            if (span <= LutealDuration) {                           // 9
                _mensesInfoTypeOfToday = MensesInfoTypeOfLutealBeforeMenses;    // 多加一个排卵期
            }else if (span <= LutealDuration + OvumDuration) {      // 19
                _mensesInfoTypeOfToday = MensesInfoTypeOfOvumRelease;
            }else if (span <= LutealDuration + OvumDuration + self.lutealDurationAfterMenses) {
                _mensesInfoTypeOfToday = MensesInfoTypeOfLutealAfterMenses;
                
                NSInteger sp = [_beganDate getDaySpanSinceDate:[NSDate date]];
                if (sp > OvumDuration + LutealDuration) {
                    _beganDate = [NSDate getDateWithDaySpan:-self.cycle sinceDate:_beganDate];
                }
            }else {
                _mensesInfoTypeOfToday = MensesInfoTypeOfMenstrual; /// 出现这种情况:当天是2月1号-7号，began=2月29
                _beganDate = [NSDate getDateWithDaySpan:-self.cycle sinceDate:_beganDate];  // 29号 --> 1号
            }
        }else {             // 经期 --> 今天
            NSInteger sp = labs(span);
            if (sp < self.mensesDuration) {                                         // 7
                _mensesInfoTypeOfToday = MensesInfoTypeOfMenstrual;
            }else if (sp < self.mensesDuration + self.lutealDurationAfterMenses) {  // 9
                _mensesInfoTypeOfToday = MensesInfoTypeOfLutealAfterMenses;
            }else if (sp < self.mensesDuration + self.lutealDurationAfterMenses + OvumDuration) {   // 19
                _mensesInfoTypeOfToday = MensesInfoTypeOfOvumRelease;
                NSInteger span = [_beganDate getDaySpanSinceDate:[NSDate date]];
                if (span < 0) {
                    _beganDate = [NSDate getDateWithDaySpan:self.cycle sinceDate:_beganDate];
                }
            }else if (sp < self.lutealDurationAfterMenses + OvumDuration + LutealDuration) {
                _mensesInfoTypeOfToday = MensesInfoTypeOfLutealBeforeMenses;
            }else {
                _mensesInfoTypeOfToday = MensesInfoTypeOfMenstrual;
                _beganDate = [NSDate getDateWithDaySpan:self.cycle sinceDate:_beganDate];   ///出现这种情况:began在上个月，今天在下个月
            }
        }
    }
    
    return _mensesInfoTypeOfToday;
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
    
    long span = labs([self.ovumDayAfterMenses getDaySpanSinceDate:[NSDate date]]);
    if (span <= OvumDuration) {
        P1 = C1 - span*0.1;
        if (P1 <= FLT_EPSILON) {
            P1 = 0.01;
        }
    }else {
        P1 = 0.01;
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
    _ovumDayAfterMenses = nil;
    _mensesInfos = nil;
    _mensesTotalDuration = 0;
    _mensesInfoTypeOfToday = MensesInfoTypeOfDefault;
}

#pragma mark - 每月的月经信息

+ (NSArray *)mensesMonthInfoWithBeganDate:(NSDate *)date mensesDuraton:(NSInteger)duration cycle:(NSInteger)cycle {
    ZJMensesInfo *info =  [[ZJMensesInfo alloc] init];
    info.mensesDuration = duration>0 ? duration:MensesDuration;
    info.cycle = (cycle>0 && cycle<LutealDuration) ? cycle:MensesCycle;
    info.beganDate = [NSDate getDateWithDaySpan:-250 sinceDate:[NSDate date]];//date?:[NSDate date];

    return info.mensesInfoOfMonth;
}

- (NSArray *)mensesInfoOfMonth {
    if (!_mensesInfoOfMonth) {
        NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSRange range = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:_beganDate];
        NSDateComponents *com = [_beganDate components];
        NSMutableArray *ary = [NSMutableArray array];
        for (int i = 0; i < range.length; i++) {
            ZJMenstrualDateInfo *info = [ZJMenstrualDateInfo new];
            [ary addObject:info];
            
            com.day = i+2;  // 加1差1天 不知道为什么加2就对了
            info.date = [cal dateFromComponents:com];
            info.type = [self getMensesInfoTypeWithDate:info.date];
            
            if (labs([info.date getDaySpanSinceDate:_beganDate]) == self.cycle-14) {
                info.isOvumDay = YES;
            }
            info.isToDay = [info.date isEqualToDate:[NSDate date]];
        }
        _mensesInfoOfMonth = [ary mutableCopy];
    }
    
    return _mensesInfoOfMonth;
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
