//
//  liveDiscussViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "liveDiscussViewController.h"
#import "liveDiscussTableViewCell.h"
#import "liveDiscussModel.h"
#import "voiceToolView.h"
#import "userListViewController.h"

#define pleaseLabelText @" 提问或者说点什么"

@interface liveDiscussViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,UITextViewDelegate,voiceToolViewDelegate,UIGestureRecognizerDelegate>
{
    UIView * commentView;//回复view
    UIButton*helpbutton;
    BOOL isHelp;
    UIView * shadowView;//阴影view
    UILabel * bottomLabel;//需要承载文字
    UILabel * pleaseHodler;//textView的pleasehodler
    BOOL postSuccess;
    NSString * randomStr;
    NSString * replayID;//引用的回复id
    NSInteger tableViewRow;//长按的row
    UIView *bgView;//背景view
}
@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong,nonatomic)MJRefreshHeaderView *header;
@property (strong,nonatomic)MJRefreshFooterView *footer;
@property (assign,nonatomic)int currentpage;
@property (strong,nonatomic)UITextView* commentTextField;//评论框
@property (strong,nonatomic)voiceToolView *voiceTool;//语音处理类

@end

@implementation liveDiscussViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self regNotification];
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    randomStr=SuiJiShu;

}

-(void)creatUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    [self creatTableView];
    [self createBottomView];
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
    _MainTable.separatorInset = UIEdgeInsetsMake(0, 53, 0, 15);
    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(@0);
        make.bottom.equalTo(@-45);
    }];
    UIView*footView=[[UIView alloc]initWithFrame:CGRectZero];
    footView.backgroundColor=grayBackgroundLightColor;
    _MainTable.tableFooterView = footView;
}

-(void)createBottomView
{
    UIView*backView=[[UIView alloc]initWithFrame:CGRectMake(0, ViewHeight-64-45, ViewWidth, 45)];
    backView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:backView];
    
    bottomLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,6, ViewWidth-30, 32)];
    bottomLabel.font=[UIFont systemFontOfSize:15.0];
    bottomLabel.textColor=grayLabelColor;
    bottomLabel.layer.borderColor=darkTitleColor.CGColor;
    bottomLabel.layer.borderWidth=0.5;
    bottomLabel.layer.cornerRadius=8;
    bottomLabel.layer.masksToBounds=YES;
    bottomLabel.text=pleaseLabelText;
    [backView addSubview:bottomLabel];
    
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor=[UIColor clearColor];
    [button setFrame:bottomLabel.frame];
    [button addTarget:self action:@selector(pressToWriteTheDiscuss) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:button];
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

-(void)pressToWriteTheDiscuss
{
    [self createCommentView];
    if (![bottomLabel.text isEqualToString:pleaseLabelText]) {
        _commentTextField.text=bottomLabel.text;
    }
    [_commentTextField becomeFirstResponder];
}

