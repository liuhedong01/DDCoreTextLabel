//
//  UIColor+DDTools.h
//  Tools
//
//  Created by 刘和东 on 2017/12/5.
//  Copyright © 2017年 Tools. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef dd_ColorHex
#define dd_ColorHex(_hex_)   [UIColor dd_colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

@interface UIColor (DDTools)

/**  @"0xF0F", @"66ccff", @"#66CCFF88" */
+ (UIColor *)dd_colorWithHexString:(NSString *)hexStr;

/**  @"0xF0F", @"66ccff", @"#66CCFF88" alpha透明度*/
+ (UIColor *)dd_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;


/** 用图片生产UIColor */
+ (UIColor *)dd_colorWithImage:(UIImage *)image;

/** 图片名字生成图片 */
+ (UIColor *)dd_colorWithImageName:(NSString *)imageName;


/** 给当前颜色设置 alpha */
- (UIColor *)dd_colorAlpha:(CGFloat)alpha;



@end
