//
//  MZGamePlayVC.h
//  GameDemo
//
//  Created by 曾龙 on 17/4/21.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZGameRoomModel.h"
@interface MZGamePlayVC : UIViewController
@property(nonatomic,strong)MZGameRoomModel *model;
@property(nonatomic,assign)BOOL isMeStep;
@end
