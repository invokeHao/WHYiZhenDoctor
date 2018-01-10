//
//  voiceBtn.h
//  yizhenDoctor
//
//  Created by augbase on 16/9/12.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface voiceBtn : UIButton

@property (strong,nonatomic)UIImageView * playBtnV;//播放按钮
@property (strong,nonatomic)UIImageView * playImageV;//播放语音动画view
@property (strong,nonatomic)UILabel * lastTimeLabel;//持续时长label
@property (assign,nonatomic)NSInteger duration;//语音时长

-(void)setDuration:(NSInteger)duration;

- (void)benginLoadVoice;

- (void)didLoadVoice;

-(void)stopPlay;

@end
