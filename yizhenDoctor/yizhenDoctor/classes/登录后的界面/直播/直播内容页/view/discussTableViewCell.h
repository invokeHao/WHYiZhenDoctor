//
//  discussTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/9/7.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "liveDiscussModel.h"

@interface discussTableViewCell : UITableViewCell

@property (strong,nonatomic)UILabel* contentLabel;
@property (strong,nonatomic)UIImageView * tagView;//标记的label

@property (strong,nonatomic)liveDiscussModel*model;

-(void)setModel:(liveDiscussModel *)model;
@end
