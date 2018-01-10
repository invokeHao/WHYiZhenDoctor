//
//  LiveViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "LiveViewController.h"
#import "liveCellFrameModel.h"
#import "LiveTableViewCell.h"
#import "liveDiscussViewController.h"
#import "liveDiscussModel.h"
#import "discussTableViewCell.h"
#import "WHProgressHUD.h"
#import "chatToolBar.h"

#define kToolBarH 45
#define kTextFieldH 32

#define discussTabelWith 170
#define discussTabelHeight 150
#define KcloseBtnWith 32

@interface LiveViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,chatToolBarDelegate,MJRefreshBaseViewDelegate>
{
    BOOL toRefresh;//判断是否刷新
    BOOL hasNewData;//有新的数据
    BOOL tableViewAtTop;//tableView在顶部
    BOOL isBackfromLibray;//从图册返回
    
    BOOL isPic;//是图片
    BOOL isVoice;//是语音
    BOOL isLiveIntro;//是直播介绍
    BOOL isDoctIntro;//是医生介绍
    
    BOOL isFirstTime;//第一次进入且没有提问消息
    BOOL hasPostContent;//发送完消息，需要滚动到底部
    BOOL isBackFromDiscussVC;//从提问页面返回

    
    NSInteger firstMessageId;//第一个messageId
    NSInteger lastMessageId;//最后一个messageId
    NSInteger lastDiscussId;//最新的discussId
    UIVisualEffectView * discussView; //讨论tabelView的背景view
    UIImageView *discussBackImageView;
    UIButton * closeBtn;//控制讨论板按钮
    UIButton * newmessageBtn;//新消息的按钮
    UIButton * recordButton;//录音按钮
    //定时刷新器
    NSTimer *timer;
    UITextField *inputText;//发送框
    
    UIImageView*librayView;
    UIView*blackView;
    //录音相关
    BOOL isbeginVoiceRecord;
    NSInteger playTime;
    NSTimer *playTimer;
    NSString *randomStr;
    
}
@property (strong,nonatomic)UITableView * MainTable;//主tableView
@property (strong,nonatomic)UITableView * discussTable;//讨论的tableView
@property (strong,nonatomic)NSMutableArray * dataArray;//直播数据数组
@property (strong,nonatomic)NSMutableArray * discussArray;//讨论数据数组
@property (strong,nonatomic)MJRefreshHeaderView * header;//刷新控件
@property (strong,nonatomic)MJRefreshFooterView * footer;
@property (strong,nonatomic) chatToolBar * toolbar;//底部工具栏


@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self initData];
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    _discussArray=[[NSMutableArray alloc]initWithCapacity:0];
    tableViewAtTop=YES;
    lastDiscussId=0;
    lastMessageId=0;
}

-(void)creatUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTableView];
    [self creatDiscussTableView];
    [self creatCloseBtn];//创建控制讨论板的按钮
    [self addToolBar];
    [self addKVO];//添加键盘观察
//    [self creatNewMessageBtn];//创建刷新的button
}
-(void)createTableView
{
    //创建主table
    _MainTable = [[UITableView alloc] init];
    _MainTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64-kToolBarH);
    _MainTable.backgroundColor = [UIColor whiteColor];
    _MainTable.delegate = self;
    _MainTable.dataSource = self;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _MainTable.allowsSelection = NO;
    UIView*footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footView.backgroundColor=[UIColor whiteColor];
    _MainTable.tableFooterView = footView;
    [self.view addSubview:_MainTable];
    
    //滚动收起键盘
    _MainTable.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    //点击收起键盘
    [_MainTable addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
    [self.view addSubview:_MainTable];
}

