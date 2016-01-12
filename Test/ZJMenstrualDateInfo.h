//
//  ZJMenstrualDateInfo.h
//  ControlTemp
//
//  Created by ZJ on 1/4/16.
//  Copyright © 2016 zjw7sky. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MensesInfoType) {
    MensesInfoTypeOfDefault,        // 无效填充期
    MensesInfoTypeOfLuteal,         // 黄体期
    MensesInfoTypeOfMenstrual,      // 月经期
    MensesInfoTypeOfOvumRelease,    // 排卵期
};

@interface ZJMenstrualDateInfo : NSObject

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign) MensesInfoType type;

/**
 *  是否是今日(now)
 */
@property (nonatomic, assign) BOOL isToDay;

/**
 *  是否是排卵日
 */
@property (nonatomic, assign) BOOL isOvumDay;


/**
 *  排卵概率(当前日期now)
 */
@property (nonatomic, assign) float ovumProbability;


@end
