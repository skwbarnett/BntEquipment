//
//  ViewController.m
//  BntEquipment
//
//  Created by 吴克赛 on 2016/12/21.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "ViewController.h"
#import "EquipmentOperation.h"

@interface ViewController ()

@property (nonatomic, strong) EquipmentOperation *equipOperation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.equipOperation = [[EquipmentOperation alloc] init];

}

@end
