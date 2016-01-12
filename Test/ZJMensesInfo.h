//
//  ZJMensesInfo.h
//  Test
//
//  Created by ZJ on 12/30/15.
//  Copyright © 2015 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  月经
 */
@interface ZJMensesInfo : NSObject

@property (nonatomic, strong) NSDate *beganDate;        // 开始时间(月经第1天)
@property (nonatomic, assign) NSInteger mensesDuration; // 持续时间
@property (nonatomic, assign) NSInteger cycle;          // 月经周期

/**
 *  @param beganDate 月经开始时间
 *  @param duration  月经持续时间
 *  @param cycle     月经周期
 */
- (ZJMensesInfo *)initWithBeganDate:(NSDate *)beganDate mensesDuraton:(NSInteger)duration cycle:(NSInteger)cycle;

@property (nonatomic, strong, readonly) NSArray *mensesInfos;

/**
 *  体温数组:前一天和当天的体温, 数组元素个数 = 2个
 */
@property (nonatomic, strong) NSArray *temps;

@end

/*
 使用
ZJMensesInfo *info = [[ZJMensesInfo alloc] initWithBeganDate:[NSDate date] mensesDuraton:7 cycle:28];
info.temps = @[@38, @39];

for (int i = 0; i < info.mensesInfos.count; i++) {
    ZJMenstrualDateInfo *obj = info.mensesInfos[i];
    NSLog(@"%d, %d, %@, %f, %zd", obj.isToDay, obj.isOvumDay, obj.date, obj.ovumProbability, obj.type);
}
 */