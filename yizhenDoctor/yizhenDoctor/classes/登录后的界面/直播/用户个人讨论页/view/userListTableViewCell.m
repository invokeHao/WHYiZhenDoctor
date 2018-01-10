//
//  userListTableViewCell.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/14.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "userListTableViewCell.h"

@implementation userListTableViewCell

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
    _iconButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _iconButton.layer.cornerRadius=16;
    _iconButton.layer.masksToBounds=YES;
    [self.contentView addSubview:_iconButton];
    
    _nameLabel=[[UILabel alloc]init];
    _nameLabel.textColor=[UIColor blackColor];
    _nameLabel.font=YiZhenFont12;
    [self.contentView addSubview:_nameLabel];
    
        
    _timeLabel=[[UILabel alloc]init];
    _timeLabel.textColor=grayLabelColor;
    _timeLabel.font=YiZhenFont12;
    [self.contentView addSubview:_timeLabel];
    
    _typeView=[[UIImageView alloc]init];
    _typeView.contentMode=UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_typeView];
    
    _contentLabel=[[UILabel alloc]init];
    _contentLabel.textColor=[UIColor blackColor];
    _contentLabel.font=YiZhenFont14;
    _contentLabel.numberOfLines=0;
    [self.contentView addSubview:_contentLabel];
    //定位控件
    [_iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@15);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconButton.mas_right).with.offset(6);
        make.top.equalTo(@18);
        make.height.equalTo(@18);
    }];
        
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_nameLabel);
        make.top.mas_equalTo(_nameLabel.mas_bottom).with.offset(2);
        make.height.equalTo(@18);
    }];
    
    [_typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.right.equalTo(@-15);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_timeLabel.mas_bottom).with.offset(8);
        make.left.mas_equalTo(_nameLabel);
        make.right.mas_equalTo(_typeView);
    }];
}

-(void)setListModel:(userListModel *)listModel
{
    _listModel=listModel;
    [_iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:_listModel.creatorAvatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_avatar3"]];
    _nameLabel.text=_listModel.creatorName;
    
    _timeLabel.text=[_listModel create_time:_listModel.createTime];
    
    if (_listModel.replyCreatorId>0) {
        NSMutableAttributedString*atrributStr=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"@%@ %@",_listModel.replyCreatorName,_listModel.content]];
        [atrributStr addAttribute:NSForegroundColorAttributeName value:themeColor range:NSMakeRange(0, _listModel.replyCreatorName.length+1)];
        _contentLabel.attributedText=atrributStr;
    }
    else
    {
        _contentLabel.text=_listModel.content;
        
    }

    _typeView.hidden=YES;
    if (_listModel.type>0) {
        _typeView.hidden=NO;
        if (_listModel.type>1) {
            //已回复
            [_typeView setImage:[UIImage imageNamed:@"help_solve"]];
        }
        else
        {
            [_typeView setImage:[UIImage imageNamed:@"help2"]];
        }
    }
}

@end
