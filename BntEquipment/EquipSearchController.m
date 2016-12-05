//
//  EquipSearchController.m
//  EquipmentSDK
//
//  Created by Barnett Wu on 2016/11/22.
//  Copyright © 2016年 Barnett Wu. All rights reserved.
//

#import "EquipSearchController.h"
#import "SearchTableViewCell.h"
#import "CharacteristicDataAnalyse.h"
#import "CharacteristicResponse.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSString+Bnt.h"
#import "DetectionIndexModel.h"
#import "MBProgressHUD+Bnt.h"
#import "NSDate+Bnt.h"
#import "DataFooter.h"

#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:\n%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height


@interface EquipSearchController ()<CBCentralManagerDelegate, CBPeripheralDelegate, CharacteristicDataAnalyseDelegete>

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSMutableArray *peripheralMArr;// all

@property (nonatomic, strong) NSMutableArray *targetPrpMArr;//  目标prp

@property (nonatomic, strong) NSMutableArray *scanPrpMArr;//    待识别prp

@property (nonatomic, strong) CBCharacteristic *readCharacteristic;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@property (nonatomic, strong) CBPeripheral *tagPeripheral;

@property (nonatomic, strong) UIButton *scanButton;

@property (nonatomic, strong) UIButton *cutButton;

@property (nonatomic, assign) NSInteger command;//  1001 scan 1002 analyse

@property (nonatomic, strong) DataFooter *datafooter;

//  时间点
@property (nonatomic, assign) NSTimeInterval startConnectInterval;

@property (nonatomic, assign) NSTimeInterval didConnectDuration;

@property (nonatomic, assign) NSTimeInterval startScanInterval;

@property (nonatomic, assign) NSTimeInterval didScanDuration;

@end

@implementation EquipSearchController

static NSString *const cellid = @"cellid";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:cellid];
    [self setupSubviews];
}

- (void)setupSubviews{
    [self.navigationController.view addSubview:self.scanButton];
    [self.navigationController.view addSubview:self.cutButton];
    [self.navigationController.view addSubview:self.datafooter];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
    self.command = 1001;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
//    int j = -1;
//    for (int i = 0 ; i < self.peripheralMArr.count; i ++) {
//        CBPeripheral *per = self.peripheralMArr[i];
//        if ([per.identifier isEqual:peripheral.identifier]) {
//            j = i;
//            break;
//        }
//    }
    //    if (j == -1) {
    //    }
    if (![self.peripheralMArr containsObject:peripheral]) {
        [self.peripheralMArr addObject:peripheral];
//        [self.tableView reloadData]; 
        [_centralManager connectPeripheral:peripheral options:nil];
//        NSLog(@"\ncentral : %@ \nperipheral : %@ \nadvertisement : %@",central, peripheral, advertisementData);
    }
}

//  链接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@">>>设备连接成功name:\n%@",peripheral.name);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    if (peripheral == _tagPeripheral) {
        [MBProgressHUD bnt_showMessage:@"设备已连接"];
    }
}
//  链接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}
//  断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    if (peripheral == _tagPeripheral) {
        [MBProgressHUD bnt_showMessage:@"设备已断开"];
    }
}

//  discovery service
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@">>>扫描到服务：%@",peripheral.services);
    
    if (error) {
        
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        
        /*
         * 扫描每个服务的 service  进而获取 characteristics
         */
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//  discovery characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    NSInteger target = -1;
    if ([service.UUID.UUIDString isEqualToString:@"180A"]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A29"]) {
                [peripheral readValueForCharacteristic:characteristic];
                [self.scanPrpMArr addObject:peripheral];
                target = 1;
            }
        }
    }
    if (target == -1) {
        if (![self.scanPrpMArr containsObject:peripheral]) {
            [_centralManager cancelPeripheralConnection:peripheral];
        }
    }

    /*
     *    读取Characteristic
     */
/*
    for (CBCharacteristic *Characteristic in service.characteristics) {
        
//        NSLog(@"\n*--* service:%@\n*--* characteristic:%@",service.UUID,Characteristic.UUID);
//        if ([Characteristic..UUID.UUIDString isEqualToString:@"2A29"]) {//Manufacturer Name String
        [peripheral readValueForCharacteristic:Characteristic];
        [peripheral setNotifyValue:YES forCharacteristic:Characteristic];
        self.readCharacteristic = Characteristic;
        self.tagPeripheral = peripheral;
*/
        /*
        if ([service.UUID.UUIDString isEqualToString:@"FFE0"]) {
//            NSLog(@"\nSeverice = %@\nUUIDString = %@\nUUIDDescrption = %@", Characteristic.service.UUID.UUIDString, Characteristic.UUID.UUIDString,Characteristic.UUID.description);
            [peripheral readValueForCharacteristic:Characteristic];
            [peripheral discoverDescriptorsForCharacteristic:Characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:Characteristic];
            self.readCharacteristic = Characteristic;
            self.tagPeripheral = peripheral;
        }
        if ([service.UUID.UUIDString isEqualToString:@"FFE5"]) {
            [peripheral readValueForCharacteristic:Characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:Characteristic];
            self.writeCharacteristic = Characteristic;
        }
    }
         */
    
    
