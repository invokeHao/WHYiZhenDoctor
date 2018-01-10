//
//  liveListViewController.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/8.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "liveListViewController.h"
#import "liveListModel.h"
#import "lveListTableViewCell.h"
#import "LiveViewController.h"
#import "NoNetworkingView.h"

@interface liveListViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,NoNetWorkingDelegate>

{
    NoNetworkingView*NoNetView;//
}
@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;//数据数组
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;
@end

@implementation liveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    
    [self setUpData];
}

-(void)creatUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    [self creatTableView];
}

-(void)creatTableView
{
    _MainTable=[[UITableView alloc]init];
    _MainTable.delegate=self;
    _MainTable.dataSource=self;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.showsVerticalScrollIndicator=NO;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(@-49);
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.title = NSLocalizedString(@"易诊", @"");
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    _header.delegate = self;
    _footer.delegate = self;
}

#pragma mark-tabelView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArray.count==0) {
        return 190;
    }
    else {
        liveListModel*model=_dataArray[indexPath.section];
        return model.cellHeight;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    lveListTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"answerCell"];
    if (cell==nil) {
        cell=[[lveListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCell"];
    }
    if (_dataArray.count<1) {
    }
    else
    {
        liveListModel*model=_dataArray[indexPath.section];
        [cell setModel:model];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    liveListModel*model=_dataArray[indexPath.section];
    LiveViewController * liveVC=[[LiveViewController alloc]init];
    liveVC.liveId=model.IDS;
    liveVC.ThemeTitle=model.title;
    [self.navigationController pushViewController:liveVC animated:YES];
}

-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/list?uid=%@&token=%@&page=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"直播列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        [NoNetView removeFromSuperview];
        NoNetView=nil;
        if (res == 0) {
            //拿到医生的Uid
            NSInteger userID=[[user objectForKey:@"userUID"] integerValue];
            
            for (NSDictionary*dic in arr) {
                liveListModel*model=[[liveListModel alloc]initWithDictionary:dic];
                if (userID!=model.doctorId) {
                    continue;
                }
                [_dataArray addObject:model];
            }
            [self.header endRefreshing];
            [self.footer endRefreshing];
            
            [_MainTable reloadData];
        }
        else
        {
            if(res==102)
            {
                if (_header||_footer) {
                    [_header removeFromSuperview];
                    [_footer removeFromSuperview];
                }
            }
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
        NSLog(@"code==%ld",error.code);
        NSLog(@"userInfo==%@",error.userInfo);
        if (error.code==-1009) {
            [self createNoNetView];
        }
        [self.header endRefreshing];
        [self.footer endRefreshing];
    }];
}

-(void)createNoNetView
{
    if (NoNetView==nil) {
        NoNetView=[[NoNetworkingView alloc]initWithFrame:self.view.frame];
        NoNetView.delegate=self;
        [_MainTable addSubview:NoNetView];
    }
    
}

-(void)functionView:(NoNetworkingView *)view refreshWithUrl:(NSString *)Url
{
    [self setUpData];
}

-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView==_header) {
        _currentpage=1;
        [_dataArray removeAllObjects];
        [self setUpData];
    }
    else if (refreshView==_footer)
    {
        _currentpage++;
        [self setUpData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.header||self.footer) {
        [self.header removeFromSuperview];
        [self.footer removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
