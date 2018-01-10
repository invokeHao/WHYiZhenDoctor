//
//  SetupView.m
//  ResultContained
//
//  Created by 李胜书 on 15/8/14.
//  Copyright (c) 2015年 李胜书. All rights reserved.
//

#import "SetupView.h"
#import "sys/sysctl.h"
#import "LoginViewController.h"
#import "AllNavigationController.h"
#import "AppDelegate.h"



@implementation SetupView
{
    CGFloat angel;
    BOOL isRun;
    UIImageView*imageV;


}

+(SetupView *) ShareInstance{
    static SetupView *sharedSetupViewInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSetupViewInstance = [[self alloc] init];
    });
    return sharedSetupViewInstance;
}



-(void)setupNavigationRightButton:(UIViewController *)viewController RightButton:(UIButton *)rightButton{
    [viewController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:rightButton]];
}

-(void)setupNavigationLeftButton:(UIViewController *)viewController LeftButton:(UIButton *)leftButton{
    [viewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:leftButton]];
}

-(void)showAlertView:(NSString *)message Title:(NSString *)title ViewController:(UIViewController *)controller{
    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:title message:message delegate:controller cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:NSLocalizedString(@"取消", @""), nil];
    [showAlert show];
}

-(void)showAlertViewOneButton:(NSString *)message Title:(NSString *)title ViewController:(UIViewController *)controller{
    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:title message:message delegate:controller cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:nil, nil];
    [showAlert show];
}

-(void)showAlertViewNoButtonMessage:(NSString*)message Title:(NSString *)title viewController:(UIViewController *)controller
{
    UIAlertView *showAlert=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [showAlert show];
    [self performSelector:@selector(hideAltert:) withObject:showAlert afterDelay:1.7];
}

-(void)hideAltert:(UIAlertView*)alter
{
    [alter dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)showHUdAlertView:(NSString *)message Title:(NSString *)title ViewController:(UIViewController *)controller{
    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:title message:message delegate:controller cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:nil, nil];
    [showAlert show];
}

-(void)showAlertTitileView:(NSString*)title AtView:(UIView*)view
{
    UILabel*label=[[UILabel alloc]init];
    
    UIView*backView=[[UIView alloc]init];
    backView.center=view.center;
    backView.bounds=CGRectMake(0, 0, 200, 40);
    backView.backgroundColor=grayBackgroundDarkColor;
    [view addSubview:backView];
    
    label.center=view.center;
    label.text=title;
    label.bounds=CGRectMake(0, 0, 200, 22);
    label.font=YiZhenFont;
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    [backView addSubview:label];
    
    [NSThread sleepForTimeInterval:2];
    backView.hidden=YES;
}

-(NSString *)getNetWorkStates{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"无网络";
                    //无网模式
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                {
                    state = @"WIFI";
                }
                    break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return state;
}