//    if ([service.UUID.UUIDString isEqualToString:@"FFE0"]) {
//        for (CBCharacteristic *characteristic in service.characteristics){
//            [peripheral readValueForCharacteristic:characteristic];
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//        }
//    }
    
    /*
     *  读取 Characteristic 的 Descriptors
     *
     */
    
//    for (CBCharacteristic *Characteristic in service.characteristics) {
////        Characteristic.service.characteristics
////        if ([Characteristic.UUID.description isEqualToString:@"System ID"]) {
//            [peripheral discoverDescriptorsForCharacteristic:Characteristic];
////        }
//    }
}

//获取charateristic的value

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *characteristicUTFString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSString *characValueHex = [NSString convertDataToHexStr:characteristic.value];
    
    NSLog(@"\n>>>characteristic : %@\n>>>characteristic-UTF8 : %@\n>>>characteristic-value : %@\n>>>characValueHex : %@\n>>>propertise: %lu",characteristic.UUID.UUIDString,characteristicUTFString,characteristic.value,characValueHex,(unsigned long)characteristic.properties);
    
//    if ([characteristic.UUID.UUIDString isEqualToString:@"FFE4"]&&
//        [characteristicUTFString isEqualToString:@""]) {
//        if (characteristic) {
//
//        }
//    }
    
    if ([characteristic.UUID.UUIDString isEqualToString:@"2A29"]){
        if ([characteristicUTFString isEqualToString:@"SZ RF STAR CO.,LTD.\0"]) {
            if (_command == 1001) {
                
                [self reloadPeripheal:peripheral];
            }
            else if (_command == 1002){
                [self readIndicatorCharacteristicValue:peripheral];
            }
        }else{
            [_centralManager cancelPeripheralConnection:peripheral];
        }
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"FFE4"]){
        [self analyseIndicatorCharacteristicValue:characteristic];
    }

}

//搜索到Characteristic的Descriptors
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    for (CBDescriptor *des in characteristic.descriptors) {
        
//        NSLog(@"\n>>>descriptor:%@\n>>>characteristic:%@",des.UUID,characteristic.UUID);
        [peripheral readValueForDescriptor:des];
    }
}

//获取 Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
//    NSLog(@"\n<<<characteristic uuid:%@ \n<<<value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    NSLog(@"%@\nerror = %@",characteristic,error);
}

//写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value
{
    
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast                                              = 0x01,
     CBCharacteristicPropertyRead                                                   = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                   = 0x04,
     CBCharacteristicPropertyWrite                                                  = 0x08,
     CBCharacteristicPropertyNotify                                                 = 0x10,
     CBCharacteristicPropertyIndicate                                               = 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites                              = 0x40,
     CBCharacteristicPropertyExtendedProperties                                     = 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)  = 0x200
     };
     
     */
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic
{
    
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//  蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%@",central);
    switch (central.state) {
        
        case CBManagerStateUnknown:
            break;
        case CBManagerStateResetting:
            break;
        case CBManagerStateUnsupported:
            break;
        case CBManagerStateUnauthorized:
            break;
        case CBManagerStatePoweredOff:
//            [self poweredOnalert];
            break;
        case CBManagerStatePoweredOn:
            self.startScanInterval = [NSDate timenowInterval];
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Event Response
//  刷新设备
- (void)scanAction:(UIButton *)button{
    _command = 1001;
    
    self.startScanInterval = [NSDate timenowInterval];
    [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
}

- (void)reloadPeripheal:(CBPeripheral *)peripheral{
    if (![self.targetPrpMArr containsObject:peripheral]) {
        self.didScanDuration = [NSDate timefromInterval:self.startScanInterval];
        [self.targetPrpMArr addObject:peripheral];
        [_centralManager cancelPeripheralConnection:peripheral];
        [self.tableView reloadData];
        [self.datafooter interactScanDuration:self.didScanDuration peripheral:peripheral];
    }
}

//  接收数据
- (void)readIndicatorCharacteristicValue:(CBPeripheral *)peripheral{
    self.didScanDuration = [NSDate timefromInterval:self.startConnectInterval];
    [self.datafooter interactConnectDuration:_didScanDuration peripheral:peripheral];
    self.tagPeripheral = peripheral;
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:@"FFE0"]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:@"FFE4"]) {
                    self.readCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (void)analyseIndicatorCharacteristicValue:(CBCharacteristic *)characteristic{
    //  read value analyse
    CharacteristicDataAnalyse *analyse = [CharacteristicDataAnalyse analyseForObject:self];
    [analyse readValueAnalyse:characteristic.value];
}

//  断开连接
- (void)disconnectPeripheral{
    [_centralManager cancelPeripheralConnection:_tagPeripheral];
}

- (void)poweredOnalert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"蓝牙未打开" message:@"请到“设置”-“蓝牙”打开蓝牙" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"知道了"
                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                  
                              }];
    /*
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"蓝牙未打开" message:@"请打开蓝牙" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"设置蓝牙"style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  
                                          NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                          if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                              [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success) {
                                                  
                                              }];
                                          }
                              }];
    */
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:^{
    }];
}

