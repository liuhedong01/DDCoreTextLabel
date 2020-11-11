//
//  DDFriendCircleUtils.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DDFriendCircleUtils : NSObject

/** 电话号码正则, 7到23 位数字 */
+ (NSRegularExpression *)regexPhoneNumber;

/** 链接正则 */
+ (NSRegularExpression *)regexLinkUrl;

/** 正则 手机号和链接，添加 高亮状态 ,（白底时高亮） */
+ (void)checkPhoneAndLinkAddHighlight:(NSMutableAttributedString *)attributeStr
                                range:(NSRange)range
             highlightBackgroundColor:(UIColor *)highlightBackgroundColor;


+ (CGSize)returnSizeWithText:(NSString*)text
                        font:(UIFont *)font
                      height:(CGFloat)height;

@end

