//
//  redCircleView.m
//  Yizhenapp
//
//  Created by augbase on 16/4/27.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "redCircleView.h"

@implementation redCircleView


-(instancetype)init{
    self=[super init];
    if (self) {
    }
    return self;
}

-(void)setCornerRadiu:(CGFloat)cornerRadiu
{
    _cornerRadiu=cornerRadiu;
    [self createUI];
}

-(void)createUI
{
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = _cornerRadiu;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:81.0/255.0 blue:76.0/255.0 alpha:1.0];
    
}
@end
