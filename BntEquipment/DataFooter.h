//
//  DataFooter.h
//  BntEquipment
//
//  Created by 吴克赛 on 2016/12/5.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DataFooter : UIView

- (void)interactScanDuration:(NSTimeInterval)duration peripheral:(CBPeripheral *)peripheral;

- (void)interactConnectDuration:(NSTimeInterval)duration peripheral:(CBPeripheral *)peripheral;

- (void)interactData:(id)model;

@end
