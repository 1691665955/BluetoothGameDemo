//
//  MZChessModel.h
//  GameDemo
//
//  Created by 曾龙 on 17/4/23.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    WhiteChess,
    BlackChess,
} ChessType;

@interface MZChessModel : NSObject
@property(nonatomic,assign)NSInteger xPoint;
@property(nonatomic,assign)NSInteger yPoint;
@property(nonatomic,assign)ChessType type;
@end
