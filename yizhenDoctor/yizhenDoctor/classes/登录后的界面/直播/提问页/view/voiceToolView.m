//
//  voiceToolView.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/13.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "voiceToolView.h"


@interface voiceToolView()<RecordAudioDelegate,UUAVAudioPlayerDelegate>
{
    BOOL isbeginVoiceRecord;
    BOOL isPlaying;//正在播放
    BOOL contentVoiceIsPlaying;
    NSData *curAudio;
    
    NSInteger playTime;
    NSTimer *playTimer;
    NSTimer *voiceTimer;
    int voiceTime;
}
@end

@implementation voiceToolView

-(id)initWithSuperViewController:(UIViewController *)superVC
{
    self.superVC=superVC;
    
    self=[super initWithFrame:CGRectMake(0, ViewHeight-45-262, ViewWidth, 45+262)];
    if (self) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI
{
    _recordAudio = [[RecordAudio alloc]init];
    _recordAudio.delegate = self;

    self.backgroundColor=[UIColor whiteColor];
    
    UIView*quesview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 45)];
    quesview.backgroundColor=[UIColor clearColor];
    quesview.layer.borderColor=lightGrayBackColor.CGColor;
    quesview.layer.borderWidth=0.5;
    [self addSubview:quesview];
    
    _questionLabel=[[UILabel alloc]init];
    _questionLabel.textColor=grayLabelColor;
    _questionLabel.font=YiZhenFont;
    [quesview addSubview:_questionLabel];
    
    _statueLabel=[[UILabel alloc]init];
    _statueLabel.textColor=grayLabelColor;
    _statueLabel.font=YiZhenFont;
    _statueLabel.text=@"点击说话";
    [self addSubview:_statueLabel];
    
    _recordView=[[UIImageView alloc]init];
    _recordView.layer.cornerRadius=60;
    _recordView.layer.masksToBounds=YES;
    _recordView.userInteractionEnabled=YES;
    [_recordView setImage:[UIImage imageNamed:@"recording"]];
    [_recordView setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"recording_gif1"],[UIImage imageNamed:@"recording_gif2"],[UIImage imageNamed:@"recording_gif3"],[UIImage imageNamed:@"recording_gif4"], nil]];
    _recordView.animationDuration=1;
    _recordView.animationRepeatCount=0;
    [self addSubview:_recordView];
    
    _recordBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _recordBtn.layer.cornerRadius=60;
    _recordBtn.layer.masksToBounds=YES;
    _recordBtn.backgroundColor=[UIColor clearColor];
    [_recordBtn setFrame:CGRectMake(0, 0, 120, 120)];
    [_recordBtn addTarget:self action:@selector(pressToBeginRecording:) forControlEvents:UIControlEventTouchUpInside];
    [_recordView addSubview:_recordBtn];
    
    UIView * lineView=[[UIView alloc]init];
    lineView.backgroundColor=lightGrayBackColor;
    [self addSubview:lineView];
    
    UIView*buttonView=[[UIView alloc]init];
    buttonView.backgroundColor=[UIColor clearColor];
    [self addSubview:buttonView];
    
    _cancelBtn=[self creatButtonWithTitle:@"取消"];
    [_cancelBtn setFrame:CGRectMake(0, 0, ViewWidth/3, 52)];
    [buttonView addSubview:_cancelBtn];
    
    UIView*lineView1=[[UIView alloc]initWithFrame:CGRectMake(ViewWidth/3, 14, 0.5, 32)];
    lineView1.backgroundColor=lightGrayBackColor;
    [buttonView addSubview:lineView1];
    
    _repeatBtn=[self creatButtonWithTitle:@"重说"];
    [_repeatBtn setFrame:CGRectMake(ViewWidth/3, 0, ViewWidth/3, 52)];
    [buttonView addSubview:_repeatBtn];
    
    UIView*lineView2=[[UIView alloc]initWithFrame:CGRectMake(ViewWidth/3*2, 14, 0.5, 32)];
    lineView2.backgroundColor=lightGrayBackColor;
    [buttonView addSubview:lineView2];
    
    _postBtn=[self creatButtonWithTitle:@"发送"];
    [_postBtn setFrame:CGRectMake(ViewWidth/3*2, 0, ViewWidth/3, 52)];
    [buttonView addSubview:_postBtn];

    //布局
    [_questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(quesview);
        make.left.equalTo(@15);
        make.right.equalTo(@-15);
        make.height.equalTo(@22);
    }];
    
    [_statueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(quesview.mas_bottom).with.offset(20);
        make.height.equalTo(@22);
    }];
    
    [_recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_statueLabel.mas_bottom).with.offset(19);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_recordBtn.mas_bottom).with.offset(29);
        make.left.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(ViewWidth, 0.5));
    }];
    
    [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView).with.offset(0);
        make.left.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(ViewWidth, 52));
    }];
    
}

-(UIButton*)creatButtonWithTitle:(NSString*)title
{
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:YiZhenFont];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button addTarget:self action:@selector(pressToHandleTheVoice:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)setStatu:(NSString *)statu
{
    _questionLabel.text=statu;
}


