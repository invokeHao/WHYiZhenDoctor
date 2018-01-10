//
//  liveCellFrameModel.m
//  Yizhenapp
//
//  Created by augbase on 16/9/6.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "liveCellFrameModel.h"
#import "NSString+extention.h"

#define timeH 40
#define padding 10
#define iconW 32
#define iconH 32
#define textW ViewWidth*0.64

@implementation liveCellFrameModel

- (void)setMessageModel:(LiveModel *)messageModel
{
    _messageModel = messageModel;
    CGRect frame = [UIScreen mainScreen].bounds;
    
    //1.时间的Frame
    if (messageModel.createTime) {
        CGFloat timeFrameX = 0;
        CGFloat timeFrameY = 5;
        CGFloat timeFrameW = frame.size.width;
        CGFloat timeFrameH = 14;
        _timeFrame = CGRectMake(timeFrameX, timeFrameY, timeFrameW, timeFrameH);
    }
    //2.name的frame
    CGFloat nameFrameX=2 * padding +iconW;
    CGFloat nameFrameY=CGRectGetMaxY(CGRectZero)+10;
    if (messageModel.showTime) {
        nameFrameY=CGRectGetMaxY(_timeFrame)+10;
    }
    else
    {
        nameFrameY=CGRectGetMaxY(CGRectZero)+10;
    }

    CGSize textMaxSize = CGSizeMake(textW, MAXFLOAT);
    CGSize nameSize=[messageModel.creatorName sizeWithFont:YiZhenFont13 maxSize:textMaxSize];
    CGSize nameRealSize=CGSizeMake(nameSize.width+4, nameSize.height+3);
    _nameFrame=(CGRect){nameFrameX,nameFrameY,nameRealSize};
    
    //3.头像的Frame
    CGFloat iconFrameX=padding;
    CGFloat iconFrameY = CGRectGetMaxY(_nameFrame)+2;
    CGFloat iconFrameW = iconW;
    CGFloat iconFrameH = iconH;
    _iconFrame = CGRectMake(iconFrameX, iconFrameY, iconFrameW, iconFrameH);
    
    //4.内容的Frame
    //文本消息
    if (messageModel.type==0) {
        CGSize textMaxSize = CGSizeMake(textW, MAXFLOAT);
        CGSize textSize = [messageModel.content sizeWithFont:YiZhenFont14 maxSize:textMaxSize];
        CGSize textRealSize = CGSizeMake(textSize.width + textPadding * 2, textSize.height + textPadding);
        CGFloat textFrameY = iconFrameY;
        CGFloat textFrameX= 2 * padding+iconFrameW;
        _textFrame = (CGRect){textFrameX, textFrameY, textRealSize};
    }
    else if (messageModel.type==1)//语音消息
    {
        CGFloat textFrameY = iconFrameY;
        CGFloat textFrameX = iconFrameW+padding * 2;
        CGSize textRealSize = CGSizeMake(200, 40);
        if (messageModel.replyCreatorId>0) {
            CGSize textMaxSize=CGSizeMake(170, MAXFLOAT);
            NSString *replyContent=[NSString stringWithFormat:@"%@：%@",messageModel.replyCreatorName,messageModel.replyContent];
            CGSize textSize=[replyContent sizeWithFont:YiZhenFont14 maxSize:textMaxSize];
            textRealSize=CGSizeMake(200, textSize.height+2*padding+40);
        }
        _textFrame = (CGRect){textFrameX, textFrameY, textRealSize};
    }
    else if(messageModel.type==2)//图片消息
    {
        CGSize textRealSize = CGSizeMake(90, 90);
        CGFloat textFrameY = iconFrameY+2;
        CGFloat textFrameX = iconFrameW+padding * 2;
        _textFrame = (CGRect){textFrameX, textFrameY, textRealSize};
    }
    else if(messageModel.type==3)//直播简介
    {
        CGSize textMaxSize = CGSizeMake(ViewWidth-30, MAXFLOAT);
        //标题的size
        CGSize titleSize=[messageModel.title sizeWithFont:YiZhenFont16 maxSize:textMaxSize];
        //内容的size
        CGSize textSize = [messageModel.content sizeWithFont:YiZhenFont13 maxSize:textMaxSize];
        //简介的size
        CGSize liveIntroSize = CGSizeMake(ViewWidth, textSize.height + titleSize.height+5*padding);
        
        CGFloat liveIntroY = 0;
        CGFloat liveIntroX= 0;
        _textFrame = (CGRect){liveIntroX, liveIntroY, liveIntroSize};
    }
    else if (messageModel.type==4)//医生简介
    {
        CGSize textMaxSize=CGSizeMake(ViewWidth-74-15, MAXFLOAT);
        //医生的size
        NSString * doctorStr=[NSString stringWithFormat:@"讲者：%@",messageModel.creatorName];
        CGSize doctorSize=[doctorStr sizeWithFont:YiZhenFont14 maxSize:textMaxSize];
        //医生简介的size
        CGSize doctorIntroSize=[messageModel.content sizeWithFont:YiZhenFont13 maxSize:textMaxSize];
        CGSize realSize=CGSizeMake(ViewWidth, doctorSize.height+doctorIntroSize.height+4*padding);
        CGFloat doctorIntroY = 0;
        CGFloat doctorIntroX= 0;
        _textFrame=(CGRect){doctorIntroX,doctorIntroY,realSize};
    }
}

-(CGFloat)cellHeght
{
    return   MAX(CGRectGetMaxY(_iconFrame), CGRectGetMaxY(_textFrame)+padding);
}


@end
