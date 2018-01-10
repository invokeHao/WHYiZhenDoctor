//
//  lveListTableViewCell.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/8.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "lveListTableViewCell.h"

@implementation lveListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
    }
    return self;
    
}

-(void)creatUI
{
    self.contentView.backgroundColor=[UIColor whiteColor];
    _iconButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _iconButton.layer.cornerRadius=30;
    _iconButton.layer.masksToBounds=YES;
    [self.contentView addSubview:_iconButton];
    
    _timesLabel=[[UILabel alloc]init];
    _timesLabel.layer.cornerRadius=2;
    _timesLabel.layer.masksToBounds=YES;
    _timesLabel.font=YiZhenFont12;
    _timesLabel.textColor=[UIColor whiteColor];
    _timesLabel.backgroundColor=grayNewlabelColor;
    [self.contentView addSubview:_timesLabel];
    
    _statueLabel=[[UILabel alloc]init];
    _statueLabel.layer.cornerRadius=2;
    _statueLabel.layer.masksToBounds=YES;
    _statueLabel.font=YiZhenFont12;
    _statueLabel.textColor=[UIColor whiteColor];
    _statueLabel.backgroundColor=themeColor;
    [self.contentView addSubview:_statueLabel];
    
    _themeLabel=[[UILabel alloc] init];
    _themeLabel.font=YiZhenFont;
    _themeLabel.numberOfLines=2;
    _themeLabel.textColor=[UIColor blackColor];
    [self.contentView addSubview:_themeLabel];
    
    _introduceLabel=[[UILabel alloc] init];
    _introduceLabel.font=YiZhenFont13;
    _introduceLabel.numberOfLines=3;
    _introduceLabel.textColor=grayLabelColor;
    [self.contentView addSubview:_introduceLabel];
    
    _liveView=[[UIView alloc] init];
    _liveView.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:_liveView];
    
    onLineView=[[UIImageView alloc]init];
    onLineView.image=[UIImage imageNamed:@"living"];
    onLineView.contentMode=UIViewContentModeScaleAspectFit;
    [_liveView addSubview:onLineView];
    
    liveLabel=[[UILabel alloc] init];
    liveLabel.font=YiZhenFont12;
    liveLabel.textColor=themeColor;
    [_liveView addSubview:liveLabel];
    
    _amountLabel=[[UILabel alloc] init];
    _amountLabel.textColor=darkTitleColor;
    _amountLabel.font=YiZhenFont12;
    [self.contentView addSubview:_amountLabel];
    
    [_iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [_timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconButton.mas_right).with.offset(15);
        make.top.equalTo(@20);
        make.height.equalTo(@18);
    }];
    
    [_statueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_timesLabel.mas_right).with.offset(3);
        make.top.equalTo(@20);
        make.height.equalTo(@18);
    }];
    
    [_themeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_timesLabel);
        make.right.equalTo(@-15);
        make.top.mas_equalTo(_timesLabel.mas_bottom).with.offset(5);
    }];
    
    [_introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_themeLabel);
        make.right.equalTo(@-15);
        make.top.mas_equalTo(_themeLabel.mas_bottom).with.offset(3);
    }];
    
    [_liveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_timesLabel);
        make.bottom.equalTo(@-17.5);
        make.height.equalTo(@15);
    }];

    [_amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(liveLabel.mas_right).with.offset(5);
        make.centerY.mas_equalTo(liveLabel);
        make.height.equalTo(@15);
    }];
}

-(void)setModel:(liveListModel *)model
{
    _model=model;
    [_iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:model.doctorAvatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_avatar3"]];
    _timesLabel.text=[NSString stringWithFormat:@" %@ ",model.tag];
    if (model.hasAttend) {
        _statueLabel.text=@"";
    }
    _themeLabel.text=model.title;
    _introduceLabel.text=model.doctorIntro;
    
    _amountLabel.text=[NSString stringWithFormat:@"已有%ld人入场",model.attends];
    onLineView.hidden=YES;
    
    if (!model.hasClosed) {
        [liveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.height.equalTo(@15);
        }];
        liveLabel.text=[model create_time:model.startTime];
        if ([liveLabel.text isEqualToString:@"直播已结束"]) {
            liveLabel.textColor=darkTitleColor;
        }
        if ([liveLabel.text isEqualToString:@"直播中"]) {
            liveLabel.text=@"直播中";
            liveLabel.textColor=[UIColor colorWithRed:250.0/255.0 green:155.0/255.0 blue:37.0/255.0 alpha:1.0];
            onLineView.hidden=NO;
            
            [onLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.equalTo(@0);
                make.size.mas_equalTo(CGSizeMake(18, 18));
            }];
            [liveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.left.mas_equalTo(onLineView.mas_right).with.offset(6);
                make.height.equalTo(@18);
            }];
        }
    }
    else if (model.hasClosed) {
        liveLabel.text=@"直播已结束";
        liveLabel.textColor=darkTitleColor;
        [liveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.left.equalTo(@0);
            make.height.equalTo(@18);
        }];
    }
}

-(void)setFrame:(CGRect)frame
{
    frame.origin.y +=10;
    frame.size.height -=10;
    [super setFrame:frame];
}

@end
