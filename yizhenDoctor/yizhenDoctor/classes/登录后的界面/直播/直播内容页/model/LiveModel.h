//
//  LiveModel.h
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveModel : NSObject

@property (strong,nonatomic) NSString * title;
@property (strong,nonatomic) NSString * content;
@property (strong,nonatomic) NSString * createTime;
@property (strong,nonatomic) NSString * creatorAvatar;
@property (assign,nonatomic) NSInteger creatorId;
@property (strong,nonatomic) NSString * creatorName;
@property (assign,nonatomic) BOOL hasRead;//是否已读
@property (assign,nonatomic) NSInteger IDS;//该消息的id
@property (strong,nonatomic) NSString * replyContent;
@property (strong,nonatomic) NSString * replyCreatorName;
@property (assign,nonatomic) NSInteger replyCreatorId;//回复人的id
@property (assign,nonatomic) BOOL sendByDoctor;//判断医生消息
@property (assign,nonatomic) BOOL sendByAssistant;//判断管理员消息
@property (assign,nonatomic) NSInteger type;//判断消息类型:0:文本,1:语音,2:图片,3:直播简介,4:医生简介
@property (assign,nonatomic) NSInteger duration;//时长

@property (assign,nonatomic) BOOL showTime;//显示时间

-(instancetype)initWithDictionary:(NSDictionary*)dic;

- (NSString *)create_time;
@end
