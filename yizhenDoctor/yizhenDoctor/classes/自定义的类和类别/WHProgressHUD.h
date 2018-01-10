//
//  WHProgressHUD.h
//  yizhenDoctor
//
//  Created by augbase on 16/9/9.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHProgressHUD : UIView

@property (nonatomic, strong) UILabel *subTitleLabel;

+ (void)show;

+ (void)dismissWithSuccess:(NSString *)str;

+ (void)dismissWithError:(NSString *)str;

+ (void)changeSubTitle:(NSString *)str;

@end
