//
//  DDTextLine.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "DDTextAttribute.h"
#import "DDTextGlyph.h"


@interface DDTextLine : NSObject

@property (nonatomic) NSUInteger index;//CTLine在CTFrameGetLines数组中的index
@property (nonatomic) NSUInteger row;//行数

@property (nonatomic,assign,readonly) CTLineRef CTLine; //CoreText中的CTlineRef
@property (nonatomic,assign,readonly) NSRange range; //在string中的range

@property (nonatomic,assign,readonly) CGRect frame; //加上ascent和descent之后的frame,UIKit坐标系
@property (nonatomic,assign,readonly) CGRect viewFrame; //frame基础上加上 ，trailingWhitespaceWidth+lineOrigin.x
@property (nonatomic,assign,readonly) CGSize size;  //frame.size
@property (nonatomic,assign,readonly) CGFloat width; //frame.size.width
@property (nonatomic,assign,readonly) CGFloat height; //frame.size.height
@property (nonatomic,assign,readonly) CGFloat top; //frame.origin.y
@property (nonatomic,assign,readonly) CGFloat bottom;//frame.origin.y + frame.size.height
@property (nonatomic,assign,readonly) CGFloat left;//frame.origin.x
@property (nonatomic,assign,readonly) CGFloat right;//frame.origin.x + frame.size.width

@property (nonatomic,assign,readonly) CGPoint lineOrigin;//CTLine的原点位置,UIKit坐标系

@property (nonatomic,assign,readonly) CGFloat ascent; //line ascent 上部距离
@property (nonatomic,assign,readonly) CGFloat descent;//line descent 下部距离
@property (nonatomic,assign,readonly) CGFloat leading;// line leading 行距
@property (nonatomic,assign,readonly) CGFloat lineWidth;// line width 行宽
@property (nonatomic,assign,readonly) CGFloat trailingWhitespaceWidth;//尾部空白的宽度

@property (nonatomic,copy) NSArray<DDTextGlyph *>* glyphs;
@property (nonatomic,copy,readonly) NSArray<DDTextAttachment *>* attachments;//包含文本附件的数组
@property (nonatomic,copy,readonly) NSArray<NSValue *>* attachmentRects;//包含文本附件在View上位置的数组 CGRect(NSValue)


/**
 *  构造方法
 *  @param CTLine     CoreText中的CTLineRef对象
 *  @param lineOrigin CTLineRef对象的起始位置CGPoint对象
 *  @return 一个DDTextLine对象
 */
+ (instancetype)textLineWithCTlineRef:(CTLineRef)CTLine lineOrigin:(CGPoint)lineOrigin;


@end
