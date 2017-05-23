//
//  ZRTabbarViewController.m
//  iFinder
//
//  Created by VictorZhang on 21/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRTabbarViewController.h"
#import "ZRHomeViewController.h"
#import "ZRSearchViewController.h"
#import "ZRMainViewController.h"
#import "ZRUtils.h"

@implementation ZRTabbarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setChildControllersArray];
    [self setAttributionAtChildViewControllers];
}

- (void)setChildControllersArray
{
    NSArray *controllers = self.viewControllers;
    
    if (![ZRUtils isJailBreak]) {
        [self setViewControllers:@[controllers[0], controllers[1]] animated:YES];
    }
}

- (void)setAttributionAtChildViewControllers {
    
    NSArray *controllers = self.childViewControllers;
    
    UINavigationController *naviController1 = controllers[0];
    naviController1.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:100];
    
    UINavigationController *naviController2 = controllers[1];
    naviController2.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:200];
    
    if ([ZRUtils isJailBreak]) {
        UINavigationController *naviController3 = controllers[2];
        naviController3.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:300];
    }
}


@end
