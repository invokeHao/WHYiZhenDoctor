//
//  userListModel.h
//  yizhenDoctor
//
//  Created by augbase on 16/9/14.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userListModel : NSObject

//"data":[{
//    "content":"吹牛逼不好吗？",
//    "createTime":1472701449000,
//    "creatorAvatar":"http://img.augbase.com/20160817140432_nlfoh7.png",
//    "creatorId":3058,
//    "creatorName":"富贵",
//    "id":1,
//    "replyCreatorName":"富贵",
//    "replyCreatorId":1234,
//    "sendByDoctor":false,
//    "sendByAssistant":false,
//    "type":0 //0:普通,1:求助,2:已回复
//}]

@property (strong,nonatomic) NSString * content;//
@property (strong,nonatomic) NSString * createTime;//创建时间
@property (assign,nonatomic) NSInteger creatorId;//创建人id
@property (strong,nonatomic) NSString * creatorName;//创建人名字
@property (strong,nonatomic) NSString * creatorAvatar;//头像
@property (assign,nonatomic) NSInteger IDS;//创建人id
@property (strong,nonatomic) NSString * replyCreatorName;//回复人的名字
@property (assign,nonatomic) NSInteger replyCreatorId;//回复人ID
@property (assign,nonatomic) BOOL sendByDoctor;//来自医生
@property (assign,nonatomic) BOOL sendByAssistant;//来自管理员
@property (assign,nonatomic) BOOL hasShutUp;//是否被禁言
@property (assign,nonatomic) NSInteger type; //0:普通,1:求助,2:已回复

//cell布局的高度
@property (assign,nonatomic)CGFloat cellHeight;
//讨论框中文字的高度
@property (assign,nonatomic)CGFloat contentHeight;

-(instancetype)initWithDictionary:(NSDictionary*)dic;

//计算时间
- (NSString *)create_time:(NSString*)timeStr;

@end
