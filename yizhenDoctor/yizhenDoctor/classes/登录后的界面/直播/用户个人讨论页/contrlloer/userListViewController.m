//
//  userListViewController.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/14.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "userListViewController.h"
#import "userListTableViewCell.h"
#import "voiceToolView.h"


@interface userListViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,voiceToolViewDelegate>

{
    UIView * shadowView;//阴影view
    NSString * replayID;
    NSString * randomStr;
}
@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;
@property (strong,nonatomic)voiceToolView *voiceTool;//语音处理类

@end

@implementation userListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
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
    _MainTable.separatorColor=lightGrayBackColor;
    _MainTable.backgroundColor=grayBackgroundLightColor;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _MainTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 20);
    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    
    UIView*footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footView.backgroundColor=[UIColor whiteColor];
    _MainTable.tableFooterView = footView;
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(15, 0, ViewWidth-30, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    [footView addSubview:lineView];

    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    _header.delegate = self;
    _footer.delegate = self;
  
}

#pragma mark-对患者回复的view
-(void)createAnswerView
{
    shadowView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
    shadowView.backgroundColor=[UIColor colorWithWhite:0.3 alpha:0.3];
    [self.navigationController.view addSubview:shadowView];
    
    _voiceTool=[[voiceToolView alloc]initWithSuperViewController:self];
    _voiceTool.delegate=self;
    [shadowView addSubview:_voiceTool];
    
    UIButton*tapbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    tapbutton.backgroundColor=[UIColor clearColor];
    [tapbutton setFrame:CGRectMake(0, 0, ViewWidth, ViewHeight-_voiceTool.height)];
    [tapbutton addTarget:self action:@selector(tapToHidenTheShadow) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:tapbutton];
}

-(void)tapToHidenTheShadow
{
    if (shadowView) {
        [shadowView removeFromSuperview];
        _voiceTool.recordAudio=nil;
        [_voiceTool.audio stopSound];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    randomStr=SuiJiShu;
    self.title=_themeTitle;
    [self setUpData];
    
    UIButton*backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"closed_sb"] forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(0, 0, 22, 22)];
    [backBtn addTarget:self action:@selector(pressToBackTheDiscuss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*back=[[UIBarButtonItem alloc]initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:back];
}

-(void)pressToBackTheDiscuss
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-tabelView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArray.count==0) {
        return 190;
    }
    else {
        userListModel*model=_dataArray[indexPath.row];
        return model.cellHeight;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    userListTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"userCell"];
    if (cell==nil) {
        cell=[[userListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userCell"];
    }
    if (_dataArray.count==0) {
        
    }
    else
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        userListModel*model=_dataArray[indexPath.row];
        [cell setListModel:model];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self createAnswerView];
    userListModel*model=_dataArray[indexPath.row];
    replayID=[NSString stringWithFormat:@"%ld",model.IDS];
    
    [_voiceTool setStatu:[NSString stringWithFormat:@"%@：%@",model.creatorName,model.content]];

}


-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/live/%@/discuss/%@?uid=%@&token=%@&page=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[NSString stringWithFormat:@"%ld",_userId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"讨论列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                userListModel*model=[[userListModel alloc]initWithDictionary:dic];
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
        [self.header endRefreshing];
        [self.footer endRefreshing];
    }];
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

#pragma mark-voiceTool的代理方法
-(void)inFunctoinVIew:(voiceToolView *)view andSendVoiceData:(NSData *)voiceData andSecond:(NSInteger)second
{
    [self postVoice:voiceData andDuration:second];
    [self tapToHidenTheShadow];
}

-(void)inFunctoinViewCancleTheRecord
{
    [self tapToHidenTheShadow];
    
}


-(void)postVoice:(NSData*)voiceData andDuration:(NSInteger)second
{
    [[SetupView ShareInstance]showHUD:self Title:NSLocalizedString(@"发送中...", @"")];
    NSString*url=@"http://img.augbase.com/";
    [[HttpManager ShareInstance]AFNetPOSTSupport:url Parameters:nil ConstructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:voiceData name:@"file" fileName:@"live.amr" mimeType:@"amr_nb"];
    } SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"上传成功");
            [[SetupView ShareInstance]hideHUD];
            NSString*voiceStr=[source objectForKey:@"data"];
            YiZhenLog(@"%@",voiceStr);
            [self postTheContent:voiceStr andReplyId:replayID andDuration:second];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

-(void)postTheContent:(NSString*)content andReplyId:(NSString*)replyId andDuration:(NSInteger)duration
{
    //type
    //    0 	文本
    //    1 	语音
    //    2 	图片
    //    3 	直播介绍
    //    4 	医生介绍
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/sendMessage",Baseurl,[NSString stringWithFormat:@"%ld",_liveId]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSString *contentStr=content;
    NSString *durationStr=[NSString stringWithFormat:@"%ld",duration];
    NSString *type=@"1";
    NSDictionary *dic;
    if (content.length>0) {
        dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,contentStr,type,durationStr,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"content",@"type",@"duration",@"random",nil]];
        if (replyId) {
            dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,contentStr,type,replyId,durationStr,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"content",@"type",@"replyId",@"duration",@"random",nil]];
        }
        [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            int res=[[source objectForKey:@"res"] intValue];
            if (res==0) {
                randomStr=SuiJiShu;
                YiZhenLog(@"success");
            }
            else
            {
                [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
                randomStr=SuiJiShu;
            }
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
            YiZhenLog(@"%@",error);
            randomStr=SuiJiShu;
        }];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_header||_footer) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
