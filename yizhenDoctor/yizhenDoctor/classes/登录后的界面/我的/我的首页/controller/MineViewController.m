//
//  MineViewController.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/8.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "MineViewController.h"
#import "AppDelegate.h"
#import "AllNavigationController.h"
#import "loginViewController.h"

@interface MineViewController ()

@property (strong,nonatomic) UITableView * MainTable;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    
}


-(void)creatUI
{
    self.view.backgroundColor=[UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title=@"我的";
//    UIButton*discussBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    [discussBtn setTitle:@"退出" forState:UIControlStateNormal];
//    [discussBtn setTitleColor:themeColor forState:UIControlStateNormal];
//    [discussBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
//    [discussBtn setFrame:CGRectMake(0, 0, 32, 22)];
//    [discussBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem*discuss=[[UIBarButtonItem alloc]initWithCustomView:discussBtn];
//    [self.navigationItem setRightBarButtonItem:discuss];

    [self logOut];
}
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 3;
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if (section==0) {
//        return 3;
//    }
//    else if (section==1)
//    {
//        return 4;
//    }
//    else
//    {
//        return 1;
//    }
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section==0&&indexPath.row==0) {
//        return 70;
//    }
//    else
//    {
//        return 50;
//    }
//}
//
//-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (cell==nil) {
//       cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//    }
//    UIImageView*iconView=[[UIImageView alloc]init];
//    iconView.layer.cornerRadius=25;
//    iconView.layer.masksToBounds=YES;
//    iconView.contentMode=UIViewContentModeScaleAspectFit;
//    [cell.contentView addSubview:iconView];
//    
//    UILabel*titleLabel=[[UILabel alloc]init];
//    titleLabel.font=YiZhenFont;
//    titleLabel.textColor=[UIColor blackColor];
//    [cell.contentView addSubview:titleLabel];
//    
//    UILabel*subLabel=[[UILabel alloc]init];
//    subLabel.font=YiZhenFont14;
//    subLabel.textColor=grayLabelColor;
//    [cell.contentView addSubview:subLabel];
//    
//    UIImageView*moreView=[[UIImageView alloc]init];
//    moreView.image=[UIImage imageNamed:@"goin"];
//    moreView.contentMode=UIViewContentModeScaleAspectFit;
//    [cell.contentView addSubview:moreView];
//    
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@15);
//        make.centerY.mas_equalTo(cell);
//        make.height.equalTo(@22);
//    }];
//    
//    [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(@15);
//        make.centerY.mas_equalTo(cell);
//        make.size.mas_equalTo(CGSizeMake(8, 16));
//    }];
//    
//    [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(moreView.mas_left).with.offset(6);
//        make.centerY.mas_equalTo(cell);
//        make.height.equalTo(@21);
//    }];
//    
//    if (indexPath.section==0) {
//        if (indexPath.row==0) {
//            [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerY.mas_equalTo(cell);
//                make.size.mas_equalTo(CGSizeMake(50, 50));
//                make.right.mas_equalTo(moreView.mas_left).with.offset(6);
//            }];
//        }
//        [iconView sd_setImageWithURL:@"" placeholderImage:[UIImage imageNamed:@"default_avatar3"]];
//    }
//    
//    return cell;
//}

-(void)logOut
{
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSString*logoutUrl=[NSString stringWithFormat:@"%@/v3/common/logout",Baseurl];
    NSDictionary *logOutDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:logoutUrl Parameters:logOutDic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        YiZhenLog(@"res==%d",res);
        if (res==0) {
            [self gotoLogin];
        }
        
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}


-(void)gotoLogin
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    AllNavigationController*allNavigationVC=[[AllNavigationController alloc]initWithRootViewController:[loginViewController new]];
    appDelegate.window.rootViewController=allNavigationVC;
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
