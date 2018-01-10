//
//  discussTableViewCell.m
//  Yizhenapp
//
//  Created by augbase on 16/9/7.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "discussTableViewCell.h"

@implementation discussTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        [self creatUI];
    }
    return self;
}

-(void)creatUI
{
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    _contentLabel=[[UILabel alloc]init];
    _contentLabel.font=YiZhenFont12;
    _contentLabel.textColor=[UIColor whiteColor];
    _contentLabel.numberOfLines=2;
    [self.contentView addSubview:_contentLabel];
    
    _tagView=[[UIImageView alloc]init];
    _tagView.image=[UIImage imageNamed:@"help2"];
    _tagView.layer.cornerRadius=4;
    _tagView.layer.masksToBounds=YES;
    [self.contentView addSubview:_tagView];
    
    [_tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.mas_equalTo(_contentLabel.mas_top).with.offset(2);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];

}

-(void)setModel:(liveDiscussModel *)model
{
    _model=model;
    _contentLabel.text=model.content;
    _tagView.hidden=NO;
    [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.equalTo(@-15);
        if (model.type==1) {
            make.left.mas_equalTo(_tagView.mas_right).with.offset(2);
        }
        else
        {
            make.left.equalTo(@15);
        }
    }];
    if (model.type!=1) {
        _tagView.hidden=YES;
    }
}

@end
