//
//  LiveModel.m
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "LiveModel.h"

@implementation LiveModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.content=dic[@"content"];
        self.createTime=dic[@"createTime"];
        self.creatorAvatar=[dic[@"creatorAvatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.creatorId=[dic[@"creatorId"] integerValue];
        self.creatorName=dic[@"creatorName"];
        self.hasRead=[dic[@"hasRead"] boolValue];
        self.IDS=[dic[@"id"] integerValue];
        self.replyContent=dic[@"replyContent"];
        self.replyCreatorName=dic[@"replyCreatorName"];
        self.replyCreatorId=[dic[@"replyCreatorId"] integerValue];
        self.sendByDoctor=[dic[@"sendByDoctor"] boolValue];
        self.sendByAssistant=[dic[@"sendByAssistant"] boolValue];
        self.type=[dic[@"type"] integerValue];
        self.duration=[dic[@"duration"] integerValue];
    }
    return self;
}

- (NSString *)create_time
{
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    // 帖子的创建时间
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:[_createTime longLongValue] /1000];
    
    
    if (create.isThisYear) { // 今年
        if (create.isToday) { // 今天
            NSDateComponents *cmps = [[NSDate date] deltaFrom:create];
            
            if (cmps.hour >= 1) { // 时间差距 >= 1小时
                return [NSString stringWithFormat:@"%zd小时前", cmps.hour];
            } else if (cmps.minute >= 5) { // 1小时 > 时间差距 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟前", cmps.minute];
            } else { // 5分钟 > 时间差距
                return @"刚刚";
            }
        } else if (create.isYesterday) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:create];
        } else { // 其他
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:create];
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:create];
    }
}

@end
