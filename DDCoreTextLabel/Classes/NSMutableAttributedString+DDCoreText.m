//
//  NSMutableAttributedString+DDCoreText.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/18.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "NSMutableAttributedString+DDCoreText.h"
#import "DDTextRunDelegate.h"

@implementation NSMutableAttributedString (DDCoreText)

- (NSRange)dd_rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (NSDictionary *)dd_attributesAtIndex:(NSUInteger)index {
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attributesAtIndex:index effectiveRange:NULL];
}

- (id)dd_attribute:(NSString *)attributeName atIndex:(NSUInteger)index
{
    if (!attributeName) return nil;
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attribute:attributeName atIndex:index effectiveRange:NULL];
}


/**
 添加附件,内部类
 
 @param textAttachment DDTextAttachment 对象
 @param range 范围
 */
- (void)__dd_setTextAttachment:(DDTextAttachment *)textAttachment range:(NSRange)range
{
    [self _dd_setAttribute:DDTextAttachmentAttributeName value:textAttachment range:range];
}

+ (NSMutableAttributedString *)dd_attachmentStringWithContent:(id)content
                                               contentMode:(UIViewContentMode)contentMode
                                                     width:(CGFloat)width
                                                    ascent:(CGFloat)ascent
                                                   descent:(CGFloat)descent
{
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:@"\uFFFC"];
    
    DDTextAttachment *attach = [DDTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr __dd_setTextAttachment:attach range:NSMakeRange(0, atr.length)];
    
    DDTextRunDelegate *delegate = [DDTextRunDelegate new];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    
    NSRange range = NSMakeRange(0, atr.length);
    
    [atr _dd_setAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegateRef range:range];
    
    if (delegate) CFRelease(delegateRef);
    return atr;
}

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
                                                 alignment:(DDTextVerticalAlignment)alignment
{
    CGFloat ascent = 0;
    CGFloat descent = 0;
    switch (alignment) {
        case DDTextVerticalAlignmentTop:
        {
            ascent = font.ascender;
            descent = attachmentSize.height - ascent;
            if (descent < 0) {
                descent = 0;
                ascent = attachmentSize.height;
            }
        }
            break;
        case DDTextVerticalAlignmentCenter:
        {
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            ascent = attachmentSize.height * 0.5 + yOffset;
            descent = attachmentSize.height - ascent;
            if (descent < 0) {
                descent = 0;
                ascent = attachmentSize.height;
            }
        }
            break;
        case DDTextVerticalAlignmentBottom:
        {
            ascent = attachmentSize.height + font.descender;
            descent = -font.descender;
            if (ascent < 0) {
                ascent = 0;
                descent = attachmentSize.height;
            }
        }
            break;
        default:
        {
            ascent = attachmentSize.height;
            descent = 0;
        }
            break;
    }
    NSMutableAttributedString * attributedString = [self dd_attachmentStringWithContent:content contentMode:contentMode width:attachmentSize.width ascent:ascent descent:descent];
    return attributedString;
}


/**
 添加高亮
 
 @param textHighlight DDTextHighlight
 @param range 范围
 */
- (void)dd_setTextHighlight:(DDTextHighlight *)textHighlight range:(NSRange)range
{
    if (textHighlight.range.length == 0) {
        textHighlight.range = range;
    }
    [self _dd_setAttribute:DDTextHighlightAttributeName value:textHighlight range:range];
    if (textHighlight.normalColor) {
        [self dd_setTextColor:textHighlight.normalColor range:range];
    }
}

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
                          userInfo:(NSDictionary *)userInfo
{
    DDTextHighlight* highlight = [[DDTextHighlight alloc] init];
    highlight.content = content;
    highlight.range = range;
    highlight.normalColor = normalColor;
    highlight.highlightBackgroundColor = highlightBackgroundColor;
    highlight.selectedRangeType = selectedRangeType;
    highlight.gestureType = gestureType;
    highlight.userInfo = userInfo;
    [self dd_setTextHighlight:highlight range:range];
    return highlight;
}

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
                        userInfo:(NSDictionary *)userInfo
{
    return [self dd_addHighlightWithContent:nil range:range normalColor:normalColor highlightBackgroundColor:highlightBackgroundColor selectedRangeType:selectedRangeType gestureType:gestureType userInfo:userInfo];
}