#pragma mark-点击开始录音
-(void)pressToBeginRecording:(UIButton*)button
{
    if (curAudio) {
        if (isPlaying) {
            //停止播放录音
            [_recordView setImage:[UIImage imageNamed:@"suspend"]];
            [_audio stopSound];
            voiceTimer.fireDate=[NSDate distantFuture];
            _statueLabel.text=@"0:00";
            isPlaying=NO;
        }
        else
        {
            [playTimer invalidate];
            voiceTime=(int)playTime;
            if (voiceTimer==nil) {
                voiceTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reduceTheCount) userInfo:nil repeats:YES];
            }
            voiceTimer.fireDate=[NSDate distantPast];
            //设置时间label
            int min=(int)playTime/60;
            int second=(int)playTime;
            if (min>0) {
                second=(int)playTime-min*60;
            }
            _statueLabel.text=[NSString stringWithFormat:@"%d:%.2d",min,second];
            //开始播放录音
            contentVoiceIsPlaying = YES;
            _audio = [UUAVAudioPlayer sharedInstance];
            _audio.delegate = self;
            [_audio playSongWithData:curAudio];
            
            isPlaying=YES;
        }
    }
    else
    {
        if (isbeginVoiceRecord) {
            [_recordView stopAnimating];
            [playTimer invalidate];
            playTimer=nil;
            NSURL*url=[_recordAudio stopRecord];
            if (url != nil) {
                curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url],1,16);
            }
            int min=(int)playTime/60;
            int second=(int)playTime;
            if (min>0) {
                second=(int)playTime-min*60;
            }
            _statueLabel.text=[NSString stringWithFormat:@"%d:%.2d",min,second];
            [_recordView setImage:[UIImage imageNamed:@"broadcast2"]];
        }
        else
        {
            if (playTimer==nil) {
                playTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
            }
            playTime=0;
            _statueLabel.text=@"点击停止";
            [_recordView startAnimating];
            [_recordAudio stopPlay];
            [_recordAudio startRecord];
            isbeginVoiceRecord=YES;
        }
    }
}

-(void)countTime
{
    playTime++;
    if (playTime>180) {
        NSLog(@"录音时间超出时长限制");
        [playTimer invalidate];
        playTimer=nil;
    }
}

-(void)reduceTheCount
{
    int min=0;
    int second=0;
    if (voiceTime<60&&voiceTime>-1) {
        _statueLabel.text=[NSString stringWithFormat:@"0:%.2d",voiceTime];
    }
    if(voiceTime>60&&voiceTime==60)
    {
        min=voiceTime/60;
        second=voiceTime-min*60;
        _statueLabel.text=[NSString stringWithFormat:@"%d:%.2d",min,second];
    }
    if (voiceTime==-1) {
        isPlaying=NO;
        voiceTimer.fireDate=[NSDate distantFuture];
        voiceTimer=nil;
    }
    voiceTime--;
}

#pragma mark-对录音的操作事件
-(void)pressToHandleTheVoice:(UIButton*)button
{
    if (button==_postBtn) {
        if (curAudio) {
            [self.delegate inFunctoinVIew:self andSendVoiceData:curAudio andSecond:playTime];
        } 
    }
    if (button==_cancelBtn) {
        [self.delegate inFunctoinViewCancleTheRecord];//取消
    }
    if (button==_repeatBtn) {
        [_recordAudio stopPlay];
        curAudio=nil;
        voiceTime=0;
        _statueLabel.text=@"点击说话";
        [_recordView setImage:[UIImage imageNamed:@"recording"]];
        isbeginVoiceRecord=NO;
        
    }
}
-(void)RecordStatus:(int)status {
    if (status==0){
        //播放中
    } else if(status==1){
        //完成
        isPlaying=NO;
        NSLog(@"播放完成");
    }else if(status==2){
        //出错
        NSLog(@"播放出错");
    }
}

#pragma mark-点击播放语音
-(void)pressToPlayVoice
{
    contentVoiceIsPlaying = YES;
    _audio = [UUAVAudioPlayer sharedInstance];
    _audio.delegate = self;
    [_audio playSongWithData:curAudio];
}

-(void)UUAVAudioPlayerBeiginPlay
{
    [_recordView setImage:[UIImage imageNamed:@"suspend"]];
 
}

- (void)UUAVAudioPlayerBeiginLoadVoice{
    [_recordView setImage:[UIImage imageNamed:@"suspend"]];
}

- (void)UUAVAudioPlayerDidFinishPlay{
    contentVoiceIsPlaying = NO;
    [[UUAVAudioPlayer sharedInstance]stopSound];
    
    int min=(int)playTime/60;
    int second=(int)playTime;
    if (min>0) {
        second=(int)playTime-min*60;
    }
    _statueLabel.text=[NSString stringWithFormat:@"%d:%.2d",min,second];
    [_recordView setImage:[UIImage imageNamed:@"broadcast2"]];


}

-(void)UUAVAudioPlayerStopPlay
{
    [_recordView setImage:[UIImage imageNamed:@"broadcast2"]];
}



@end
