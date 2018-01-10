//
//  loginViewController.h
//  yizhenDoctor
//
//  Created by augbase on 16/8/25.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLabelTextFieldView.h"

@interface loginViewController : UIViewController

@property (strong,nonatomic) ImageViewLabelTextFieldView *userNameView;
@property (strong,nonatomic) ImageViewLabelTextFieldView *passWordView;


@property (strong,nonatomic) UIButton *loginButton;

@property (nonatomic,strong) UIButton *forgetPassButton;


@end
