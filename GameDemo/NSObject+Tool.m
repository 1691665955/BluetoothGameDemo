//
//  NSObject+Tool.m
//  GameDemo
//
//  Created by 曾龙 on 2018/1/11.
//  Copyright © 2018年 scinan. All rights reserved.
//

#import "NSObject+Tool.h"

@implementation NSObject (Tool)
- (UIViewController *)currentViewController{
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        
    }
    // modal展现方式的底层视图不同
    // 取到第一层时，取到的是UITransitionView，通过这个view拿不到控制器
    UIView *firstView = [keyWindow.subviews firstObject];
    UIView *secondView = [firstView.subviews firstObject];
    UIResponder *response = [secondView nextResponder];
    UIViewController *vc ;
    while (response) {
        if ([response isKindOfClass:[UIViewController class]]) {
            vc = (UIViewController *)response;
            break;
        } else {
            response = [response nextResponder];
        }
    }
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            
            return [nav.viewControllers lastObject];
        } else {
            return tab.selectedViewController;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.viewControllers lastObject];
    } else {
        return vc;
    }
    return nil;
}
@end
