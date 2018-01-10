//
//  WHProgressHUD.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/9.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "WHProgressHUD.h"

@interface WHProgressHUD()
{
    UIImageView * microphoneView;//麦克风view
    UILabel * statueLabel;//录音状态lable
    UIView*centerView;//中间的背景图
}
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;

@end

@implementation WHProgressHUD

@synthesize overlayWindow;

+ (WHProgressHUD*)sharedView {
    static dispatch_once_t once;
    static WHProgressHUD *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[WHProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        sharedView.backgroundColor = [UIColor clearColor];
    });
    return sharedView;
}

+ (void)show {
    [[WHProgressHUD sharedView] show];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alpha=1;
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        //初始化
        if (!self.subTitleLabel){
            self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.subTitleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!microphoneView)
            microphoneView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice2_gif1"]];
        
        if (!centerView) {
            centerView=[[UIView alloc]init];
        }
        
        if (!statueLabel) {
            statueLabel=[[UILabel alloc]init];
        }
        
        centerView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 - 30);        centerView.bounds=CGRectMake(0, 0, 130, 130);
        centerView.layer.cornerRadius=10;
        centerView.layer.masksToBounds=YES;
        centerView.backgroundColor=[UIColor colorWithWhite:0.4 alpha:1];
        
        self.subTitleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,centerView.centerY+130);
        self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];


        
        microphoneView.frame = CGRectMake(47, 26, 36, 60);
        microphoneView.animationImages=[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"voice2_gif1"],
                                        [UIImage imageNamed:@"voice2_gif2"],
                                        [UIImage imageNamed:@"voice2_gif3"],
                                        [UIImage imageNamed:@"voice2_gif4"],nil];
        microphoneView.animationDuration = 1;
        microphoneView.animationRepeatCount = 0;
        [microphoneView startAnimating];
        
        statueLabel.frame=CGRectMake(11.5, 103, 108, 17);
        statueLabel.textColor=[UIColor whiteColor];
        statueLabel.textAlignment=NSTextAlignmentCenter;
        statueLabel.font=[UIFont fontWithName:@"PingFangSC-Light" size:12.0];
        statueLabel.text=@"手指上滑，取消发送";

        
        [centerView addSubview:microphoneView];
        [centerView addSubview:statueLabel];
        
        [self addSubview:centerView];
        [self addSubview:self.subTitleLabel];
    });
}

+ (void)changeSubTitle:(NSString *)str
{
    [[WHProgressHUD sharedView] setState:str];
}

- (void)setState:(NSString *)str
{
    statueLabel.text = str;
}

+ (void)dismissWithSuccess:(NSString *)str {
    [[WHProgressHUD sharedView] dismiss:str];
}

+ (void)dismissWithError:(NSString *)str {
    [[WHProgressHUD sharedView] dismiss:str];
}

- (void)dismiss:(NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        statueLabel.text = state;
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [centerView removeFromSuperview];
                                 centerView = nil;
                                 [microphoneView removeFromSuperview];
                                 microphoneView = nil;
                                 [self.subTitleLabel removeFromSuperview];
                                 self.subTitleLabel = nil;
                                 
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                             }
                         }];
    });
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = NO;
        [overlayWindow makeKeyAndVisible];
    }
    return overlayWindow;
}


@end
