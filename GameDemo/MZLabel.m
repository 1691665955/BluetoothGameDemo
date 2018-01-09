//
//  MZLabel.m
//  MyTestProject
//
//  Created by 曾龙 on 16/11/19.
//  Copyright © 2016年 scinan. All rights reserved.
//

#import "MZLabel.h"

@implementation MZLabel

- (MZLabel *)initWithFrame:(CGRect)frame andbackgroundColor:(UIColor *)BColor andText:(NSString *)text andTextColor:(UIColor *)TColor andTextAlignment:(NSTextAlignment)alignment andFont:(UIFont *)font
{
    self = [super init];
    self.frame = frame;
    self.backgroundColor = BColor;
    self.text = text;
    self.textColor = TColor;
    self.textAlignment = alignment;
    self.font = font;
    return self;    
}

@end
