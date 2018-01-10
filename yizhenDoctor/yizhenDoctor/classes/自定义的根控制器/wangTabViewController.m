//
//  wangTabViewController.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/8.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "wangTabViewController.h"
#import "liveListViewController.h"
#import "MineViewController.h"

@interface wangTabViewController ()

@end

@implementation wangTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    //
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    
    UIView*V=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 49)];
    UIColor*color=[UIColor whiteColor];
    V.backgroundColor=color;
    [self.tabBar insertSubview:V atIndex:0];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    //    [[UITabBar appearance] setShadowImage:[UIImage alloc]];
    // 通过appearance统一设置所有UITabBarItem的文字属性
    // 后面带有UI_APPEARANCE_SELECTOR的方法, 都可以通过appearance对象来统一设置
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:11];
    attrs[NSForegroundColorAttributeName] = darkTitleColor;
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSFontAttributeName] = attrs[NSFontAttributeName];
    selectedAttrs[NSForegroundColorAttributeName] = themeColor;
    
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    // 添加子控制器
    
    [self setupChildVc:[[liveListViewController alloc]init] title:@"易诊" image:@"live_off" selectedImage:@"live_on"];
    
    [self setupChildVc:[[MineViewController alloc] init] title:@"我的" image:@"mine_off" selectedImage:@"mine_on"];
    //    self.selectedIndex=1;
}
/**
 * 初始化子控制器
 */
- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置文字和图片
    UIImage* imageNormal = [UIImage imageNamed:image];
    UIImage* imageSelected = [UIImage imageNamed:selectedImage];
    vc.tabBarItem.selectedImage = [imageSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.image = [imageNormal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    vc.tabBarItem.title = title;
    
    // 添加为子控制器
    [self addChildViewController:vc];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
