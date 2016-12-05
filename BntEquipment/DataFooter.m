//
//  DataFooter.m
//  BntEquipment
//
//  Created by 吴克赛 on 2016/12/5.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "DataFooter.h"
#import "DetectionIndexModel.h"
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

@interface DataFooter ()

@property (nonatomic, strong) UILabel *footerLab_data;

@property (nonatomic, strong) UILabel *footerLab_connect;

@end

@implementation DataFooter

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupViews];
    }
    return self;
}

- (void)setupViews{
    [self addSubview:self.footerLab_data];
    [self addSubview:self.footerLab_connect];
}

- (void)interactScanDuration:(NSTimeInterval)duration peripheral:(CBPeripheral *)peripheral{
    NSString *scan = [NSString stringWithFormat:@"扫描时间：%.8f s\nid:%@",
                      duration,peripheral.identifier];
    _footerLab_connect.text = scan;
}

- (void)interactConnectDuration:(NSTimeInterval)duration peripheral:(CBPeripheral *)peripheral{
    NSString *scan = [NSString stringWithFormat:@"连接时间：%.8f s\nid:%@",
                      duration,peripheral.identifier];
    _footerLab_connect.text = scan;
}

- (void)interactData:(id)model{
    NSString *project;
    DetectionIndexModel *detection = (DetectionIndexModel *)model;
    switch (detection.project) {
        case 2:
            project = @"血糖";
            break;
        case 3:
            project = @"血尿酸";
            break;
        case 4:
            project = @"胆固醇";
            break;
            
        default:
            break;
    }
    [_footerLab_data setText:[NSString stringWithFormat:@"检测项：%@\n检测时间：%@\n检测结果：%@"
                                    ,project,detection.detectionDate,detection.indicator]];
}

- (UILabel *)footerLab_connect{
    if (_footerLab_connect == nil) {
        _footerLab_connect = [[UILabel alloc] init];
        _footerLab_connect.textAlignment = NSTextAlignmentCenter;
        _footerLab_connect.backgroundColor = [UIColor lightGrayColor];
        _footerLab_connect.numberOfLines = 0;
        _footerLab_connect.frame = CGRectMake(0, 150, SCREEN_WIDTH, 80);
    }
    return _footerLab_connect;
}

- (UILabel *)footerLab_data{
    if (_footerLab_data == nil) {
        _footerLab_data = [[UILabel alloc] init];
        _footerLab_data.backgroundColor = [UIColor grayColor];
        _footerLab_data.textAlignment = NSTextAlignmentCenter;
        _footerLab_data.frame = CGRectMake(0, 0, SCREEN_WIDTH, 150);
        _footerLab_data.numberOfLines = 0;
    }
    return _footerLab_data;
}

@end
