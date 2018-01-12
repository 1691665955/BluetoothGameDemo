//
//  MZBluetoothManager.m
//  GameDemo
//
//  Created by 曾龙 on 17/4/24.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import "MZBluetoothManager.h"
#import "NSObject+Tool.h"

#define GameTag  @"MZ2018"  //用来标记搜索到的蓝牙设备是否是游戏设备
#define RemoveTag @"Remove" //用来标记房主离开房间，房间删除

@implementation MZBluetoothManager
{
    //外设管理中心
    CBPeripheralManager * _peripheralManager;
    //外设提供的服务
    CBMutableService *_ser;
    //服务提供的读特征值
    CBMutableCharacteristic * _readChara;
    //服务提供的写特征值
    CBMutableCharacteristic * _writeChara;
    //设备中心管理对象
    CBCentralManager * _centralManager;
    //要连接的外设
    CBPeripheral * _peripheral;
    //房间名称
    NSString * _roomName;
    //要交互的外设属性
    CBCharacteristic * _centralReadChara;
    CBCharacteristic * _centralWriteChara;
    
    //搜索到房间的回调
    void(^serachGameRoomCallBack)(NSArray<MZGameRoomModel *> *rooms);
    
    //搜索到的房间名称
    NSMutableArray * _rooms;
}

+(instancetype)shareManager {
    static MZBluetoothManager *manager = nil;
    static dispatch_once_t predicte;
    dispatch_once(&predicte, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

//实现创建游戏的方法
- (void)creatGameWithName:(NSString *)name block:(void (^)(BOOL))finish {
    [_centralManager stopScan];
    
    if (_peripheralManager==nil) {
        //初始化服务
        _ser = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"] primary:YES];
        //初始化特征
        _readChara = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        _writeChara = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00068"] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
        //向服务中添加特征
        _ser.characteristics = @[_readChara,_writeChara];
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    }
    [_peripheralManager stopAdvertising];
    //记录房间名称
    _roomName = [NSString stringWithFormat:@"%@+%@",GameTag,name];
    //设置为房主
    _isCentral = YES;
    //开始广播广告
    [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:_roomName}];
    finish(YES);
}

//外设检测蓝牙状态
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    //判断是否可用
    if (peripheral.state == CBManagerStatePoweredOn) {
        //添加服务
        [_peripheralManager addService:_ser];
        //开始广播广告
        [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:_roomName}];
    } else {
        //弹框提示
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert];
        });
    }
}

//弹提示框
- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请确保您的蓝牙可用" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirmAction];
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}


//添加服务后回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"添加服务失败");
    } else {
        NSLog(@"添加服务成功");
    }
}

//中心设备订阅特征值时回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    [_peripheralManager stopAdvertising];
    NSLog(@"停止广播");
}

//收到写消息后的回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(getData:)]) {
            [self.delegate getData:[[NSString alloc] initWithData:requests.firstObject.value encoding:NSUTF8StringEncoding]];
        }
    });
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"开始广播");
}

/********************************加入游戏***********************************/

//作为游戏加入者查找附近的游戏
- (void)searchGameRoomCallBack:(void(^)(NSArray<MZGameRoomModel *> *rooms)) result {
    if (_centralManager == nil) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    }
    if (_rooms == nil) {
        _rooms = [NSMutableArray array];
    }
    [_rooms removeAllObjects];

    serachGameRoomCallBack = result;
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
}

//加入游戏
- (void)joinToTheGameWithPeripheral:(CBPeripheral *)peripheral {
    //保存此设备
    _peripheral = peripheral;
    //进行连接
    [_centralManager connectPeripheral:peripheral options:nil];
}

//设备硬件检测状态回调的方法，可用后开始扫描设备
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (_centralManager.state == CBManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

//发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    //获取设备的名称或者广告中的相应字段来匹配
    NSString *name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if ([name hasPrefix:GameTag]) {
        for (MZGameRoomModel *model in _rooms) {
            //防止重复添加房间
            if ([model.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                return;
            }
        }
        MZGameRoomModel *model = [[MZGameRoomModel alloc] init];
        model.roomName = [name substringFromIndex:GameTag.length+1];
        model.peripheral = peripheral;
        [_rooms addObject:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            serachGameRoomCallBack(_rooms);
        });
    } else if ([name hasPrefix:RemoveTag]) {
        if (name.length>6) {
            NSString *roomName = [name substringFromIndex:6];
            for (int i=0; i<_rooms.count; i++) {
                MZGameRoomModel *model = _rooms[i];
                if ([roomName isEqualToString:[NSString stringWithFormat:@"%@+%@",GameTag,model.roomName]]) {
                    [_rooms removeObject:model];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        serachGameRoomCallBack(_rooms);
                    });
                }
            }
        }
    }
}

//连接外设成功的回调
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接成功");
    [_centralManager stopScan];
    //设置代理与搜索外设中的服务
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(joinToGameFailure)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate joinToGameFailure];
        });
    }
}

//连接断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"断开连接");
//    [_centralManager connectPeripheral:peripheral options:nil];
}


#pragma mark -CBPeripheralDelegate

//发现服务后的回调方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"]]) {
            NSLog(@"找到服务");
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

//开发服务中的特征值后回调的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *chara in service.characteristics) {
        //发现特征，比较特征值的UUID来获取所需要的
        if ([chara.UUID isEqual:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"]]) {
            //保存特征值
            _centralReadChara = chara;
            //监听特征值
            [_peripheral setNotifyValue:YES forCharacteristic:_centralReadChara];
        }
        
        if ([chara.UUID isEqual:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00068"]]) {
            _centralWriteChara = chara;
        }
    }
    _isCentral = NO;
    if ([self.delegate respondsToSelector:@selector(joinToGameSuccess)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate joinToGameSuccess];
        });
    }
}

//所监听的特征值更新时回调的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    //更新接收到的数据
    dispatch_sync(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(getData:)]) {
            [self.delegate getData:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]];
        }
    });
}

- (void)disConnect {
    if (!_isCentral) {
        [_centralManager cancelPeripheralConnection:_peripheral];
        [_peripheral setNotifyValue:NO forCharacteristic:_centralReadChara];
        _peripheral = nil;
        _roomName = nil;
    }
}

//开始广播
- (void)startAdvitise {
    [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:_roomName}];
}

//停止广播
- (void)stopAdvitise {
    [_peripheralManager stopAdvertising];
}

//房主通知其他用户该房间已移除
- (void)advitisTheRoomRemoved {
    [_peripheralManager stopAdvertising];
    [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:[NSString stringWithFormat:@"%@%@",RemoveTag,_roomName]}];
}

- (void)writeData:(NSString *)data {
    if (_isCentral) {
        BOOL isSucces = [_peripheralManager updateValue:[data dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_readChara onSubscribedCentrals:nil];
        if (isSucces) {
            NSLog(@"success");
        }
    } else {
        [_peripheral writeValue:[data dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_centralWriteChara type:CBCharacteristicWriteWithoutResponse];
    }
}

@end
