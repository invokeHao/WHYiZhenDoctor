//
//  AllNavigationController.m
//  yizhenDoctor
//
//  Created by augbase on 16/8/25.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "AllNavigationController.h"

@interface AllNavigationController ()

@end

@implementation AllNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    UIImage*image=[UIImage imageNamed:@"back_w"];
    [[UINavigationBar appearance] setBackIndicatorImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"lineNav"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