/**
 *  添加一个点击链接事件,默认 点击事件 为 单点和长按，选中范围为普通
 DDTextHighLightGestureType           默认  DDTextHighLightGestureTypeSingleAndLongPressClick
 DDTextHighLightTextSelectedRangeType 默认  DDTextHighLightTextSelectedRangeNormal
 *
 *  @param content                         链接包含的数据
 *  @param range                           范围
 *  @param normalColor                     正常颜色
 *  @param highlightBackgroundColor        点击时的高亮颜色
 */
- (DDTextHighlight *)dd_addHighlightWithContent:(id)content
                             range:(NSRange)range
                       normalColor:(UIColor *)normalColor
          highlightBackgroundColor:(UIColor *)highlightBackgroundColor
{
    return [self dd_addHighlightWithContent:content range:range normalColor:normalColor highlightBackgroundColor:highlightBackgroundColor selectedRangeType:DDTextHighLightTextSelectedRangeNormal gestureType:DDTextHighLightGestureTypeSingleAndLongPressClick userInfo:nil];
}

- (void)dd_setTextColor:(UIColor *)textColor range:(NSRange)range
{
    [self _dd_setAttribute:NSForegroundColorAttributeName value:textColor range:range];
}

- (void)dd_setTextColor:(UIColor *)textColor
{
    [self dd_setTextColor:textColor range:[self dd_rangeOfAll]];
}

- (void)dd_setFont:(UIFont *)font range:(NSRange)range
{
    [self _dd_setAttribute:NSFontAttributeName value:font range:range];
}

- (void)dd_setFont:(UIFont *)font
{
    [self dd_setFont:font range:[self dd_rangeOfAll]];
}

- (void)dd_setCharacterSpacing:(unichar)characterSpacing
{
    [self dd_setCharacterSpacing:characterSpacing range:[self dd_rangeOfAll]];
}

- (void)dd_setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range
{
    CFNumberRef charSpacingNum =  CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&characterSpacing);
    if (charSpacingNum != nil) {
        [self _dd_setAttribute:NSKernAttributeName value:(__bridge id)charSpacingNum range:range];
        CFRelease(charSpacingNum);
    }
}

- (void)dd_setUnderlineStyle:(NSUnderlineStyle)underlineStyle
              underlineColor:(UIColor *)underlineColor
{
    [self dd_setUnderlineStyle:underlineStyle underlineColor:underlineColor range:[self dd_rangeOfAll]];
}

- (void)dd_setUnderlineStyle:(NSUnderlineStyle)underlineStyle
              underlineColor:(UIColor *)underlineColor
                       range:(NSRange)range
{
    [self _dd_setAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    [self _dd_setAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:(underlineStyle)] range:range];
}

- (void)dd_setLineSpacing:(CGFloat)lineSpacing
{
    [self dd_setLineSpacing:lineSpacing range:[self dd_rangeOfAll]];
}

- (void)dd_setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range
{
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle* value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle* style = value.mutableCopy;
                          [style setLineSpacing:lineSpacing];
                          [self _dd_setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineSpacing:lineSpacing];
                          [self _dd_setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)dd_setTextAlignment:(NSTextAlignment)textAlignment
{
    [self dd_setTextAlignment:textAlignment range:[self dd_rangeOfAll]];
}

- (void)dd_setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range
{
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle* value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle* style = value.mutableCopy;
                          [style setAlignment:textAlignment];
                          [self _dd_setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
                          [style setAlignment:textAlignment];
                          [self _dd_setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)dd_setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [self dd_setLineBreakMode:lineBreakMode range:[self dd_rangeOfAll]];
}

- (void)dd_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range
{
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle* value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle* style = value.mutableCopy;
                          [style setLineBreakMode:lineBreakMode];
                          [self _dd_setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineBreakMode:lineBreakMode];
                          [self _dd_setParagraphStyle:style range:subRange];
                      }
                  }];
}

#pragma mark - 私有方法
/** 设置行间距 */
- (void)_dd_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    [self _dd_setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

/** 设置 */
- (void)_dd_setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]){
        return;
    }
    
    if (range.location < 0) {
        //小于 0
        return;
    }
    
    if (range.length == 0) {
        //长度为 0,返回
        return;
    }
    
    if (NSMaxRange(range) > NSMaxRange(self.dd_rangeOfAll)) {
        //超出了范围
        return;
    }
    if (value && ![NSNull isEqual:value]) {
        [self addAttribute:name value:value range:range];
    }else {
        [self removeAttribute:name range:range];
    }
}
/** 删除属性 */
- (void)_dd_removeAttribute:(NSString *)name range:(NSRange)range
{
    if (!name || [NSNull isEqual:name]){
        return;
    }
    [self removeAttribute:name range:range];
}

@end
