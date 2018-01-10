//
//  voiceBtn.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/12.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "voiceBtn.h"

@interface voiceBtn ()
@end

@implementation voiceBtn

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI
{
    self.layer.cornerRadius=20;
    self.layer.masksToBounds=YES;
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(15, 0, ViewWidth-30, 0.5)];
    lineView.backgroundColor=[UIColor whiteColor];
    [self addSubview:lineView];

    _duration=0;
    _playBtnV=[[UIImageView alloc]init];
    [_playBtnV setImage:[UIImage imageNamed:@"broadcast"]];
//    [_playBtnV setImage:[UIImage imageNamed:@"broadcast_2"]];
    [self addSubview:_playBtnV];
    //播放音乐view
    _playImageV=[[UIImageView alloc]init];
    _playImageV.image=[UIImage imageNamed:@"voice_gif1"];
    _playImageV.animationImages=[NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"voice_gif1"],
                                 [UIImage imageNamed:@"voice_gif2"],
                                 [UIImage imageNamed:@"voice_gif3"],nil];
    _playImageV.animationDuration = 0.3;
    _playImageV.animationRepeatCount = 0;
    [self addSubview:_playImageV];
    //时长label
    _lastTimeLabel=[[UILabel alloc]init];
    _lastTimeLabel.font=YiZhenFont13;
    _lastTimeLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:_lastTimeLabel];
    
    [_playBtnV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@6);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    [_playImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_playBtnV.mas_right).with.offset(9);
        make.top.mas_equalTo(@9);
        make.size.mas_equalTo(CGSizeMake(70, 22));
    }];
    [_lastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.top.equalTo(@10);
        make.height.equalTo(@20);
    }];
}

-(void)setDuration:(NSInteger)duration
{
    _duration=duration;
    [self refrshTheTimeLableWithTime:_duration];
}

-(void)benginLoadVoice
{
    _playImageV.hidden = YES;
}
- (void)didLoadVoice
{
 
    [_playBtnV setImage:[UIImage imageNamed:@"broadcast_2"]];
    _playImageV.hidden = NO;
    [_playImageV startAnimating];
}

-(void)stopPlay
{
    [_playBtnV setImage:[UIImage imageNamed:@"broadcast"]];
    [_playImageV stopAnimating];
}

-(void)refrshTheTimeLableWithTime:(NSInteger)duration
{
    int min,second;
    min=(int)duration/60;
    second=(int)duration-min*60;
    _lastTimeLabel.text=[NSString stringWithFormat:@"%d:%.2d",min,second];
}

@end
