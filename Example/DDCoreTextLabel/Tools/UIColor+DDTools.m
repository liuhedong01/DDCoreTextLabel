//
//  UIColor+DDTools.m
//  Tools
//
//  Created by 刘和东 on 2017/12/5.
//  Copyright © 2017年 Tools. All rights reserved.
//

#import "UIColor+DDTools.h"

@implementation UIColor (DDTools)


static inline NSUInteger dd_hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL dd_hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = dd_hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = dd_hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = dd_hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = dd_hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = dd_hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = dd_hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = dd_hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = dd_hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

/**  @"0xF0F", @"66ccff", @"#66CCFF88" */
+ (UIColor *)dd_colorWithHexString:(NSString *)hexStr
{
    CGFloat r, g, b, a;
    if (dd_hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

/**  @"0xF0F", @"66ccff", @"#66CCFF88" alpha透明度*/
+ (UIColor *)dd_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    CGFloat r, g, b, a;
    if (dd_hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    }
    return nil;
}

/** 用图片生产UIColor */
+ (UIColor *)dd_colorWithImage:(UIImage *)image
{
    if (image && [image isKindOfClass:UIImage.class]) {
        return [UIColor colorWithPatternImage:image];
    }
    return nil;
}

/** 图片名字生成图片 */
+ (UIColor *)dd_colorWithImageName:(NSString *)imageName
{
    if (imageName && [imageName isKindOfClass:NSString.class]) {
        return [self dd_colorWithImage:[UIImage imageNamed:imageName]];
    }
    return nil;
}

/** 给当前颜色设置 alpha */
- (UIColor *)dd_colorAlpha:(CGFloat)alpha
{
    return [self colorWithAlphaComponent:alpha];
}

@end
