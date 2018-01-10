//
//  NoNetworkingView.m
//  yizhenDoctor
//
//  Created by 王浩 on 16/10/19.
//  Copyright © 2016年 augbase. All rights reserved.
//

#define KOopViewH 150
#define kMargin 8

#import "NoNetworkingView.h"

@implementation NoNetworkingView

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    self.backgroundColor=grayBackgroundLightColor;
    
    _oopsView=[[UIView alloc]init];
    _oopsView.center=CGPointMake(ViewWidth/2, ViewHeight/2-64);
    _oopsView.bounds=CGRectMake(0, 0, ViewWidth-100, KOopViewH);
    _oopsView.backgroundColor=[UIColor clearColor];
    [self addSubview:_oopsView];
    
    _backImageV=[[UIImageView alloc]init];
    _backImageV.image=[UIImage imageNamed:@"oops"];
    [_oopsView addSubview:_backImageV];
    
    _describLael=[[UILabel alloc]init];
    _describLael.textColor=darkTitleColor;
    _describLael.text=@"天下没有不断的网，检查一下再试试";
    _describLael.font=YiZhenFont13;
    [_oopsView addSubview:_describLael];
    
    _refreshBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_refreshBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [_refreshBtn setTitle:@"刷新试试" forState:UIControlStateNormal];
    [_refreshBtn setTitleColor:grayLabelColor forState:UIControlStateNormal];
    [_refreshBtn addTarget:self action:@selector(pressToRefresh) forControlEvents:UIControlEventTouchUpInside];
    [_oopsView addSubview:_refreshBtn];
    //适配控件
    [_backImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_oopsView);
        make.top.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(105, 68));
    }];
    
    [_describLael mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_oopsView);
        make.top.mas_equalTo(_backImageV.mas_bottom).with.offset(8);
        make.height.equalTo(@18);
    }];
    
    [_refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_oopsView);
        make.top.mas_equalTo(_describLael.mas_bottom).with.offset(8);
        make.size.mas_equalTo(CGSizeMake(68, 22));
    }];
    
}

-(void)pressToRefresh
{
    [self.delegate functionView:self refreshWithUrl:nil];
}

@end
