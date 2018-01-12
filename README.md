# BluetoothGameDemo
关于蓝牙对战的五子棋游戏

##
该游戏仅是本人用来学习蓝牙基础知识的demo

    1.实现创建游戏房间功能
    2.实现搜索游戏房间功能
    3.实现游戏对战功能（包括落子，悔棋，重开功能）
    4.目前只完成两台iphone的操作调试，还待后续测试优化

##
实现技术：该游戏由于是蓝牙对战，所以涉及到中心设备和外设

    1.外设（供搜索的设备）
    
        .当一个手机去创建一个游戏房间时，此时该手机会根据房间名创建相关服务特征并且开始广播
        
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
        
        

        .当外设收到已经订阅到服务特征值时，停止发送广播（订阅到服务特征值时代表已有中心设备连接到该设备上面，即有游戏玩家进入已创建的房间）
        
        //中心设备订阅特征值时回调
        - (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
            [_peripheralManager stopAdvertising];
            NSLog(@"停止广播");
        }
        
        
        
        .游戏开始后通过代理获取中心设备写的数据，更新UI和进行相关操作
        
        //收到写消息后的回调
        - (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
            dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(getData:)]) {
                [self.delegate getData:[[NSString alloc] initWithData:requests.firstObject.value encoding:NSUTF8StringEncoding]];
                }
            });
        }
        

    2.中心设备（搜索的设备）
    
        .进入主界面后手机会作为中心设备去搜索外设，即游戏房间
        
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
        
        
        
        .搜索到的外设会进行过滤，找到是五子棋游戏的外设，然后返回给主界面，更新UI
        
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
        
        .点击主界面上的的房间会连接外设，连接成功后进入游戏
        
        //加入游戏
        - (void)joinToTheGameWithPeripheral:(CBPeripheral *)peripheral {
            //保存此设备
            _peripheral = peripheral;
            //进行连接
            [_centralManager connectPeripheral:peripheral options:nil];
        }
        
        
        
        .游戏开始后，通过被外设订阅的特征值来读取外设发送的信息
        
        //所监听的特征值更新时回调的方法
        - (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
            //更新接收到的数据
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(getData:)]) {
                    [self.delegate getData:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]];
                }
            });
        }


    3.写数据
    
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

