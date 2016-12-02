//
//  DetectionIndexModel.m
//  EquipmentSDK
//  检测指标

//  Created by Barnett Wu on 2016/11/29.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "DetectionIndexModel.h"

@implementation DetectionIndexModel

- (NSString *)description{
    return [NSString stringWithFormat:@"检测项：%@\n检测时间：%@\n检测结果：%@",
            @(self.project),self.detectionDate,self.indicator];
}

@end
