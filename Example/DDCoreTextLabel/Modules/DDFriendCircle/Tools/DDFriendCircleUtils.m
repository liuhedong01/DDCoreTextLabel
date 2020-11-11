//
//  DDFriendCircleUtils.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleUtils.h"

@implementation DDFriendCircleUtils

/** 电话号码正则 */
+ (NSRegularExpression *)regexPhoneNumber
{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{3,4}[- ]\\d{7,8})|(\\d{7,500})" options:kNilOptions error:NULL];
    });
    return regex;
}

/** 链接正则 */
+ (NSRegularExpression *)regexLinkUrl
{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:kNilOptions error:NULL];
    });
    return regex;
}

/** 正则 手机号和链接，添加 高亮状态 ,（白底时高亮） */
+ (void)checkPhoneAndLinkAddHighlight:(NSMutableAttributedString *)attributeStr
                                range:(NSRange)range
             highlightBackgroundColor:(UIColor *)highlightBackgroundColor
{
    /** 匹配手机号 */
    NSArray<NSTextCheckingResult *> *phoneNumberResults = [[self regexPhoneNumber] matchesInString:attributeStr.string options:kNilOptions range:range];
    
    for (NSTextCheckingResult *link in phoneNumberResults) {
        NSInteger length = link.range.length;
        if (link.range.location == NSNotFound || length <= 1) continue;
        if (length > DDFriendCircleRegexPhoneNumberMaxLength) {
            continue;
        }
        
        DDTextHighlight * highlight = [[DDTextHighlight alloc] init];
        highlight.normalColor = dd_ColorHex(2782D7);
        highlight.highlightBackgroundColor = highlightBackgroundColor;
        highlight.tag = DD_FriendCircle_TextHighlightPhoneNumberClickedTag;
        highlight.content = [attributeStr attributedSubstringFromRange:link.range].string;
        [attributeStr dd_setTextHighlight:highlight range:link.range];
    }
    
    /** 匹配链接 */
    NSArray<NSTextCheckingResult *> *linkUrlResults = [[self regexLinkUrl] matchesInString:attributeStr.string options:kNilOptions range:range];
    for (NSTextCheckingResult *link in linkUrlResults) {
        if (link.range.location == NSNotFound || link.range.length <= 1) continue;
        DDTextHighlight * highlight = [[DDTextHighlight alloc] init];
        highlight.normalColor = dd_ColorHex(2782D7);
        highlight.highlightBackgroundColor = highlightBackgroundColor;
        highlight.tag = DD_FriendCircle_TextHighlightLinkClickedTag;
        highlight.content = [attributeStr attributedSubstringFromRange:link.range].string;
        [attributeStr dd_setTextHighlight:highlight range:link.range];
    }

}


+ (CGSize)returnSizeWithText:(NSString*)text
                        font:(UIFont *)font
                      height:(CGFloat)height
{
    if (!text || text.length == 0) {
        /// 可能是空
        text = @"";
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:options attributes:dic context:nil].size;
    return size;
}

@end
