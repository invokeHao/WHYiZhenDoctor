//
//  liveCellFrameModel.h
//  Yizhenapp
//
//  Created by augbase on 16/9/6.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveModel.h"
#define textPadding 15
@interface liveCellFrameModel : NSObject

@property (nonatomic, assign, readonly) CGRect timeFrame;
@property (nonatomic, assign, readonly) CGRect nameFrame;
@property (nonatomic, assign, readonly) CGRect iconFrame;
@property (nonatomic, assign, readonly) CGRect textFrame;
@property (nonatomic, assign, readonly) CGFloat cellHeght;

@property (strong,nonatomic) LiveModel *messageModel;

-(CGFloat)cellHeght;

@end
