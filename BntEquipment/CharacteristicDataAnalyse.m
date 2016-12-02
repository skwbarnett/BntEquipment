//
//  CharacteristicDataAnalyse.m
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/29.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "CharacteristicDataAnalyse.h"
#import "NSString+Bnt.h"
#import "NSData+Bnt.h"
#import "DetectionIndexModel.h"


@implementation CharacteristicDataAnalyse

+ (instancetype)analyseForObject:(id)object{
    CharacteristicDataAnalyse *analyse = [[CharacteristicDataAnalyse alloc] init];
    analyse.delegate = object;
    
    return analyse;
}

- (void)readValueAnalyse:(NSData *)data{
    NSString *hexStr = [data convertDataToHexStr];
    
//    NSMutableArray *strMArr = [hexStr stringCarveBy2Character];
    CharacteristicDataAnalyseResult result = [self resultTypeAnalyse:hexStr];
    if (result == CharacteristicDataAnalyseResultSuccess){
        DetectionIndexModel *model = [[DetectionIndexModel alloc] init];
        model.project = [self projectAnalyse:hexStr];
        model.indicator = [self indicatorAnalyse:hexStr];
        model.detectionDate = [self dateAnalyse:hexStr];
        if([self.delegate respondsToSelector:@selector(dataAnalyseSuccessWithData:)]) {
            [self.delegate dataAnalyseSuccessWithData:model];
        }
    }else if([self.delegate respondsToSelector:@selector(dataAnalyseFailure)]){
        [self.delegate dataAnalyseFailure];
    }
}

- (CharacteristicDataAnalyseResult)resultTypeAnalyse:(NSString *)dataStr{
    if (dataStr.length > 28 && [[dataStr substringWithRange:NSMakeRange(0, 2)] isEqual:@"a9"]) {
        return CharacteristicDataAnalyseResultSuccess;
    }
    return CharacteristicDataAnalyseResultUnRegular;
}

- (DetectionIndexModel *)detectionIndicatorAnalyse:(NSString *)dataStr{
    DetectionIndexModel *model = [[DetectionIndexModel alloc] init];
    
    return model;
}

#pragma mark - indicator analyse
- (NSString *)dateAnalyse:(NSString *)dataStr{
    NSString *dateStr = [dataStr substringWithRange:NSMakeRange(10, 12)];
    NSMutableArray *strMArr = [dateStr stringCarveBy2Character];
    NSString *year = [@"20" stringByAppendingString:[strMArr[0] hexSwitchString2Char]];
    NSString *month = [strMArr[1] hexSwitchString2Char];
    NSString *day = [strMArr[2] hexSwitchString2Char];
    NSString *hour = [strMArr[3] hexSwitchString2Char];
    NSString *minute = [strMArr[4] hexSwitchString2Char];
    NSString *second = [strMArr[5] hexSwitchString2Char];
    NSString *formatDate = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",year,month,day,hour,minute,second];
    return formatDate;
}

- (NSString *)indicatorAnalyse:(NSString *)dataStr{
    NSString *indicatorStr = [[dataStr substringWithRange:NSMakeRange(6, 4)] hexSwitchString];
    float indicator_f = (indicatorStr.integerValue / 100.0);
    return [NSString stringWithFormat:@"%.2f",indicator_f];
}

- (ProjectType)projectAnalyse:(NSString *)dataStr{
    NSString *projectStr = [dataStr substringWithRange:NSMakeRange(22, 2)];
    if ([projectStr isEqualToString:@"a2"]) {
        return ProjectTypeBG;
    }else if ([projectStr isEqualToString:@"a3"]) {
        return ProjectTypeBUA;
    }else if ([projectStr isEqualToString:@"a4"]) {
        return ProjectTypeTC;
    }
    return ProjectTypeNone;
}


@end
