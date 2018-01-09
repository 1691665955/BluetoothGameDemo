//
//  MZLabel.h
//  MyTestProject
//
//  Created by 曾龙 on 16/11/19.
//  Copyright © 2016年 scinan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZLabel : UILabel
/**
 初始化Label
 */
- (MZLabel *)initWithFrame:(CGRect)frame andbackgroundColor:(UIColor *)BColor andText:(NSString *)text andTextColor:(UIColor *)TColor andTextAlignment:(NSTextAlignment)alignment andFont:(UIFont *)font;
@end
