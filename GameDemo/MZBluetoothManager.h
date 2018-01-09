//
//  MZBluetoothManager.h
//  GameDemo
//
//  Created by 曾龙 on 17/4/24.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@protocol MZBluetoothManagerDelegate <NSObject>
//获取对方数据
- (void)getData:(NSString *)data;

@optional
- (void)searchGameSuccess;
@end

@interface MZBluetoothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>
@property(nonatomic,strong)id<MZBluetoothManagerDelegate> delegate;
@property(nonatomic,assign)BOOL isCentral;


+(instancetype)shareManager;

//作为游戏房主建立游戏房间
-(void)creatGameWithName:(NSString *)name block:(void(^)(BOOL first))finish;

//作为游戏加入者查找附近的游戏
- (void)searchGame;

//断开连接
- (void)disConnect;

//进行写数据操作
- (void)writeData:(NSString *)data;
@end
