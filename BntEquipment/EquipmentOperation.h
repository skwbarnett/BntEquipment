//
//  EquipmentOperation.h
//  BntEquipment
//
//  Created by 吴克赛 on 2016/12/21.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PDEquipmentDelegate <NSObject>
@optional
- (void)equipmentGetDataSuccess:(id)dataModel;
@end

@interface EquipmentOperation : NSObject

@property (nonatomic, weak) id<PDEquipmentDelegate>delegate;

@end
