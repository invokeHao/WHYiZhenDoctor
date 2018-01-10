//
//  checkNetWorkingTool.m
//  yizhenDoctor
//
//  Created by 王浩 on 16/10/19.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "checkNetWorkingTool.h"

@implementation checkNetWorkingTool

+(BOOL) isConnectionAvailable:(UIView *)view{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    Reachability *reach1 = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    NetworkStatus status1 = [reach1 currentReachabilityStatus];
    if (status == NotReachable && status1 == NotReachable) {
        isExistenceNetwork = NO;
        NSLog(@"notReachable");
    }
    if (status == ReachableViaWiFi || status1 == ReachableViaWiFi) {
        isExistenceNetwork = YES;
        NSLog(@"WIFI");
    }
    if (status == ReachableViaWWAN || status1 == ReachableViaWWAN) {
        isExistenceNetwork = YES;
        NSLog(@"3G");
    }
    
    if (!isExistenceNetwork) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.removeFromSuperViewOnHide =YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
        hud.minSize = CGSizeMake(132.f, 80.0f);
        [hud hide:YES afterDelay:1.0];
        return NO;
    }
    
    return isExistenceNetwork;
}

-(void)changeNetWork:(NSNotification*)notification
{
    Reachability *reachability=(Reachability*)notification.object;
    NetworkStatus status=[reachability currentReachabilityStatus];
    Reachability *reach1 = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    NetworkStatus status1 = [reach1 currentReachabilityStatus];
    BOOL isExistenceNetwork=YES;
    if (status == NotReachable && status1 == NotReachable) {
        isExistenceNetwork = NO;
        NSLog(@"notReachable");
    }
    if (status == ReachableViaWiFi || status1 == ReachableViaWiFi) {
        isExistenceNetwork = YES;
        NSLog(@"WIFI");
    }
    if (status == ReachableViaWWAN || status1 == ReachableViaWWAN) {
        isExistenceNetwork = YES;
        NSLog(@"3G");
    }
}

+(BOOL) isConnectionAvailable{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    Reachability *reach1 = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    NetworkStatus status1 = [reach1 currentReachabilityStatus];
    if (status == NotReachable && status1 == NotReachable) {
        isExistenceNetwork = NO;
        NSLog(@"notReachable");
    }
    if (status == ReachableViaWiFi || status1 == ReachableViaWiFi) {
        isExistenceNetwork = YES;
        NSLog(@"WIFI");
    }
    if (status == ReachableViaWWAN || status1 == ReachableViaWWAN) {
        isExistenceNetwork = YES;
        NSLog(@"3G");
    }
    
    if (!isExistenceNetwork) {
        return NO;
    }
    
    return isExistenceNetwork;
}

@end
