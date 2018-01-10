//
//  AppDelegate.m
//  yizhenDoctor
//
//  Created by augbase on 16/8/25.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "AppDelegate.h"
#import "loginViewController.h"
#import "AllNavigationController.h"
#import "wangTabViewController.h"


@interface AppDelegate ()
{
    BOOL NotFirstTimeLogin;//
    AllNavigationController*allNavigationVC;//总控制器
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置网络
    

    
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    
    NotFirstTimeLogin = [[defaults objectForKey:NotFirstLogin] boolValue];//no为初次登录，yes则不是
    if (NotFirstTimeLogin) {
        allNavigationVC=[[AllNavigationController alloc]initWithRootViewController:[wangTabViewController new]];
    }
    else
    {
        loginViewController*loginVC=[[loginViewController alloc]init];
       allNavigationVC=[[AllNavigationController alloc]initWithRootViewController:loginVC];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=[UIColor whiteColor];
    self.window.rootViewController = allNavigationVC;
    [self.window makeKeyAndVisible];
    
    //注册环信
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
