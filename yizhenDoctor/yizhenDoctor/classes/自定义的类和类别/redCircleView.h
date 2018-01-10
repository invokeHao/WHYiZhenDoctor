//
//  redCircleView.h
//  Yizhenapp
//
//  Created by augbase on 16/4/27.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface redCircleView : UILabel

@property (assign,nonatomic)CGFloat cornerRadiu;//所需的圆角数

-(instancetype)init;

-(void)setCornerRadiu:(CGFloat)cornerRadiu;
@end
