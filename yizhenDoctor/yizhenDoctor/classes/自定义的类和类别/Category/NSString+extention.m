//
//  NSString+extention.m
//  Yizhenapp
//
//  Created by augbase on 16/5/14.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "NSString+extention.h"

@implementation NSString (extention)
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
