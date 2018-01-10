//
//  liveDiscussTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "liveDiscussModel.h"

@interface liveDiscussTableViewCell : UITableViewCell

@property (strong,nonatomic) UIButton * iconButton;
@property (strong,nonatomic) UILabel * nameLabel;
@property (strong,nonatomic) UILabel * timeLabel;
@property (strong, nonatomic) UIButton *shutUpBtn;
@property (strong,nonatomic) UIImageView * typeView;//显示标记（求助，已回复）
@property (strong,nonatomic) UILabel * contentLabel;//内容label

@property (strong,nonatomic) liveDiscussModel * discussModel;

-(void)setDiscussModel:(liveDiscussModel *)discussModel;

@end
