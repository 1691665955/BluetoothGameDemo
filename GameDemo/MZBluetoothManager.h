//
//  MZBluetoothManager.h
//  GameDemo
//
//  Created by 曾龙 on 17/4/24.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZGameRoomModel.h"
@protocol MZBluetoothManagerDelegate <NSObject>
@optional
//获取对手发送数据
- (void)getData:(NSString *)data;
//加入游戏成功
- (void)joinToGameSuccess;
//加入游戏失败
- (void)joinToGameFailure;
@end

@interface MZBluetoothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>
@property(nonatomic,strong)id<MZBluetoothManagerDelegate> delegate;
@property(nonatomic,assign)BOOL isCentral;
//对手名称
@property(nonatomic,copy)NSString *competitor;

+ (instancetype)shareManager;

//作为游戏房主建立游戏房间
- (void)creatGameWithName:(NSString *)name block:(void(^)(BOOL first))finish;

//作为游戏加入者查找附近的游戏
- (void)searchGameRoomCallBack:(void(^)(NSArray<MZGameRoomModel *> *rooms)) result;

//加入游戏
- (void)joinToTheGameWithPeripheral:(CBPeripheral *)peripheral;

//断开连接
- (void)disConnect;

//开始广播
- (void)startAdvitise;

//停止广播
- (void)stopAdvitise;

//房主通知其他用户该房间已移除
- (void)advitisTheRoomRemoved;

//进行写数据操作
- (void)writeData:(NSString *)data;
@end
