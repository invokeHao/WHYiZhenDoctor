//
//  userListTableViewCell.h
//  yizhenDoctor
//
//  Created by augbase on 16/9/14.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "userListModel.h"

@interface userListTableViewCell : UITableViewCell

@property (strong,nonatomic) UIButton * iconButton;
@property (strong,nonatomic) UILabel * nameLabel;
@property (strong,nonatomic) UILabel * timeLabel;
@property (strong,nonatomic) UIImageView * typeView;//显示标记（求助，已回复）
@property (strong,nonatomic) UILabel * contentLabel;//内容label

@property (strong,nonatomic) userListModel * listModel;


-(void)setListModel:(userListModel *)listModel;

@end
