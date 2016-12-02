//
//  CharacteristicDataAnalyse.h
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/29.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CharacteristicDataAnalyseResult) {
    CharacteristicDataAnalyseResultUnRegular,
    CharacteristicDataAnalyseResultSuccess,
    CharacteristicDataAnalyseResultFailure,
};

//typedef void(^dataAnalyseComplete)(CharacteristicDataAnalyseResult result, NSMutableArray *dataMArr);

@protocol CharacteristicDataAnalyseDelegete <NSObject>

@optional
- (void)dataAnalyseSuccessWithData:(id)dataModel;

- (void)dataAnalyseFailure;

@end

@interface CharacteristicDataAnalyse : NSObject


- (void)readValueAnalyse:(NSData *)data;

+ (instancetype)analyseForObject:(id)object;



@property (nonatomic, weak) id<CharacteristicDataAnalyseDelegete>delegate;


@end
