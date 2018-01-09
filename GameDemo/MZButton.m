//
//  MZButton.m
//  MyTestProject
//
//  Created by 曾龙 on 16/11/18.
//  Copyright © 2016年 scinan. All rights reserved.
//


/**
 需要引入SDWebImage三方库
 */
#import "MZButton.h"
@interface MZButton ()
@property(nonatomic,copy)buttonClicked clickedBlock;
@property(nonatomic,copy)NSString *NName;
@property(nonatomic,copy)NSString *SName;
@property(nonatomic,copy)NSString *NTitle;
@property(nonatomic,copy)NSString *STitle;
@property(nonatomic,assign)BOOL isDIY;
@end

@implementation MZButton

//初始化有背景图片的button
-(MZButton *)initWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle andTitlteColor:(UIColor *)titleColor andNBImageName:(NSString *)NBName andHBImageName:(NSString *)HBName andSBName:(NSString *)SBName andClickedBlock:(buttonClicked)clickedBlock
{
    self = [super init];
    self.frame = frame;
    [self setTitle:NTitle forState:UIControlStateNormal];
    [self setTitle:STitle forState:UIControlStateSelected];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:NBName] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:SBName] forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageNamed:HBName] forState:UIControlStateHighlighted];
    [self addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.clickedBlock = clickedBlock;
    return self;
}

//初始化有背景颜色的button
-(MZButton *)initWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle  andTitlteColor:(UIColor *)titleColor andBackgroundColor:(UIColor *)backgroundColor andClickedBlock:(buttonClicked)clickedBlock
{
    self = [super init];
    self.frame = frame;
    [self setTitle:NTitle forState:UIControlStateNormal];
    [self setTitle:STitle forState:UIControlStateSelected];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    [self setBackgroundColor:backgroundColor];
    [self addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.clickedBlock = clickedBlock;
    return self;
}

//初始化图片在上，title在下的button,space为图像与边框间隔，文字与图像的间隔默认为space／2
- (MZButton *)initImageTopWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle andTitlteColor:(UIColor *)titleColor andNormalImageName:(NSString *)NName  andSelectedImageName:(NSString *)SName andWithBackgroundColor:(UIColor *)backgroundColor andSpace:(CGFloat)space andTitleFont:(UIFont *)font andClickedBlock:(buttonClicked)clickedBlock
{
    self = [super init];
    self.frame = frame;
    [self setBackgroundColor:backgroundColor];
    [self addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.clickedBlock = clickedBlock;
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(space, space, frame.size.width-2*space, frame.size.width-2*space)];
    iconView.image = [UIImage imageNamed:NName];
    iconView.tag = 998;
    [self addSubview:iconView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width-space*0.5, frame.size.width, frame.size.height-frame.size.width-space*0.5)];
    label.text = NTitle;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = titleColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.tag = 999;
    [self addSubview:label];
    
    self.NName = NName;
    self.SName = SName;
    self.NTitle = NTitle;
    self.STitle = STitle;
    self.isDIY = YES;
    
    return self;
}

//初始化图片在左，title在右的button,space为图像与边框间隔，文字与图像的间隔默认为space／2
- (MZButton *)initImageLeftWithFrame:(CGRect)frame andNormalTitle:(NSString *)NTitle andSelectedTitle:(NSString *)STitle andTitlteColor:(UIColor *)titleColor andNormalImageName:(NSString *)NName  andSelectedImageName:(NSString *)SName andWithBackgroundColor:(UIColor *)backgroundColor andSpace:(CGFloat)space andTitleFont:(UIFont *)font andClickedBlock:(buttonClicked)clickedBlock
{
    self = [super init];
    self.frame = frame;
    [self setBackgroundColor:backgroundColor];
    [self addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.clickedBlock = clickedBlock;
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(space, space, frame.size.height-2*space, frame.size.height-2*space)];
    iconView.image = [UIImage imageNamed:NName];
    iconView.tag = 998;
    [self addSubview:iconView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.height-space*0.5, space, frame.size.width-frame.size.height, frame.size.height-2*space)];
    label.text = NTitle;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = titleColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.tag = 999;
    [self addSubview:label];
    
    self.NName = NName;
    self.SName = SName;
    self.NTitle = NTitle;
    self.STitle = STitle;
    self.isDIY = YES;
    
    return self;
}

- (void)btnClicked
{
    if (self.clickedBlock)
    {
        self.clickedBlock(self);
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (self.isDIY)
    {
        if (selected == YES)
        {
            UIImageView *imageView = (UIImageView *)[self viewWithTag:998];
            imageView.image = [UIImage imageNamed:self.SName];
            UILabel *label = (UILabel *)[self viewWithTag:999];
            label.text = self.STitle;
        }
        else
        {
            UIImageView *imageView = (UIImageView *)[self viewWithTag:998];
            imageView.image = [UIImage imageNamed:self.NName];
            UILabel *label = (UILabel *)[self viewWithTag:999];
            label.text = self.NTitle;
        }
    }
}
@end