#pragma mark - CharacteristicData Analyse Delegete

- (void)dataAnalyseSuccessWithData:(id)dataModel{
    DetectionIndexModel *model = (DetectionIndexModel *)dataModel;
//    [self.tagPeripheral setNotifyValue:NO forCharacteristic:self.readCharacteristic];
//    [self.tagPeripheral writeValue:[CharacteristicResponse historyDataResponse] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"%@",model);
//    NSString *project;
//    switch (model.project) {
//        case 2:
//            project = @"血糖";
//            break;
//        case 3:
//            project = @"血尿酸";
//            break;
//        case 4:
//            project = @"胆固醇";
//            break;
//            
//        default:
//            break;
//    }
//   [MBProgressHUD bnt_showMessage:[NSString stringWithFormat:@"检测项：%@\n检测时间：%@\n检测结果：%@"
//                                   ,project,model.detectionDate,model.indicator]];
    [self.datafooter interactData:model];
}

- (void)dataAnalyseFailure{
    NSLog(@"非标数据");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.peripheralMArr.count;
    return self.targetPrpMArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    [cell interactData:self.targetPrpMArr index:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    CBPeripheral *peripheral = self.targetPrpMArr[indexPath.row];
    for (CBPeripheral *prp in self.targetPrpMArr) {
        if (![prp isEqual:peripheral]) {
            [_centralManager cancelPeripheralConnection:prp];
        }
    }
    [_centralManager stopScan];
    _command = 1002;
    self.startConnectInterval = [NSDate timenowInterval];
//    CBPeripheral *peripheral = self.peripheralMArr[indexPath.row];
    [_centralManager connectPeripheral:peripheral options:nil];
    self.tagPeripheral = peripheral;
}

- (NSMutableArray *)peripheralMArr{
    if (_peripheralMArr == nil) {
        _peripheralMArr = [NSMutableArray array];
    }
    return _peripheralMArr;
}

- (NSMutableArray *)targetPrpMArr{
    if (_targetPrpMArr == nil) {
        _targetPrpMArr = [NSMutableArray array];
    }
    return _targetPrpMArr;
}

- (NSMutableArray *)scanPrpMArr{
    if (_scanPrpMArr == nil) {
        _scanPrpMArr = [NSMutableArray array];
    }
    return _scanPrpMArr;
}



- (UIButton *)scanButton{
    if (_scanButton == nil) {
        _scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _scanButton.backgroundColor = [UIColor grayColor];
        [_scanButton setTitle:@"扫描设备" forState:UIControlStateNormal];
        _scanButton.frame = CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH / 2, 44);
        [_scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanButton;
}

- (UIButton *)cutButton{
    if (_cutButton == nil) {
        _cutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cutButton.frame = CGRectMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 44, SCREEN_WIDTH / 2, 44);
        [_cutButton addTarget:self action:@selector(disconnectPeripheral) forControlEvents:UIControlEventTouchUpInside];
        _cutButton.backgroundColor = [UIColor lightGrayColor];
        [_cutButton setTitle:@"断开连接" forState:UIControlStateNormal];
    }
    return _cutButton;
}

- (DataFooter *)datafooter{
    if (_datafooter == nil) {
        _datafooter = [[DataFooter alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 274, SCREEN_WIDTH, 230)];
        
    }
    return _datafooter;
}

@end
