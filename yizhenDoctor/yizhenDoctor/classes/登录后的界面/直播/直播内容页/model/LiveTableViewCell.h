//
//  LiveTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "liveCellFrameModel.h"
#import "voiceBtn.h"
#import "redCircleView.h"

typedef void (^voiceBtnBlock) (BOOL haveRead,NSInteger messageId);
typedef void (^beginPlayBlock) (BOOL hasBegin);
typedef void (^endPlayBlock) (BOOL hasEnd);

@interface LiveTableViewCell : UITableViewCell
{
    NSString*picUrl;
    
    UIButton *playBtn;//播放按钮
    UIImageView * playImageV;//播放语音动画view
    UILabel * lastTimeLabel;//持续时长label
    NSInteger messageID;
    
    UILabel*titlelabel;
    UILabel*LcontentLable;
    
    UILabel*DcontentLabel;
    UILabel*doctorLabel;
    UIButton*iconBtn;
    UILabel*replyLabel;
    redCircleView*redView;//红点
}
@property (strong,nonatomic)UILabel*timeLabel;
@property (strong,nonatomic)UILabel*nameLabel;//姓名
@property (strong,nonatomic)UIImageView *iconView;
@property (strong,nonatomic)UIButton *textView;
@property (strong,nonatomic)UIImageView*imageV;
@property (strong,nonatomic)UIImageView*backView;
@property (strong,nonatomic)UIImageView * voiceView;//语音view
@property (strong,nonatomic)voiceBtn*voiceButton;
@property (strong,nonatomic)UIImageView * liveIntroView;//直播简介view
@property (strong,nonatomic)UIImageView * doctorIntroView;//医生简介view

@property (nonatomic, strong) liveCellFrameModel * liveCellFrame;

@property (nonatomic , strong) voiceBtnBlock voiceBlock;

@property (nonatomic, strong) beginPlayBlock beginBlock;

@property (nonatomic, strong) endPlayBlock endBlock;

-(void)setVoiceBlock:(voiceBtnBlock)voiceBlock;

-(void)setBeginBlock:(beginPlayBlock)beginBlock;

-(void)setEndBlock:(endPlayBlock)endBlock;

@end
