//
//  voiceToolView.h
//  yizhenDoctor
//
//  Created by augbase on 16/9/13.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordAudio.h"
#import "UUAVAudioPlayer.h"

@class voiceToolView;

@protocol voiceToolViewDelegate <NSObject>

//发送语音
-(void)inFunctoinVIew:(voiceToolView*)view andSendVoiceData:(NSData*)voiceData andSecond:(NSInteger)second;
-(void)inFunctoinViewCancleTheRecord;

@end

@interface voiceToolView : UIView

@property (strong,nonatomic)UUAVAudioPlayer *audio;
@property (strong,nonatomic)RecordAudio *recordAudio;

@property (strong,nonatomic)UILabel * questionLabel;//问题label
@property (strong,nonatomic)UILabel * statueLabel;//录音状态label
@property (strong,nonatomic)UIImageView * recordView;
@property (strong,nonatomic)UIButton * recordBtn;//录音按钮
@property (strong,nonatomic)UIButton * cancelBtn;//取消按钮
@property (strong,nonatomic)UIButton * repeatBtn;//重说按钮
@property (strong,nonatomic)UIButton * postBtn;//发送按钮

@property (strong,nonatomic)UIViewController * superVC;//父VC
@property (assign,nonatomic)id<voiceToolViewDelegate>  delegate;

@property (strong,nonatomic)NSString*statu;//

-(id)initWithSuperViewController:(UIViewController*)superVC;

-(void)setStatu:(NSString *)statu;
@end