- (void)creatDiscussTableView{
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    discussView= [[UIVisualEffectView alloc]initWithEffect:beffect];
    discussView.frame=CGRectMake(ViewWidth-10-discussTabelWith, 6, discussTabelWith, discussTabelHeight);
    discussView.layer.cornerRadius=8;
    discussView.layer.masksToBounds=YES;
    [self.view addSubview:discussView];
    
    discussBackImageView=[[UIImageView alloc]initWithFrame:CGRectMake(ViewWidth-35, 0, 15, 6)];
    discussBackImageView.image=[UIImage imageNamed:@"combined _shape2"];
    [self.view addSubview:discussBackImageView];

    
    //创建讨论的tableView
    _discussTable=[[UITableView alloc]init];
    _discussTable.frame=CGRectMake(0,5, discussTabelWith , discussTabelHeight-5);
    _discussTable.backgroundColor=[UIColor clearColor];
    _discussTable.layer.cornerRadius=8;
    _discussTable.layer.masksToBounds=YES;
    _discussTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _discussTable.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _discussTable.separatorColor =[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    _discussTable.delegate=self;
    _discussTable.dataSource=self;
    _discussTable.scrollEnabled=NO;
    
    [discussView addSubview:_discussTable];
}

-(void)creatCloseBtn
{
    closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"retractable"] forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake(ViewWidth-10-KcloseBtnWith, 164, KcloseBtnWith, KcloseBtnWith)];
    [closeBtn addTarget:self action:@selector(closeOrOpenTheDiscussBoard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

//-(void)creatNewMessageBtn
//{
//    newmessageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    [newmessageBtn setFrame:CGRectMake(ViewWidth/2-60, ViewHeight-20-40-64, 120, 40)];
//    [newmessageBtn setTitle:@"有新内容" forState:UIControlStateNormal];
//    [newmessageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [newmessageBtn setBackgroundColor:themeColor];
//    [newmessageBtn.titleLabel setFont:YiZhenFont16];
//    [newmessageBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    newmessageBtn.layer.cornerRadius=20;
//    newmessageBtn.layer.masksToBounds=YES;
//    [newmessageBtn addTarget:self action:@selector(pressToSeeTheNewMessage) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:newmessageBtn];
//    newmessageBtn.hidden=YES;
//}

-(void)creatTimer
{
    if (timer==nil) {
        timer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(syncTheLiveData) userInfo:nil repeats:YES];
    }
    [timer fire];
}

#pragma mark-创建发送栏
- (void)addToolBar
{
    _toolbar = [[chatToolBar alloc]initWithSuperVC:self];
    _toolbar.delegate=self;
    [self.view addSubview:_toolbar];
}

-(void)addKVO
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _header=[[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer=[[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    _header.delegate=self;
    _footer.delegate=self;

    randomStr=SuiJiShu;
    self.title=_ThemeTitle;
    if (timer==nil&&isBackFromDiscussVC) {
        [self creatTimer];
    }
    //讨论的按钮
    UIButton*discussBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [discussBtn setTitle:@"提问" forState:UIControlStateNormal];
    [discussBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [discussBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [discussBtn setFrame:CGRectMake(0, 0, 34, 22)];
    [discussBtn addTarget:self action:@selector(pressToDiscussTheTheme) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*discuss=[[UIBarButtonItem alloc]initWithCustomView:discussBtn];
    [self.navigationItem setRightBarButtonItem:discuss];
}

#pragma mark-view上的点击事件
-(void)closeOrOpenTheDiscussBoard
{
    if (closeBtn.y>150) {
        CGRect viewRect=discussView.frame;
        CGRect buttonRect=closeBtn.frame;
        viewRect.size.height=0;
        buttonRect.origin.y=10;
        [UIView animateWithDuration:0.5 animations:^{
            discussView.frame=viewRect;
            closeBtn.frame=buttonRect;
            [closeBtn setImage:[UIImage imageNamed:@"retractable2"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            discussBackImageView.hidden=YES;
        }];
    }
    else
    {
        CGRect viewRect=discussView.frame;
        CGRect buttonRect=closeBtn.frame;
        viewRect.size.height=discussTabelHeight;
        buttonRect.origin.y=164;
        [UIView animateWithDuration:0.5 animations:^{
            discussView.frame=viewRect;
            closeBtn.frame=buttonRect;
        }];
        discussBackImageView.hidden=NO;
        [closeBtn setImage:[UIImage imageNamed:@"retractable"] forState:UIControlStateNormal];
    }
}

//-(void)pressToSeeTheNewMessage
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArray.count-1 inSection:0];
//    [_MainTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    newmessageBtn.hidden=YES;
//}

-(void)pressToDiscussTheTheme
{
    liveDiscussViewController*discussVC=[[liveDiscussViewController alloc]init];
    discussVC.liveId=_liveId;
    [discussVC setBlock:^(BOOL hadCommit) {
        isBackFromDiscussVC=hadCommit;
    }];
    [self.navigationController pushViewController:discussVC animated:YES];
}

#pragma mark-tableView的delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_MainTable) {
        if (_dataArray.count==0) {
            return 20;
        }
        liveCellFrameModel*model=_dataArray[indexPath.row];
        //保证直播简介和医生简介的连接
        if (model.messageModel.type==3) {
            return model.cellHeght-10;
        }
        else
        {
            return model.cellHeght;
        }
    }
    else
    {
        if (_discussArray.count==0) {
            return 20;
        }
        liveDiscussModel*model=_discussArray[indexPath.row];
        return model.contentHeight;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_MainTable) {
        return _dataArray.count;
    }
    else
    {
        return _discussArray.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_MainTable) {
        static NSString *cellIdentifier = @"cell";
        
        LiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[LiveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        if (_dataArray.count==0) {
        }
        else
        {
            cell.liveCellFrame = _dataArray[indexPath.row];
        }
        //这个block用来标记已读状态
        [cell setVoiceBlock:^(BOOL haveReade,NSInteger messageId) {
            [self markTheMessageWithMessageId:messageId];
            liveCellFrameModel*model=_dataArray[indexPath.row];
            model.messageModel.hasRead=haveReade;
        }];
        //这两个block用来
        [cell setBeginBlock:^(BOOL hasBegin) {
            if (hasBegin) {
               timer.fireDate=[NSDate distantFuture];
            }
        }];
        [cell setEndBlock:^(BOOL hasEnd) {
            if (hasEnd) {
              timer.fireDate=[NSDate distantPast];
            }
        }];
        return cell;
    }
    else
    {
       static NSString *cellIdentifier = @"discussCell";
        discussTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[discussTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (_discussArray.count==0) {
        }
        else
        {
            cell.model=_discussArray[indexPath.row];
        }
        return cell;
    }
}

- (void)tableViewScrollToBottom{
    if (_discussArray.count == 0)
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_discussArray.count-1 inSection:0];
    [_discussTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    NSIndexPath *mIndexPath = [NSIndexPath indexPathForRow:_dataArray.count-1 inSection:0];
    [_MainTable scrollToRowAtIndexPath:mIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark-讨论版滚动到最下面
-(void)discussTabelScrollToBottom
{
    if(_discussArray.count==0){
        return;
    }
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_discussArray.count-1 inSection:0];
    [_discussTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView==_MainTable) {
        CGFloat height=_MainTable.height;
        CGFloat contentOffSet=_MainTable.contentOffset.y;
        CGFloat distanceFromeBottom=_MainTable.contentSize.height-contentOffSet;
        if (distanceFromeBottom<height) {
            tableViewAtTop=NO;
            hasNewData=NO;
            newmessageBtn.hidden=YES;
        }
        if (contentOffSet<100&&hasNewData) {
            tableViewAtTop=YES;
            newmessageBtn.hidden=NO;
        }
    }
}

#pragma mark-获取列表数据（next是true向下翻页，next为false向上翻页）
-(void)setUpDataWithMessageId:(NSInteger)messageId andNext:(BOOL)nextpage
{
    NSString * next=@"false";
    if (nextpage) {
        next=@"true";
    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/message?uid=%@&token=%@&messageId=%@&next=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%ld",messageId],next];
    YiZhenLog(@"直播内容列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        NSMutableArray*recoderArr=[NSMutableArray arrayWithArray:_dataArray];
        [_dataArray removeAllObjects];
        
        BOOL first=YES;
        
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                if (first) {
                    LiveModel*firstModel=[[LiveModel alloc]initWithDictionary:dic];
                    firstMessageId=firstModel.IDS;
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=firstModel;
                    [_dataArray addObject:cellFrameModel];
                    first=NO;
                }
                else
                {
                    LiveModel*model=[[LiveModel alloc]initWithDictionary:dic];
                    model.title=_ThemeTitle;
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model;
                    [_dataArray addObject:cellFrameModel];
                    
                }
            }
            for (liveCellFrameModel*model in recoderArr) {
                [_dataArray addObject:model];
            }
            [_MainTable reloadData];

            timer.fireDate=[NSDate distantPast];
            [_header endRefreshing];
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
            [_header endRefreshing];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
        [_header endRefreshing];
    }];
}

#pragma mark-初始化数据（直接到正在直播的页）
-(void)initData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/sync?uid=%@&token=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"当前直播列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableDictionary*listdic=[source objectForKey:@"data"];
        NSMutableArray*messageArr=listdic[@"messageList"];
        NSMutableArray*discussArr=listdic[@"discussList"];
        if (res == 0) {
            for (int i=0; i<messageArr.count; i++) {
                if (i==0) {
                    LiveModel*model=[[LiveModel alloc]initWithDictionary:messageArr[0]];
                    model.showTime=YES;
                    
                    firstMessageId=model.IDS;
                    
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model;
                    [_dataArray addObject:cellFrameModel];
                }
                else if(i>0)
                {
                    LiveModel*model1=[[LiveModel alloc]initWithDictionary:messageArr[i-1]];
                    LiveModel*model2=[[LiveModel alloc]initWithDictionary:messageArr[i]];
                    if ([self checkTime:model1.createTime ToAfterTime:model2.createTime]) {
                        model2.showTime=YES;
                    }
                    else
                    {
                        model2.showTime=NO;
                    }
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model2;
                    [_dataArray addObject:cellFrameModel];
                }
            }
            for (NSDictionary*dic in discussArr) {
                liveDiscussModel*discussModel=[[liveDiscussModel alloc]initWithDictionary:dic];
                [_discussArray addObject:discussModel];
            }
            if (_discussArray.count<1&&closeBtn.y>150) {
                [self closeOrOpenTheDiscussBoard];
                [closeBtn setImage:[UIImage imageNamed:@"retractable"] forState:UIControlStateNormal];
                isFirstTime=YES;
            }
            if (messageArr.count>0) {
                hasNewData=YES;
                //if (tableViewAtTop) {
                newmessageBtn.hidden=NO;
                // }
            }
            [_MainTable reloadData];
            [_discussTable reloadData];
            
            //拿到最新的id
            liveCellFrameModel*messageModel=[_dataArray lastObject];
            lastMessageId=messageModel.messageModel.IDS;
            liveDiscussModel*discussModel=[_discussArray lastObject];
            lastDiscussId=discussModel.IDS;
            
            [self tableViewScrollToBottom];
//            [self creatTimer];
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-同步刷新列表
-(void)syncTheLiveData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/sync?uid=%@&token=%@&messageId=%@&discussId=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%ld",lastMessageId],[NSString stringWithFormat:@"%ld",lastDiscussId]];
    YiZhenLog(@"直播同步列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableDictionary*listdic=[source objectForKey:@"data"];
        NSMutableArray*messageArr=listdic[@"messageList"];
        NSMutableArray*discussArr=listdic[@"discussList"];
        if (res == 0) {
            for (int i=0; i<messageArr.count; i++) {
                if (i==0) {
                    LiveModel*model=[[LiveModel alloc]initWithDictionary:messageArr[0]];
                    model.showTime=YES;
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model;
                    [_dataArray addObject:cellFrameModel];
                }
                else if(i>0)
                {
                    LiveModel*model1=[[LiveModel alloc]initWithDictionary:messageArr[i-1]];
                    LiveModel*model2=[[LiveModel alloc]initWithDictionary:messageArr[i]];
                    if ([self checkTime:model1.createTime ToAfterTime:model2.createTime]) {
                        model2.showTime=YES;
                    }
                    else
                    {
                        model2.showTime=NO;
                    }
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model2;
                    [_dataArray addObject:cellFrameModel];
                }
                
            }
            for (NSDictionary*dic in discussArr) {
                liveDiscussModel*discussModel=[[liveDiscussModel alloc]initWithDictionary:dic];
                [_discussArray addObject:discussModel];
            }
            if (_discussArray.count>3) {
                [_discussArray removeObjectAtIndex:0];
            }
            if (messageArr.count>0) {
                hasNewData=YES;
                if (tableViewAtTop) {
                    newmessageBtn.hidden=NO;
                }
            }
            if (_discussArray.count>0&&isFirstTime&&closeBtn.y<100) {
                [self closeOrOpenTheDiscussBoard];
                isFirstTime=NO;
            }
            [_MainTable reloadData];
            [_discussTable reloadData];
            [self discussTabelScrollToBottom];
            
            if (hasPostContent) {
                [self tableViewScrollToBottom];
                hasPostContent=NO;
            }

            //拿到最新的id
            liveCellFrameModel*messageModel=[_dataArray lastObject];
            lastMessageId=messageModel.messageModel.IDS;
            liveDiscussModel*discussModel=[_discussArray lastObject];
            lastDiscussId=discussModel.IDS;
            
            [_header endRefreshing];
            [_footer endRefreshing];
        }
        else
        {
            [_header endRefreshing];
            [_footer endRefreshing];
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_header endRefreshing];
        [_footer endRefreshing];
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-mj刷新的代理
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    timer.fireDate=[NSDate distantFuture];
    if (refreshView==_header) {
        [self setUpDataWithMessageId:firstMessageId andNext:NO];
    }
    else if (refreshView==_footer)
    {
        [self syncTheLiveData];
    }
}


#pragma mark-chatTool的delegate
-(void)InputFunctionView:(chatToolBar *)funcView sendMessage:(NSString *)message
{
    [self postTheContent:message andDuration:0];
    funcView.TextViewInput.text=@"";
}

-(void)InputFunctionView:(chatToolBar *)funcView sendPicture:(UIImage *)image andFromLibrary:(BOOL)fromLibrary
{
    if (fromLibrary) {
        [self creatLibrayViewWithImage:image];
    }
    else
    {
        [self postImage:[self fixOrientation:image]];
    }
}

-(void)InputFunctionView:(chatToolBar *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    [self postVoice:voice andDuration:second];
}

#pragma mark-发送聊天
-(void)postTheContent:(NSString*)content andDuration:(NSInteger)second
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
    NSString *duration=[NSString stringWithFormat:@"%ld",second];
    NSString *type;
    if (isPic) {
        type=@"2";
    }
    else if (isVoice) {
        type=@"1";
    }
    else
    {
        type=@"0";
    }
    NSDictionary *dic;
    if (content.length>0||[type isEqualToString:@"1"]||[type isEqualToString:@"2"]||[type isEqualToString:@"3"]) {
        dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,contentStr,type,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"content",@"type",@"random",nil]];
        if(isVoice)
        {
            dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,contentStr,type,duration,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"content",@"type",@"duration",@"random",nil]];
        }
        [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            int res=[[source objectForKey:@"res"] intValue];
            if (res==0) {
                isPic=NO;
                isVoice=NO;
                isLiveIntro=NO;
                isDoctIntro=NO;
                randomStr=SuiJiShu;
                hasPostContent=YES;
                [self syncTheLiveData];
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

#pragma mark-标记为已读
-(void)markTheMessageWithMessageId:(NSInteger)messageId
{
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[NSString stringWithFormat:@"%ld",messageId]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSDictionary *dic;
    dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"random",nil]];
  
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
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

#pragma mark-上传图床
-(void)postImage:(UIImage *)image{
    [[SetupView ShareInstance]showHUD:self Title:NSLocalizedString(@"发送中...", @"")];
    NSData *data= UIImageJPEGRepresentation(image , 1);
    NSString*url=@"http://img.augbase.com/";
    [[HttpManager ShareInstance]AFNetPOSTSupport:url Parameters:nil ConstructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"live.png" mimeType:@"png"];
    } SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"上传成功");
            [[SetupView ShareInstance]hideHUD];
            NSString*imageStr=[source objectForKey:@"data"];
            YiZhenLog(@"%@",imageStr);
            isPic=YES;
            [self postTheContent:imageStr andDuration:0];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
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
            isVoice=YES;
            [self postTheContent:voiceStr andDuration:second];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}
//结束编辑
-(void)endEdit
{
    [self.toolbar.TextViewInput resignFirstResponder];
}

#pragma mark-ActionSheet的代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 888) {
        //选择头像
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.navigationBar.tintColor=themeColor;
        if (buttonIndex == 1) {
            //开启相册
            isBackfromLibray=YES;
            imagePicker.allowsEditing =NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.navigationBar.tintColor=themeColor;
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }else if (buttonIndex == 0){
            //开启相机
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.navigationBar.tintColor=themeColor;
            [self presentViewController:imagePicker animated:YES completion:^{}];
        }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            [picker dismissViewControllerAnimated:YES completion:^{}];
            if (isBackfromLibray) {
                [self creatLibrayViewWithImage:image];
            }
            else
            {
                [self postImage:[self fixOrientation:image]];
            }
        });
    });
}