-(void)showAlertView:(int)res Hud:(MBProgressHUD *)HUD ViewController:(UIViewController *)controller{
    [_HUD hide:YES];
    if (res == 1){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"输入数据出错", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 2){
        [self showAlertViewNoButtonMessage:@"小易正在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 3){
        [self showAlertViewNoButtonMessage:@"小易正在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 4){
        [self showAlertViewNoButtonMessage:@"帐号已存在，花一分钟注册一个吧" Title:@"提示" viewController:controller];
    }else if (res == 5){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"您的医生账户正在审核中…", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 6){
        [self showAlertViewNoButtonMessage:@"用户名太抢手了，换一个吧" Title:@"提示" viewController:controller];
    }else if (res == 7){
        [self showAlertViewNoButtonMessage:@"该邮箱已被注册" Title:@"提示" viewController:controller];
    }else if (res == 8){
        [self showAlertViewNoButtonMessage:@"帐号或密码不正确" Title:@"提示" viewController:controller];
    }else if (res == 9){
        [self showAlertViewNoButtonMessage:@"请求超时" Title:@"提示" viewController:controller];
    }else if (res == 10){
        [self showAlertViewNoButtonMessage:@"小易正在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 11){
        [self showAlertViewNoButtonMessage:@"小易正在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 12){
        [self showAlertViewNoButtonMessage:@"小易正在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 13){
        [self showAlertViewNoButtonMessage:@"小易正在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 14){
        [self showAlertViewNoButtonMessage:@"小易正在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 15){
        [self showAlertViewNoButtonMessage:@"暂无数据" Title:@"提示" viewController:controller];
    }else if (res == 16){
        [self showAlertViewNoButtonMessage:@"推送还在路上" Title:@"提示" viewController:controller];
    }else if (res == 17){
        [self showAlertViewNoButtonMessage:@"验证码出错" Title:@"提示" viewController:controller];
    }else if (res == 18){
        [self showAlertViewNoButtonMessage:@"手机号已被注册" Title:@"提示" viewController:controller];
    }else if (res == 19){
        [self showAlertViewNoButtonMessage:@"验证码不正确" Title:@"提示" viewController:controller];
    }else if (res == 20){
        [self showAlertViewNoButtonMessage:@"用户验证失败" Title:@"提示" viewController:controller];
    }else if (res == 21){
        [self showAlertViewNoButtonMessage:@"数据迁移失败" Title:@"提示" viewController:controller];
    }else if (res == 22){
        [self showAlertViewNoButtonMessage:@"用户编号和预留邮箱不匹配" Title:@"提示" viewController:controller];
    }else if (res == 23){
        [self showAlertViewNoButtonMessage:@"用户编号和预留手机号不匹配" Title:@"提示" viewController:controller];
    }else if (res == 24){
        [self showAlertViewNoButtonMessage:@"二维码不属于易诊？" Title:@"提示" viewController:controller];
    }else if (res == 25){
        [self showAlertViewNoButtonMessage:@"二维码已用" Title:@"提示" viewController:controller];
    }else if (res == 26){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"TA已经是你的好友啦", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 27){
        [self showAlertViewNoButtonMessage:@"小易在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 28){
        [self showAlertViewNoButtonMessage:@"小易在开小差，稍等一会儿" Title:@"提示" viewController:controller];
    }else if (res == 29){
        [self showAlertViewNoButtonMessage:@"验证码已用完，请关注“易诊”微信订阅号索取新验证码" Title:@"提示" viewController:controller];
    }else if (res == 30){
        [self showAlertViewNoButtonMessage:@"验证码填错了，再试一次吧＝" Title:@"提示" viewController:controller];
    }else if (res == 31){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"生成Access Code失败", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 32){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"生成signature失败", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 33){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"get User失败", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 34){
        [self showAlertViewNoButtonMessage:@"账户出错，请尽快联系“易诊”微信订阅号" Title:@"提示" viewController:controller];
    }else if (res == 35){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"获取消息失败", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 36){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"无法发送消息", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 37){
        [self showAlertViewNoButtonMessage:@"获取指标信息失败" Title:@"提示" viewController:controller];
    }else if (res == 38){
        [self showAlertViewNoButtonMessage:@"排序指标失败" Title:@"提示" viewController:controller];
    }else if (res == 39){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"搜索医生失败", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 40){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"邀请失败", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 41){
        [self showAlertViewNoButtonMessage:@"获取疾病信息失败" Title:@"提示" viewController:controller];
    }else if (res == 42){
        [self showAlertViewNoButtonMessage:@"未知错误" Title:@"提示" viewController:controller];
    }else if (res == 43){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"TA已经是你的好友啦", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 44){
        [self showAlertViewNoButtonMessage:@"信息为完善" Title:@"提示" viewController:controller];
    }
    else if (res ==806)
    {
        [self showAlertViewNoButtonMessage:@"手机号或密码错误" Title:@"提示" viewController:controller];
    }
    else if (res ==901)
    {
        [self showAlertViewNoButtonMessage:@"直播不存在" Title:@"提示" viewController:controller];
    }
    else if (res ==904)
    {
        [self showAlertViewNoButtonMessage:@"您还没有加入直播" Title:@"提示" viewController:controller];
    }
    else if (res ==102||res==101)
    {
        [self showAlertViewNoButtonMessage:@"登录过期，请重新登录" Title:@"提示" viewController:controller];
        [self gotoLogin];
    }
    
}

-(void)showHUD:(UIViewController *)viewController Title:(NSString *)title{
    _HUD = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    //常用的设置
    //小矩形的背景色
    _HUD.color = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6f];//背景色
    //显示的文字
    _HUD.labelText = title;
    //是否有庶罩
    _HUD.dimBackground = NO;
}

-(void)showTextHUD:(UIViewController*)viewController Title:(NSString*)title
{
    _HUD=[MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    _HUD.color=[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6f];
    _HUD.labelText=title;
    _HUD.mode=MBProgressHUDModeText;
    _HUD.dimBackground=NO;
    _HUD.removeFromSuperViewOnHide=YES;
    [_HUD hide:YES afterDelay:1.6];
}

-(void)showImageHUD:(UIViewController*)viewcontroller
{
    _HUD = [MBProgressHUD showHUDAddedTo:viewcontroller.view animated:NO];
    _HUD.color=[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6f];
    _HUD.mode=MBProgressHUDModeCustomView;
    imageV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rotation"]];
    _HUD.customView=imageV;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CABasicAnimation *rotationAnim = [CABasicAnimation animation];
        rotationAnim.keyPath = @"transform.rotation.z";
        rotationAnim.toValue = @(2 * M_PI);
        rotationAnim.repeatCount = MAXFLOAT;
        rotationAnim.duration = 2;
        rotationAnim.cumulative = NO;//无限循环
        [imageV.layer addAnimation:rotationAnim forKey:nil];
    });

}

-(void)hideHUD{
    [_HUD hide:YES];
    isRun=NO;
}

- (NSString*) doDevicePlatform{
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) {
        
        platform = @"iPhone";
        
    } else if ([platform isEqualToString:@"iPhone1,2"]) {
        
        platform = @"iPhone 3G";
        
    } else if ([platform isEqualToString:@"iPhone2,1"]) {
        
        platform = @"iPhone 3GS";
        
    } else if ([platform isEqualToString:@"iPhone3,1"]||[platform isEqualToString:@"iPhone3,2"]||[platform isEqualToString:@"iPhone3,3"]) {
        
        platform = @"iPhone 4";
        
    } else if ([platform isEqualToString:@"iPhone4,1"]) {
        
        platform = @"iPhone 4S";
        
    } else if ([platform isEqualToString:@"iPhone5,1"]||[platform isEqualToString:@"iPhone5,2"]) {
        
        platform = @"iPhone 5";
        
    }else if ([platform isEqualToString:@"iPhone5,3"]||[platform isEqualToString:@"iPhone5,4"]) {
        
        platform = @"iPhone 5C";
        
    }else if ([platform isEqualToString:@"iPhone6,2"]||[platform isEqualToString:@"iPhone6,1"]) {
        
        platform = @"iPhone 5S";
        
    }else if ([platform isEqualToString:@"iPod4,1"]) {
        
        platform = @"iPod touch 4";
        
    }else if ([platform isEqualToString:@"iPod5,1"]) {
        
        platform = @"iPod touch 5";
        
    }else if ([platform isEqualToString:@"iPod3,1"]) {
        
        platform = @"iPod touch 3";
        
    }else if ([platform isEqualToString:@"iPod2,1"]) {
        
        platform = @"iPod touch 2";
        
    }else if ([platform isEqualToString:@"iPod1,1"]) {
        
        platform = @"iPod touch";
        
    } else if ([platform isEqualToString:@"iPad3,2"]||[platform isEqualToString:@"iPad3,1"]) {
        
        platform = @"iPad 3";
        
    } else if ([platform isEqualToString:@"iPad2,2"]||[platform isEqualToString:@"iPad2,1"]||[platform isEqualToString:@"iPad2,3"]||[platform isEqualToString:@"iPad2,4"]) {
        
        platform = @"iPad 2";
        
    }else if ([platform isEqualToString:@"iPad1,1"]) {
        
        platform = @"iPad 1";
        
    }else if ([platform isEqualToString:@"iPad2,5"]||[platform isEqualToString:@"iPad2,6"]||[platform isEqualToString:@"iPad2,7"]) {
        
        platform = @"ipad mini";
        
    } else if ([platform isEqualToString:@"iPad3,3"]||[platform isEqualToString:@"iPad3,4"]||[platform isEqualToString:@"iPad3,5"]||[platform isEqualToString:@"iPad3,6"]) {
        
        platform = @"ipad 3";
        
    }
    
    return platform;
}

#pragma mark-登出app
-(void)gotoLogin
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    AllNavigationController*allNavigationVC=[[AllNavigationController alloc]initWithRootViewController:[loginViewController new]];
    appDelegate.window.rootViewController=allNavigationVC;
    
}

@end
