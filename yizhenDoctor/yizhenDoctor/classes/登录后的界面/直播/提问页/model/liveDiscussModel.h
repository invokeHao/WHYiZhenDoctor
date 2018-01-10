//
//  liveDiscussModel.h
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface liveDiscussModel : NSObject

@property (strong,nonatomic)NSString * content;
@property (strong,nonatomic)NSString * createTime;
@property (strong,nonatomic)NSString * creatorAvatar;
@property (assign,nonatomic)NSInteger creatorId;//发帖人id
@property (strong,nonatomic)NSString * creatorName;//姓名
@property (assign,nonatomic)NSInteger IDS;//消息的id
@property (strong,nonatomic) NSString * replyCreatorName;//回复人的名字
@property (assign,nonatomic) NSInteger replyCreatorId;//回复人ID
@property (assign,nonatomic) BOOL sendByDoctor;//来自医生
@property (assign,nonatomic) BOOL sendByAssistant;//来自管理员
@property (assign,nonatomic) BOOL hasShutUp;//是否被禁言

@property (assign,nonatomic)NSInteger type;//0:普通,1:求助,2:已回复

//cell布局的高度
@property (assign,nonatomic)CGFloat cellHeight;
//讨论框中文字的高度
@property (assign,nonatomic)CGFloat contentHeight;

-(instancetype)initWithDictionary:(NSDictionary*)dic;

//计算时间
- (NSString *)create_time:(NSString*)timeStr;

@end