-(void)createCommentView
{
    //创建阴影view
    shadowView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
    shadowView.backgroundColor=[UIColor colorWithWhite:0.3 alpha:0.3];
    [self.navigationController.view addSubview:shadowView];
    
    //创建回复的view
    commentView=[[UIView alloc]initWithFrame:CGRectMake(0, ViewHeight-120, ViewWidth, 120)];
    commentView.backgroundColor=[UIColor whiteColor];
    [shadowView addSubview:commentView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 1)];
    lineView.backgroundColor=darkTitleColor;
    [commentView addSubview:lineView];
    
    _commentTextField=[[UITextView alloc]initWithFrame:CGRectMake(15, 44, ViewWidth-30, 56)];
    _commentTextField.delegate=self;
    _commentTextField.layer.cornerRadius=8;
    _commentTextField.layer.masksToBounds=YES;
    _commentTextField.layer.borderColor=darkTitleColor.CGColor;
    _commentTextField.layer.borderWidth=0.5;
    _commentTextField.font=YiZhenFont14;
    [commentView addSubview:_commentTextField];
    
    pleaseHodler=[[UILabel alloc]initWithFrame:CGRectMake(0, 6, 80, 22)];
    pleaseHodler.text=pleaseLabelText;
    pleaseHodler.font=YiZhenFont14;
    pleaseHodler.textColor=grayLabelColor;
    [_commentTextField addSubview:pleaseHodler];
    
    UIButton*postBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [postBtn setTitle:@"发送" forState:UIControlStateNormal];
    [postBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [postBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [postBtn setFrame:CGRectMake(ViewWidth-15-32, 13, 32, 22)];
    [postBtn addTarget:self action:@selector(postTheDiscuss) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:postBtn];
    
    UIButton*cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [cancelBtn setTitleColor:grayLabelColor forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(15, 13, 32, 22)];
    [cancelBtn addTarget:self action:@selector(tapToHidenTheShadow) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:cancelBtn];
}

-(void)creatNoDiscussView
{
    bgView=[[UIView alloc]initWithFrame:self.MainTable.frame];
    bgView.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:bgView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    
    YiZhenLog(@"%lf",lineView.frame.origin.y);
    [bgView addSubview:lineView];
    
    UIImageView*image=[[UIImageView alloc]init];
    image.center=CGPointMake(ViewWidth/2, ViewHeight/2-64);
    image.bounds=CGRectMake(0, 0, 240, 240);
    image.image=[UIImage imageNamed:@"no_help"];
    image.contentMode=UIViewContentModeScaleAspectFit;
    [bgView addSubview:image];
}

-(void)tapToHidenTheShadow
{
    if (shadowView) {
        [shadowView removeFromSuperview];
        [_commentTextField resignFirstResponder];
        bottomLabel.text=pleaseLabelText;
        if (_commentTextField.text.length>0) {
            bottomLabel.text=[NSString stringWithFormat:@" %@",_commentTextField.text];
        }
        isHelp=NO;
        _voiceTool.recordAudio=nil;
        [_voiceTool.audio stopSound];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"提问";
    tableViewRow=10000;//目的为了拦截长按导致的多次页面跳转
    
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    _header.delegate = self;
    _footer.delegate = self;

    [self setUpData];
    
    UIButton*backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回直播间" forState:UIControlStateNormal];
    [backBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [backBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [backBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -18, 0, 0)];
    [backBtn setFrame:CGRectMake(0, 0, 90, 22)];
    [backBtn addTarget:self action:@selector(pressToBackTheLive) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*back=[[UIBarButtonItem alloc]initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:back];
    
    //加入长按手势
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.7; //seconds  设置响应时间
    lpgr.delegate = self;
    [_MainTable addGestureRecognizer:lpgr];
}

-(void)pressToBackTheLive
{
    _block(YES);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-tabelView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArray.count==0) {
        return 190;
    }
    else {
        liveDiscussModel*model=_dataArray[indexPath.row];
        return model.cellHeight;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    liveDiscussTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"discussCell"];
    if (cell==nil) {
        cell=[[liveDiscussTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCell"];
    }
    if (_dataArray.count==0) {
        
    }
    else
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        liveDiscussModel*model=_dataArray[indexPath.row];
        [cell setDiscussModel:model];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self createAnswerView];
    liveDiscussModel*model=_dataArray[indexPath.row];
    replayID=[NSString stringWithFormat:@"%ld",model.IDS];
    
    [_voiceTool setStatu:[NSString stringWithFormat:@"%@：%@",model.creatorName,model.content]];
}

- (void)tableViewScrollToTop{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_MainTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark-长按相应函数
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer  //
{
    CGPoint p=[gestureRecognizer locationInView:_MainTable];
    
    NSIndexPath *indexPath = [_MainTable indexPathForRowAtPoint:p];//获取响应的长按的indexpath
    if (tableViewRow==indexPath.row) {
        return;
    }
    tableViewRow=indexPath.row;
    if (indexPath == nil)
    {
        NSLog(@"long press on table view but not on a row");
    }
    else
    {
        [_MainTable removeGestureRecognizer:gestureRecognizer];
        liveDiscussModel*model=_dataArray[indexPath.row];
        userListViewController*userListVC=[[userListViewController alloc]init];
        userListVC.liveId=_liveId;
        userListVC.userId=model.creatorId;
        userListVC.themeTitle=model.creatorName;
        [self.navigationController pushViewController:userListVC animated:YES];
        NSLog(@"long press on table view at row %ld", (long)indexPath.row);
    }
}
-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/discuss?uid=%@&token=%@&page=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"讨论列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                liveDiscussModel*model=[[liveDiscussModel alloc]initWithDictionary:dic];
                [_dataArray addObject:model];
            }
            if (_dataArray.count<1) {
                [self creatNoDiscussView];
                return ;
            }
            [self.header endRefreshing];
            [self.footer endRefreshing];
            [_MainTable reloadData];
            if (postSuccess) {
                [self tableViewScrollToTop];
                postSuccess=NO;
            }
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

#pragma mark-发送讨论
-(void)postTheDiscuss
{
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/sendDiscuss",Baseurl,[NSString stringWithFormat:@"%ld",_liveId]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSString *contentStr=_commentTextField.text;
    NSString *seekingHelp;
    seekingHelp=@"false";
    if (isHelp) {
      seekingHelp=@"true";
    }
    NSDictionary*dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,contentStr,seekingHelp,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"content",@"seekingHelp",@"random",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"回复成功");
            isHelp=NO;
            postSuccess=YES;
            _commentTextField.text=@"";
            _currentpage=1;
            randomStr=SuiJiShu;
            [_dataArray removeAllObjects];
            [self tapToHidenTheShadow];
            [self setUpData];
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

-(void)postVoice:(NSData*)voiceData andDuration:(NSInteger)duration
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
            [self postTheContent:voiceStr andReplyId:replayID andDuration:duration];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-发送聊天
-(void)postTheContent:(NSString*)content andReplyId:(NSString*)replyId andDuration:(NSInteger)duration{
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
                _currentpage=1;
                [self setUpData];
                _block(YES);
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
            [[SetupView ShareInstance]hideHUD];
        }];
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

#pragma mark-textView的代理方法
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length>0) {
        pleaseHodler.hidden=YES;
    }
}

#pragma mark-键盘相关
- (void)regNotification
{
    //使用NSNotificationCenter 键盘将要出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)unregNotification
{
    //释放kvo
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height-64;
    if (keyFrame.origin.y<ViewHeight) {
        [UIView animateWithDuration:duration animations:^{
            commentView.transform=CGAffineTransformMakeTranslation(0, moveY);
        }];
        //遮盖view的点击事件
        UIButton*tapButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [tapButton setBackgroundColor:[UIColor clearColor]];
        [tapButton setFrame:CGRectMake(0, 0, ViewWidth, commentView.y)];
        [tapButton addTarget:self action:@selector(tapToHidenTheShadow) forControlEvents:UIControlEventTouchUpInside];
        [shadowView addSubview:tapButton];
        [shadowView bringSubviewToFront:commentView];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            commentView.transform=CGAffineTransformMakeTranslation(0, moveY);
        }];
        [self tapToHidenTheShadow];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_header removeFromSuperview];
    [_footer removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
