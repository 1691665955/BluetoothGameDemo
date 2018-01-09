//
//  MZGameRoomCell.m
//  GameDemo
//
//  Created by 曾龙 on 17/4/21.
//  Copyright © 2017年 scinan. All rights reserved.
//

#import "MZGameRoomCell.h"
#import "MZLabel.h"
#import "Header.h"
@interface MZGameRoomCell ()
@property(nonatomic,strong)MZLabel *titleLB;
@end

@implementation MZGameRoomCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLB = [[MZLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) andbackgroundColor:[UIColor greenColor] andText:nil andTextColor:[UIColor whiteColor] andTextAlignment:NSTextAlignmentCenter andFont:[UIFont systemFontOfSize:30*SCALE]];
        [self addSubview:self.titleLB];
    }
    return self;
}

- (void)setModel:(MZGameRoomModel *)model {
    _model = model;
    self.titleLB.text = model.roomName;
}
@end
