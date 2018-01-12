//
//  MZGameRoomModel.h
//  GameDemo
//
//  Created by 曾龙 on 17/4/21.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface MZGameRoomModel : NSObject
/**
 房间名称
 */
@property(nonatomic,copy)NSString *roomName;

/**
 外设信息
 */
@property(nonatomic,strong)CBPeripheral *peripheral;
@end
