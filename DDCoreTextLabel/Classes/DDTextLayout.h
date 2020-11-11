//
//  DDTextLayout.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/17.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDTextContainer.h"
#import <CoreText/CoreText.h>
#import "DDTextAttribute.h"
#import "DDTextLine.h"


@interface DDTextLayout : NSObject <NSCoding>

/** 文本容器 */
@property (nonatomic, strong, readonly) DDTextContainer * container;
/** 文本 */
@property (nonatomic, strong, readonly) NSAttributedString* text;//文本
/** 可见字符串的 的 NSRange */
@property (nonatomic, readonly) NSRange range;
/** 文本边框 */
@property (nonatomic, assign, readonly) CGRect textBoundingRect;
/** 文本边框的大小 */
@property (nonatomic, assign, readonly) CGSize textBoundingSize;
/** 大小 */
@property (nonatomic, assign, readonly) CGRect boundingRect;
/** 大小 */
@property (nonatomic, assign, readonly) CGSize boundingSize;
/** 包含DDTextLine的数组 */
@property (nonatomic, strong, readonly) NSArray<DDTextLine *>* linesArray;
/** 包含文本附件的数组 */
@property (nonatomic, strong, readonly) NSArray<DDTextAttachment *> *attachments;
/** 文本附件 CGRect信息的数组 */
@property (nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRects;
/** 一个包含文本链接的信息的数组 */
@property (nonatomic, strong, readonly) NSArray<DDTextHighlight *>* textHighlights;
/** 是否折叠 */
@property (nonatomic, assign, readonly) BOOL needTruncation;

/** 原点，默认 0，0 */
@property (nonatomic, assign, readonly) CGPoint origin;

@property (nonatomic, assign, readonly) CGPathRef path;

/**
 *  构造方法
 *
 *  @param container DDTextContainer
 *  @param text      NSAttributedString
 *
 *  @return DDTextLayout实例
 */
+ (DDTextLayout *)layoutWithContainer:(DDTextContainer *)container
                                 text:(NSMutableAttributedString *)text;

/**
 *  构造方法
 *
 *  @param container DDTextContainer
 *  @param text      NSAttributedString
 *  @param origin    原点
 *
 *  @return DDTextLayout实例
 */
+ (DDTextLayout *)layoutWithContainer:(DDTextContainer *)container
                                 text:(NSMutableAttributedString *)text
                               origin:(CGPoint)origin;

/**
 *  构造方法
 *
 *  @param size      CGSize
 *  @param text      NSAttributedString
 *
 *  @return DDTextLayout实例
 */
+ (DDTextLayout *)layoutWithContainerSize:(CGSize)size
                                     text:(NSMutableAttributedString *)text;

/**
 *  绘制文本
 *
 *  @param context        CGContextRef对象，绘制上下文
 *  @param size           绘制范围的大小
 *  @param point          在DDCoreTextLabel中的绘制起始点CGPoint
 *  @param containerView  绘制文本的容器UIView对象
 *  @param containerLayer 绘制文本的容器UIView对象的CALayer对象(.layer)
 *  @param cancel         是否取消绘制
 */
- (void)drawIncontext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
        containerView:(UIView *)containerView
       containerLayer:(CALayer *)containerLayer
               cancel:(BOOL (^)(void))cancel;

/**
 *  将文本附件从UIView或CALayer上移除，在即将开始绘制时调用
 */
- (void)removeAttachmentFromSuperViewOrLayer;


@end
