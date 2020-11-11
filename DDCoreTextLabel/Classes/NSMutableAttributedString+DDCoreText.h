//
//  NSMutableAttributedString+DDCoreText.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/18.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DDTextAttribute.h"
#import "DDTextContainer.h"

@interface NSMutableAttributedString (DDCoreText)

/**
 范围
 
 @return NSMakeRange(0, self.length)
 */
- (NSRange)dd_rangeOfAll;

/** 获取index 位置所有属性 */
- (NSDictionary *)dd_attributesAtIndex:(NSUInteger)index;


/**
  获取属性对象

 @param attributeName 属性名字
 @param index 当前位置
 @return 获取到的属性对象
 */
- (id)dd_attribute:(NSString *)attributeName atIndex:(NSUInteger)index;

/**
 添加附件
 
 @param content         (UIImage/UIView/CALayer)
 @param contentMode     UIViewContentMode
 @param width           宽度
 @param ascent          上行高
 @param descent         下行高
 @return 一个带有附件的富文本
 */
+ (NSMutableAttributedString *)dd_attachmentStringWithContent:(id)content
                                                  contentMode:(UIViewContentMode)contentMode
                                                        width:(CGFloat)width
                                                       ascent:(CGFloat)ascent
                                                      descent:(CGFloat)descent;


/**
 添加附件
 
 @param content             (UIImage/UIView/CALayer)
 @param contentMode         UIViewContentMode
 @param attachmentSize      content 大小
 @param font                content 根据 font 对齐 content
 @param alignment           content 垂直对齐模式
 @return 一个带有附件的富文本
 */
+ (NSMutableAttributedString *)dd_attachmentStringWithContent:(id)content
                                               contentMode:(UIViewContentMode)contentMode
                                            attachmentSize:(CGSize)attachmentSize
                                               alignToFont:(UIFont *)font
                                                 alignment:(DDTextVerticalAlignment)alignment;

/**
 添加高亮
 
 @param textHighlight DDTextHighlight
 @param range 范围
 */
- (void)dd_setTextHighlight:(DDTextHighlight *)textHighlight range:(NSRange)range;


/**
 添加 高亮
 
 @param content                        链接内容
 @param range                          范围
 @param normalColor                    正常颜色
 @param highlightBackgroundColor      点击时背景颜色
 @param selectedRangeType              高亮状态的被点击时 文字 选中时的 位置 与高宽类型
 @param gestureType                    高亮的点击事件
 @param userInfo                       用户自定义信息
 */
- (DDTextHighlight *)dd_addHighlightWithContent:(id)content
                          range:(NSRange)range
                    normalColor:(UIColor *)normalColor
       highlightBackgroundColor:(UIColor *)highlightBackgroundColor
              selectedRangeType:(DDTextHighLightTextSelectedRangeType)selectedRangeType
                    gestureType:(DDTextHighLightGestureType)gestureType
                       userInfo:(NSDictionary *)userInfo;

/**
 添加 高亮
 
 @param range                       范围
 @param normalColor                 正常颜色
 @param highlightBackgroundColor    点击时背景颜色
 @param selectedRangeType           高亮状态的被点击时 文字 选中时的 位置 与高宽类型
 @param gestureType                 高亮的点击事件
 @param userInfo                    用户自定义信息
 */
- (DDTextHighlight *)dd_addHighlightWithRange:(NSRange)range
                     normalColor:(UIColor *)normalColor
        highlightBackgroundColor:(UIColor *)highlightBackgroundColor
               selectedRangeType:(DDTextHighLightTextSelectedRangeType)selectedRangeType
                     gestureType:(DDTextHighLightGestureType)gestureType
                        userInfo:(NSDictionary *)userInfo;


/**
 *  添加一个点击链接事件,默认 点击事件 为 单点和长按，选中范围为普通
 DDTextHighLightGestureType           默认  DDTextHighLightGestureTypeSingleAndLongPressClick
 DDTextHighLightTextSelectedRangeType 默认  DDTextHighLightTextSelectedRangeNormal
 *
 *  @param content                         链接包含的数据
 *  @param range                           范围
 *  @param normalColor                     正常颜色
 *  @param highlightBackgroundColor       点击时的高亮颜色
 */
- (DDTextHighlight *)dd_addHighlightWithContent:(id)content
                          range:(NSRange)range
                    normalColor:(UIColor *)normalColor
       highlightBackgroundColor:(UIColor *)highlightBackgroundColor;


/**
 设置文本颜色，范围NSMakeRange(0, self.length)
 
 @param textColor 文本颜色
 */
- (void)dd_setTextColor:(UIColor *)textColor;

/**
 设置文本颜色
 
 @param textColor 文本颜色
 @param range 范围
 */
- (void)dd_setTextColor:(UIColor *)textColor range:(NSRange)range;

/**
 *  设置文本字体，范围NSMakeRange(0, self.length)
 *
 *  @param font  字体
 */
- (void)dd_setFont:(UIFont *)font;

/**
 *  设置文本字体
 *
 *  @param font  字体
 *  @param range 范围
 */
- (void)dd_setFont:(UIFont *)font range:(NSRange)range;

/**
 *  设置字间距，范围NSMakeRange(0, self.length)
 *
 *  @param characterSpacing 字间距
 */
- (void)dd_setCharacterSpacing:(unichar)characterSpacing;

/**
 *  设置字间距
 *
 *  @param characterSpacing 字间距
 *  @param range            范围
 */
- (void)dd_setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range;

/**
 *  设置下划线样式和颜色，范围NSMakeRange(0, self.length)
 *
 *  @param underlineStyle 下划线样式
 *  @param underlineColor 下划线颜色
 */
- (void)dd_setUnderlineStyle:(NSUnderlineStyle)underlineStyle
              underlineColor:(UIColor *)underlineColor;

/**
 *  设置下划线样式和颜色
 *
 *  @param underlineStyle 下划线样式
 *  @param underlineColor 下划线颜色
 *  @param range          范围
 */
- (void)dd_setUnderlineStyle:(NSUnderlineStyle)underlineStyle
              underlineColor:(UIColor *)underlineColor
                       range:(NSRange)range;

#pragma mark - ParagraphStyle

/**
 *  设置行间距
 *
 *  @param lineSpacing 行间距，范围NSMakeRange(0, self.length)
 */
- (void)dd_setLineSpacing:(CGFloat)lineSpacing;

/**
 *  设置行间距
 *
 *  @param lineSpacing 行间距
 *  @param range       范围
 */
- (void)dd_setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;

/**
 *  设置文本水平对齐方式，范围NSMakeRange(0, self.length)
 *
 *  @param textAlignment 文本对齐方式
 */
- (void)dd_setTextAlignment:(NSTextAlignment)textAlignment;

/**
 *  设置文本水平对齐方式
 *
 *  @param textAlignment 文本对齐方式
 *  @param range         范围
 */
- (void)dd_setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range;

/**
 *  设置文本换行方式，范围NSMakeRange(0, self.length)
 *
 *  @param lineBreakMode 换行方式
 */
- (void)dd_setLineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 *  设置文本换行方式
 *
 *  @param lineBreakMode 换行方式
 *  @param range         范围
 */
- (void)dd_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;

@end
