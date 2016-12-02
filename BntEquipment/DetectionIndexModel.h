//
//  DetectionIndexModel.h
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/29.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ProjectType) {
    ProjectTypeBG = 2,  //血糖
    ProjectTypeBUA,     //血尿酸
    ProjectTypeTC,      //胆固醇
    ProjectTypeNone
};

@interface DetectionIndexModel : NSObject

@property (nonatomic, strong) NSString *detectionDate;

@property (nonatomic, assign) ProjectType project;

@property (nonatomic, strong) NSString *indicator;

@end