#pragma mark-创建相册返回的view
-(void)creatLibrayViewWithImage:(UIImage*)image
{
    [UIApplication sharedApplication].statusBarHidden=YES;
    blackView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
    blackView.backgroundColor=[UIColor blackColor];
    //    [self.navigationController.view addSubview:blackView];
    librayView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 64, ViewWidth, ViewHeight-64-60)];
    librayView.contentMode=UIViewContentModeScaleAspectFit;
    librayView.image=image;
    [blackView addSubview:librayView];
    
    UIButton*useBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [useBtn setFrame:CGRectMake(ViewWidth-100, ViewHeight-35, 80, 20)];
    [useBtn setTitle:@"使用照片" forState:UIControlStateNormal];
    [useBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [useBtn addTarget:self action:@selector(uploadlibrayphoto) forControlEvents:UIControlEventTouchUpInside];
    [blackView addSubview:useBtn];
    
    UIButton*rePhoto=[UIButton buttonWithType:UIButtonTypeCustom];
    [rePhoto setFrame:CGRectMake(20, ViewHeight-35, 80, 20)];
    [rePhoto setTitle:@"重新选择" forState:UIControlStateNormal];
    [rePhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rePhoto addTarget:self action:@selector(rePhoto) forControlEvents:UIControlEventTouchUpInside];
    [blackView addSubview:rePhoto];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:blackView];
}

-(void)uploadlibrayphoto
{
    [self postImage:[self fixOrientation:librayView.image]];
    [blackView removeFromSuperview];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

-(void)rePhoto
{
    [blackView removeFromSuperview];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = NO;
    __weak id weakself=self;
    picker.delegate = weakself;
    isBackfromLibray=YES;
    picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBar.tintColor=themeColor;
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark-键盘的监听事件
- (void)keyboardWillChange:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height-64;
    NSLog(@"_toolbar.y==%lf",_toolbar.y);
    NSLog(@"moveY==%lf",moveY);
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, moveY);
        //        _toolbar.transform=CGAffineTransformMakeTranslation(0, moveY);
    }];
}

#pragma mark-一些工具方法
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (BOOL)checkTime:(NSString*)time ToAfterTime:(NSString*)afterTime
{
    long presentTime = [time longLongValue] /1000;
    
    long lastTime=[afterTime longLongValue] /1000;
    
    
    if (lastTime-presentTime>60*5) {
        return YES;
    }
    return NO;
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_header||_footer) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
    if (timer.isValid) {
        [timer invalidate];
    }
    timer=nil;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];}

@end
