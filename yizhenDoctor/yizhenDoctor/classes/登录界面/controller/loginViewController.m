//
//  loginViewController.m
//  yizhenDoctor
//
//  Created by augbase on 16/8/25.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "loginViewController.h"
#import "AppDelegate.h"
#import "wangTabViewController.h"
#import "AllNavigationController.h"

@interface loginViewController ()
{
    BOOL isRegisted;//判断是否注册过，注册过则自动填充手机号为账号（仅限为从注册界面跳过来）
    BOOL showPasswordOrNot;//判断是否显示明文密码
    UIButton *sectureButton;//密码框右边显示密码or not的按钮
    BOOL NotFirstTimeLogin;//no为初次登录，yes则不是
    NSString *userName;//用户名称
    NSString *userID;//用户ID
    NSString *pass;//密码
    NSString *server;//服务器
    NSString *randomStr;
}
@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    randomStr=SuiJiShu;
}

-(void)creatUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    int spaceRoom = 0;
    
    _userNameView = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 94-spaceRoom, ViewWidth-90, 50)];
    _passWordView = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 149-spaceRoom, ViewWidth-90, 50)];
    //    [_userNameView.contentTextField addTarget:self action:@selector(ensurePhoneAndPassword) forControlEvents:UIControlEventEditingChanged];
    //    [_passWordView.contentTextField addTarget:self action:@selector(ensurePhoneAndPassword) forControlEvents:UIControlEventEditingChanged];
    
    sectureButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [sectureButton addTarget:self action:@selector(changeSecture) forControlEvents:UIControlEventTouchUpInside];
    [sectureButton setBackgroundImage:[UIImage imageNamed:@"not_visible"] forState:UIControlStateNormal];
    
    _passWordView.contentTextField.rightViewMode = UITextFieldViewModeAlways;
    _passWordView.contentTextField.rightView = sectureButton;
    
    [self.view addSubview:_userNameView];
    [self.view addSubview:_passWordView];
    
    _loginButton = [[UIButton alloc]init];
    _loginButton.backgroundColor = themeColor;
    [_loginButton setTitle:NSLocalizedString(@"登录", @"") forState:UIControlStateNormal];
    _loginButton.layer.cornerRadius=10;
    _loginButton.layer.masksToBounds=YES;
    [_loginButton addTarget:self action:@selector(gotoMainView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    _forgetPassButton = [[UIButton alloc]init];
    [_forgetPassButton addTarget:self action:@selector(forgetPass:) forControlEvents:UIControlEventTouchUpInside];
    _forgetPassButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_forgetPassButton setTitle:NSLocalizedString(@"忘记密码", @"") forState:UIControlStateNormal];
    [_forgetPassButton setTitleColor:themeColor forState:UIControlStateNormal];
    _forgetPassButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_forgetPassButton];
    
    //autolayout
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.top.equalTo(_passWordView.mas_bottom).with.offset(50);
        make.right.equalTo(@-50);
        make.left.equalTo(@50);
    }];
    [_forgetPassButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@18);
        make.top.equalTo(_loginButton.mas_bottom).with.offset(20);
        make.right.equalTo(@-50);
        make.width.equalTo(@64);
    }];
    self.navigationItem.title=@"登录";

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil]];
    self.navigationController.navigationBar.tintColor = themeColor;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"white"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
    randomStr=SuiJiShu;
    
    
    _userNameView.contentTextField.placeholder = NSLocalizedString(@"手机号／邮箱", @"");
    _passWordView.contentTextField.placeholder = NSLocalizedString(@"密码", @"");
    _passWordView.contentTextField.secureTextEntry = YES;
    _passWordView.contentTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passWordView.contentTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    showPasswordOrNot = YES;
}


#pragma 登录的响应函数
-(void)gotoMainView{
    [self.view endEditing:YES];
    if ([self ensurePhoneAndPassword]) {
        [[SetupView ShareInstance]showHUD:self Title:@"登录中..."];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_userNameView.contentTextField.text forKey:@"userName"];
        [defaults setObject:_passWordView.contentTextField.text forKey:@"userPassword"];
        
        NSString *url = [NSString stringWithFormat:@"%@v3/common/doctor/login",Baseurl];
        NSMutableDictionary *loginDic = [NSMutableDictionary dictionary];
        [loginDic setValue:[defaults objectForKey:@"userName"] forKey:@"loginName"];
        [loginDic setValue:[defaults objectForKey:@"userPassword"] forKey:@"password"];
        [loginDic setValue:randomStr forKey:@"random"];
        url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        [manager POST:url parameters:loginDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"responseObject=%@",responseObject);
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary*Udic=[source objectForKey:@"data"];
            int res=[[source objectForKey:@"res"] intValue];
            YiZhenLog(@"登陆的返回res====%d",res);
            if (res==0) {
                //请求完成
                [defaults setObject:[Udic objectForKey:@"uid"] forKey:@"userUID"];
                [defaults setObject:[Udic objectForKey:@"token"] forKey:@"userToken"];
                [self loginToYizhen];
            }
            else{
                randomStr=SuiJiShu;
                [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YiZhenLog(@"WEB端登录失败");
            YiZhenLog(@"%@",error);
            randomStr=SuiJiShu;
            [[SetupView ShareInstance]hideHUD];
            [[SetupView ShareInstance]showAlertViewNoButtonMessage:@"请检查您的网络" Title:@"网络错误" viewController:self];
        }];
    }
}
#pragma 忘记密码的响应函数
-(void)forgetPass:(UIButton *)sender{
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    findPasswordViewController *findPasswordVC = [story instantiateViewControllerWithIdentifier:@"FIndPasswordVC"];
//    [self.navigationController pushViewController:findPasswordVC animated:YES];
}


-(void)loginToYizhen
{
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:NotFirstLogin];
    wangTabViewController *wangTabelVC=[[wangTabViewController alloc]init];
    //    wangTabelVC.selectedIndex=1;
    
    AllNavigationController*navVC=[[AllNavigationController alloc]initWithRootViewController:wangTabelVC];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.window.rootViewController =navVC ;
    
}

-(BOOL)ensurePhoneAndPassword{
    if (_userNameView.contentTextField.text.length<1) {
        [[SetupView ShareInstance] showTextHUD:self Title:@"用户名不能为空"];
        return NO;
    }
    else if (_passWordView.contentTextField.text.length<1)
    {
        [[SetupView ShareInstance] showTextHUD:self Title:@"密码不能为空"];
        return NO;
    }
    else
    {
        return YES;
    }
}
-(void)changeSecture{
    if (showPasswordOrNot) {
        _passWordView.contentTextField.secureTextEntry = NO;
        showPasswordOrNot = NO;
        [sectureButton setBackgroundImage:[UIImage imageNamed:@"visible"] forState:UIControlStateNormal];
    }else{
        _passWordView.contentTextField.secureTextEntry = YES;
        showPasswordOrNot = YES;
        [sectureButton setBackgroundImage:[UIImage imageNamed:@"not_visible"] forState:UIControlStateNormal];
    }
}

/*手机号码验证 MODIFIED BY HELENSONG*/
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(17[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

#pragma 取消输入操作
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
