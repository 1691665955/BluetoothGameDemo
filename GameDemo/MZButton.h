//
//  MZButton.h
//  MyTestProject
//
//  Created by 曾龙 on 16/11/18.
//  Copyright © 2016年 scinan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZButton : UIButton
typedef void (^buttonClicked)(MZButton *sender);

/**
 初始化有背景图片的button
 */
-(MZButton *)initWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle andTitlteColor:(UIColor *)titleColor andNBImageName:(NSString *)NBName andHBImageName:(NSString *)HBName andSBName:(NSString *)SBName andClickedBlock:(buttonClicked)clickedBlock;

/**
 初始化有背景颜色的button
 */
-(MZButton *)initWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle  andTitlteColor:(UIColor *)titleColor andBackgroundColor:(UIColor *)backgroundColor andClickedBlock:(buttonClicked)clickedBlock;

/**
 初始化图片在上，title在下的button,space为图像与边框间隔，文字与图像的间隔默认为space／2
 */
- (MZButton *)initImageTopWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle andTitlteColor:(UIColor *)titleColor andNormalImageName:(NSString *)NName  andSelectedImageName:(NSString *)SName andWithBackgroundColor:(UIColor *)backgroundColor andSpace:(CGFloat)space andTitleFont:(UIFont *)font andClickedBlock:(buttonClicked)clickedBlock;

/**
 初始化图片在左，title在右的button,space为图像与边框间隔，文字与图像的间隔默认为space／2
 */
- (MZButton *)initImageLeftWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle andTitlteColor:(UIColor *)titleColor andNormalImageName:(NSString *)NName  andSelectedImageName:(NSString *)SName andWithBackgroundColor:(UIColor *)backgroundColor andSpace:(CGFloat)space andTitleFont:(UIFont *)font andClickedBlock:(buttonClicked)clickedBlock;

@end
