//
//  CharacteristicResponse.m
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/30.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "CharacteristicResponse.h"

@implementation CharacteristicResponse

#pragma mark - response byte

+ (NSData *)historyDataResponse{
    Byte reg[4];
    reg[0] = 0xa9;
    reg[1] = 0x02;
    reg[2] = 0x51;
    reg[3] = 0x54;
    //    reg[5] = (Byte)(reg[0]^reg[1]^reg[2]^reg[3]^reg[4]);
    NSData *data = [NSData dataWithBytes:reg length:4];
    return data;
}

//- (NSData *)


@end
