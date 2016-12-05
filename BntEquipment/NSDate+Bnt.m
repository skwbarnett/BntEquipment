//
//  NSDate+Bnt.m
//  BntEquipment
//
//  Created by 吴克赛 on 2016/12/5.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "NSDate+Bnt.h"

@implementation NSDate (Bnt)

+ (NSTimeInterval)timenowInterval{
    return [[NSDate date] timeIntervalSince1970];
}

+ (NSTimeInterval)timefromInterval:(NSTimeInterval)timeInterval{
    NSDate *nowDate = [NSDate date];
    return [nowDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}

@end
