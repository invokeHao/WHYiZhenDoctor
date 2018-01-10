//
//  NoNetworkingView.h
//  yizhenDoctor
//
//  Created by 王浩 on 16/10/19.
//  Copyright © 2016年 augbase. All rights reserved.
//


@class NoNetworkingView;

@protocol NoNetWorkingDelegate <NSObject>

-(void)functionView:(NoNetworkingView*)view refreshWithUrl:(NSString*)Url;

@end

#import <UIKit/UIKit.h>

@interface NoNetworkingView : UIView

@property (strong,nonatomic)UIView *oopsView;
@property (strong,nonatomic)UIImageView * backImageV;
@property (strong,nonatomic)UILabel * describLael;
@property (strong,nonatomic)UIButton * refreshBtn;//刷新的button

@property (weak,nonatomic)id<NoNetWorkingDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame;
@end
