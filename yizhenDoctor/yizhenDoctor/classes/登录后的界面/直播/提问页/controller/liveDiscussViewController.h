//
//  liveDiscussViewController.h
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RefreshBlock)(BOOL hadCommit);

@interface liveDiscussViewController : UIViewController

@property (assign,nonatomic)NSInteger liveId;//直播id
@property (strong,nonatomic)RefreshBlock block;

-(void)setBlock:(RefreshBlock)block;
@end
