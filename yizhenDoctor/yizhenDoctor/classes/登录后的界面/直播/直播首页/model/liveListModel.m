//
//  liveListModel.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/8.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "liveListModel.h"

@implementation liveListModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.doctorAvatar=[dic[@"doctorAvatar"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.doctorId=[dic[@"doctorId"] integerValue];
        self.doctorIntro=dic[@"doctorIntro"];
        self.doctorIntroLink=dic[@"doctorIntroLink"];
        self.doctorName=dic[@"doctorName"];
        self.hasAttend=[dic[@"hasAttend"] boolValue];
        self.hasClosed=[dic[@"hasClosed"] boolValue];
        self.IDS=[dic[@"id"] integerValue];
        self.intro=dic[@"intro"];
        self.startTime=dic[@"startTime"];
        self.tag=dic[@"tag"];
        self.title=dic[@"title"];
        self.attends=[dic[@"attends"] integerValue];
    }
    return self;
}

- (CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 90- 15, MAXFLOAT);
        // 计算文字的高度
//        NSString*titleStr=[NSString stringWithFormat:@"%@医生：%@",self.doctorName,self.title];
        
        CGFloat titleH = [self.title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : YiZhenFont } context:nil].size.height;
        //        NSLog(@"textH==%lf",textH);
        CGFloat introH = [self.doctorIntro boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : YiZhenFont13 } context:nil].size.height;
        if (introH>60) {
            introH=60;
        }
        _cellHeight = 44+titleH+2+introH+37+10;
    }
    return _cellHeight;
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
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSString *nowDateStr=[fmt stringFromDate:[NSDate date]];
    NSDate *date=[NSDate date];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSInteger intervalS=  [zone secondsFromGMTForDate:create];
    NSDate *localDate = [[NSDate date] dateByAddingTimeInterval:interval];
    NSDate * startDate= [create dateByAddingTimeInterval:intervalS];
    
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond  fromDate:localDate toDate:startDate options:0];
//    NSLog(@"天%ld..时%ld...分%ld",cmps.day,cmps.hour,cmps.minute);
    if (create.isThisYear) { // 今年
        if (create.isToday) { // 今天
            if (cmps.hour >= 1) { // 时间差距 >= 1小时
                return [NSString stringWithFormat:@"%zd小时后开始", cmps.hour];
                }
            if(cmps.hour<1&&cmps.minute>=1){ // 1小时 > 时间差距 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟后开始", cmps.minute];}
            else{
                return @"直播中";
            }
        }else { // 其他
            if (cmps.day<0) {
                return @"直播中";
            }
            if (cmps.day==0) {
                return @"1天以后开始";
            }
            else
            {
                return [NSString stringWithFormat:@"%ld天以后开始",cmps.day];
            }
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:create];
    }
}

- (NSInteger)compareTimeWithNow:(NSString*)time
{
    long liveTime = [time longLongValue] /1000;
    
    NSDate *nowDate=[NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[nowDate timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    long now=[timeString longLongValue] /1000;
    
    int days=(int)((liveTime-now)/3600/24+1);
    
    return days;
}

@end
