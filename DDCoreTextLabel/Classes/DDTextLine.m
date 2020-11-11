//
//  DDTextLine.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDTextLine.h"

@interface DDTextLine ()


@property (nonatomic,assign) CTLineRef CTLine; //CoreText中的CTlineRef
@property (nonatomic,assign) NSRange range; //在string中的range

@property (nonatomic,assign) CGRect frame; //加上ascent和descent之后的frame,UIKit坐标系
@property (nonatomic,assign) CGRect viewFrame; //frame基础上加上 ，trailingWhitespaceWidth+lineOrigin.x
@property (nonatomic,assign) CGSize size;  //frame.size
@property (nonatomic,assign) CGFloat width; //frame.size.width
@property (nonatomic,assign) CGFloat height; //frame.size.height
@property (nonatomic,assign) CGFloat top; //frame.origin.y
@property (nonatomic,assign) CGFloat bottom;//frame.origin.y + frame.size.height
@property (nonatomic,assign) CGFloat left;//frame.origin.x
@property (nonatomic,assign) CGFloat right;//frame.origin.x + frame.size.width

@property (nonatomic,assign) CGPoint lineOrigin;//CTLine的原点位置,UIKit坐标系

@property (nonatomic,assign) CGFloat ascent; //line ascent 上部距离
@property (nonatomic,assign) CGFloat descent;//line descent 下部距离
@property (nonatomic,assign) CGFloat leading;// line leading 行距
@property (nonatomic,assign) CGFloat lineWidth;// line width 行宽
@property (nonatomic,assign) CGFloat trailingWhitespaceWidth;//尾部空白的宽度

@property (nonatomic,copy) NSArray<DDTextAttachment *>* attachments;//包含文本附件的数组
@property (nonatomic,copy) NSArray<NSValue *>* attachmentRects;//包含文本附件在View上位置的数组 CGRect(NSValue)

@property (nonatomic,assign) CGFloat firstGlyphPosition;

@end

@implementation DDTextLine

+ (instancetype)textLineWithCTlineRef:(CTLineRef)CTLine lineOrigin:(CGPoint)lineOrigin
{
    if (!CTLine) {
        return nil;
    }
    DDTextLine* line = [[DDTextLine alloc] init];
    line.CTLine = CTLine;
    line.lineOrigin = lineOrigin;
    return line;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:(__nonnull id)self.CTLine forKey:@"CTLine"];
    [aCoder encodeCGPoint:self.lineOrigin forKey:@"lineOrigin"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    CTLineRef CTLine = (__bridge CTLineRef)([aDecoder decodeObjectForKey:@"CTLine"]);
    CGPoint lineOrigin = [aDecoder decodeCGPointForKey:@"lineOrigin"];
    DDTextLine* one = [DDTextLine textLineWithCTlineRef:CTLine lineOrigin:lineOrigin];
    return one;
}

- (id)init {
    self = [super init];
    if (self) {
        self.lineWidth = 0.0f;
        self.ascent = 0.0f;
        self.descent = 0.0f;
        self.leading = 0.0f;
        self.firstGlyphPosition = 0.0f;
        self.trailingWhitespaceWidth = 0.0f;
        self.range = NSMakeRange(0, 0);
    }
    return self;
}

- (void)dealloc {
    if (self.CTLine) {
        CFRelease(self.CTLine);
    }
}

- (void)setCTLine:(CTLineRef)CTLine
{
    if (_CTLine != CTLine) {
        if (CTLine) CFRetain(CTLine);
        if (_CTLine) CFRelease(_CTLine);
        _CTLine = CTLine;
        if (_CTLine) {
            _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_CTLine);
            _range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPosition = pos.x;
            } else {
                _firstGlyphPosition = 0;
            }
            
            _trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
            
        } else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPosition = _trailingWhitespaceWidth = 0;
            _range = NSMakeRange(0, 0);
        }
        [self _reloadBounds];
    }
}

- (void)setLineOrigin:(CGPoint)lineOrigin {
    _lineOrigin = lineOrigin;
    [self _reloadBounds];
}

- (void)_reloadBounds
{
    self.frame = CGRectMake(self.lineOrigin.x + self.firstGlyphPosition,
                            self.lineOrigin.y - self.ascent,
                            self.lineWidth,
                            self.ascent + self.descent);
    
    self.viewFrame =  CGRectMake(self.lineOrigin.x,
                                 self.lineOrigin.y - self.ascent,
                                 self.lineWidth + self.trailingWhitespaceWidth,
                                 self.ascent + self.descent);
    
    _attachments = nil;
    _attachmentRects = nil;
    if (!_CTLine) return;
    //  获取 CTRunRef 数组runs
    CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
    //CTRunRef 个数 runCount
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) return;
    
    NSMutableArray *attachments = [NSMutableArray new];
    NSMutableArray *attachmentRanges = [NSMutableArray new];
    NSMutableArray *attachmentRects = [NSMutableArray new];
    NSMutableArray* glyphsArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        
        for (NSUInteger i = 0; i < runCount; i++) {
            //获取第 i 个 CTRunRef
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            // 获取 字形 glyph 个数
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if(glyphCount == 0) continue;
            
            
            //有
            CGPoint runPosition = CGPointZero;
            CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
            CGFloat ascent, descent, leading, runWidth;
            CGRect runTypoBounds;
            
            runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            runPosition.x += self.lineOrigin.x;
            runPosition.y = self.lineOrigin.y - runPosition.y;
            runTypoBounds = CGRectMake(runPosition.x, runPosition.y - ascent, runWidth, ascent + descent);
            
            NSRange runRange = NSMakeRange(CTRunGetStringRange(run).location, CTRunGetStringRange(run).length);
            
            {
                CGGlyph glyphs[glyphCount];
                CTRunGetGlyphs(run, CFRangeMake(0, 0),glyphs);
                
                CGPoint glyphPositions[glyphCount];
                CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
                
                CGSize glyphAdvances[glyphCount];
                CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances);
                
                for (NSInteger i = 0; i < glyphCount; i ++) {
                    
                    DDTextGlyph* glyph = [[DDTextGlyph alloc] init];
                    glyph.glyph = glyphs[i];
                    glyph.position = glyphPositions[i];
                    glyph.leading = leading;
                    glyph.ascent = ascent;
                    glyph.descent = descent;
                    glyph.width = glyphAdvances[i].width;
                    glyph.height = glyphAdvances[i].height;
                    [glyphsArray addObject:glyph];
                    
                }
            }
            
            
            //获取属性对象
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            //获取 DDTextAttachment 对象
            DDTextAttachment *attachment = attrs[DDTextAttachmentAttributeName];
            if (attachment) {
                [attachments addObject:attachment];
                [attachmentRanges addObject:[NSValue valueWithRange:runRange]];
                [attachmentRects addObject:[NSValue valueWithCGRect:runTypoBounds]];
                
            }
            
        }
        
    }
    _attachments = attachments.count ? attachments : nil;
    _attachmentRects = attachmentRects.count ? attachmentRects : nil;
    self.glyphs = [glyphsArray copy];
}

#pragma mark - Getter

- (CGSize)size {
    return self.frame.size;
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

- (CGFloat)top {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)left {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)right {
    return CGRectGetMaxX(self.frame);
}

@end
