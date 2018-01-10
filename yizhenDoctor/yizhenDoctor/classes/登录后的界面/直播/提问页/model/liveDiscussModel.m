//
//  liveDiscussModel.m
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "liveDiscussModel.h"

@implementation liveDiscussModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.content=dic[@"content"];
        self.createTime=dic[@"createTime"];
        self.creatorAvatar=[dic[@"creatorAvatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.creatorId=[dic[@"creatorId"] integerValue];
        self.creatorName=dic[@"creatorName"];
        self.IDS=[dic[@"id"] integerValue];
        self.replyCreatorName=dic[@"replyCreatorName"];
        self.replyCreatorId=[dic[@"replyCreatorId"] integerValue];
        self.sendByDoctor=[dic[@"sendByDoctor"] boolValue];
        self.sendByAssistant=[dic[@"sendByAssistant"] boolValue];
        self.hasShutUp=[dic[@"hasShutUp"] boolValue];
        self.type=[dic[@"type"] integerValue];
    }
    return self;
}

- (CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 68, MAXFLOAT);
        // 计算文字的高度
        NSString * mutableContent=[NSString stringWithFormat:@"@%@ %@",self.replyCreatorName,self.content];
        CGFloat contentH;
        if (self.replyCreatorId>0) {
            contentH = [mutableContent boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : YiZhenFont14 } context:nil].size.height;
        }
        else
        {
            contentH = [self.content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : YiZhenFont14 } context:nil].size.height;
        }
        
            _cellHeight = 64+contentH+15;
    }
    return _cellHeight;
}

-(CGFloat)contentHeight
{
    if (!_contentHeight) {
        CGSize maxSize=CGSizeMake(150, MAXFLOAT);
        CGFloat contentH = [self.content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : YiZhenFont12} context:nil].size.height;
        if (contentH>26) {
            contentH=26;
        }
        _contentHeight=10+contentH+10;
    }
    return _contentHeight;
}

- (NSString *)create_time:(NSString*)timeStr
{
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    // 帖子的创建时间
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:[timeStr longLongValue] /1000];
    
    
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
