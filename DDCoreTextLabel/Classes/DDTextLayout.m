//
//  DDTextLayout.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/17.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDTextLayout.h"
#import "DDCGUtilities.h"

@interface DDTextLayout ()

/** 文本容器 */
@property (nonatomic,strong,readwrite) DDTextContainer * container;
/** 文本 */
@property (nonatomic,strong,readwrite) NSAttributedString* text;//文本
/** text 的 NSRange */
@property (nonatomic, readwrite) NSRange range;
/** 文本边框 */
@property (nonatomic, assign, readwrite) CGRect textBoundingRect;
/** 文本边框的大小 */
@property (nonatomic, assign, readwrite) CGSize textBoundingSize;
/** 大小 */
@property (nonatomic, assign, readwrite) CGRect boundingRect;
/** 大小 */
@property (nonatomic, assign, readwrite) CGSize boundingSize;
/** 包含DDTextLine的数组 */
@property (nonatomic, strong, readwrite) NSArray<DDTextLine *>* linesArray;
/** 包含文本附件的数组 */
@property (nonatomic, strong, readwrite) NSArray<DDTextAttachment *> *attachments;
/** 文本附件 CGRect信息的数组 */
@property (nonatomic, strong, readwrite) NSArray<NSValue *> *attachmentRects;
/** 一个包含文本链接的信息的数组 */
@property (nonatomic, strong, readwrite) NSArray<DDTextHighlight *>* textHighlights;
/** 是否折叠 */
@property (nonatomic, assign, readwrite) BOOL needTruncation;

/** 原点，默认 0，0 */
@property (nonatomic, assign, readwrite) CGPoint origin;

@property (nonatomic, assign, readwrite) CGPathRef path;


//是否需要绘制附件
@property (nonatomic, assign) BOOL needAttachmentDraw;

@end

@implementation DDTextLayout

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.container forKey:@"container"];
    [aCoder encodeObject:self.text forKey:@"text"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    DDTextContainer * container = [aDecoder decodeObjectForKey:@"container"];
    NSMutableAttributedString * text = [aDecoder decodeObjectForKey:@"text"];
    DDTextLayout * layout = [DDTextLayout layoutWithContainer:container
                                                         text:text];
    return layout;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    return self; // readonly object
}

#pragma mark - Init

/**
 *  构造方法
 *
 *  @param size      CGSize
 *  @param text      NSAttributedString
 *
 *  @return DDTextLayout实例
 */
+ (DDTextLayout *)layoutWithContainerSize:(CGSize)size
                                     text:(NSMutableAttributedString *)text
{
    DDTextContainer * container = [DDTextContainer  containerWithSize:size];
    DDTextLayout * layout = [DDTextLayout layoutWithContainer:container text:text];
    return layout;
}

/**
 *  构造方法
 *
 *  @param container DDTextContainer
 *  @param text      NSAttributedString
 *
 *  @return DDTextLayout实例
 */
+ (DDTextLayout *)layoutWithContainer:(DDTextContainer *)container
                                 text:(NSMutableAttributedString *)text
{
    return [self layoutWithContainer:container text:text origin:CGPointMake(0, 0)];
}

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
                               origin:(CGPoint)origin
{
    if (!text || !container || text.length == 0) {
        return nil;
    }
    
    DDTextLayout *layout = NULL;
    NSRange range;
    CTFramesetterRef frameSetter = NULL;//设置
    CTFrameRef ctFrame = NULL;
    CGPathRef cgPath = nil;//绘制路径
    CFArrayRef ctLines = nil;// CTLineRef 数组
    CGPoint *lineOrigins = NULL;//基线原点 数组
    CGRect containerBoudingBox = CGRectZero;//内容 位置大小，切掉边距之后的
    NSUInteger lineCount = 0;
    NSMutableArray *lines = nil;// CTLineRef 数组
    NSMutableArray* textHighlights = nil;//保存高亮状态的数组
    NSMutableArray *attachments = nil;//附件
    NSMutableArray *attachmentRects = nil;//附件的位置坐标信息
    NSUInteger maxNumberOfLines = 0;//最大行数
    BOOL needTruncation = NO;//是否需要折叠
    
    @autoreleasepool {
        
        
        //复制一次，以免释放
        text = text.mutableCopy;
        container = container.copy;
        if (!text || !container) return nil;
        //计算整个富文本的 range
        
        maxNumberOfLines = container.maxNumberOfLines;
        
        //外面传过来的大小, 切掉边距之后的
        CGPathRef containerPath = container.path.CGPath;
        containerBoudingBox = CGPathGetPathBoundingBox(containerPath);
        
        range = NSMakeRange(0, text.length);
        //计算文字高度   、 返回多少行  和  范围
        CFRange cfRange = CFRangeMake(0, 0);
        int numberOfLines ;
        CGFloat height = dd_getStringHeightAndNumberOfLinesAndRange(text, containerBoudingBox.size.width, maxNumberOfLines, &numberOfLines,&cfRange);
        //不相等，说明需要
        if (range.length != cfRange.length) {
            needTruncation = YES;
        }
        
        range = NSMakeRange(0, cfRange.location+cfRange.length);
        
        
        //实际大小
        CGSize pathSize = CGSizeMake(containerBoudingBox.size.width, height);
        
        CGRect pathRect = {containerBoudingBox.origin,pathSize};
        
        pathRect.size.height = 1000000;
        cgPath = CGPathCreateWithRect(pathRect, NULL);
        if (!cgPath) goto fail;
        
        frameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
        if (!frameSetter) goto fail;
        ctFrame = CTFramesetterCreateFrame(frameSetter,
                                           cfRange,
                                           cgPath,
                                           NULL);
        if (!ctFrame) goto fail;
        
        NSInteger rowIndex = -1;
        NSUInteger rowCount = 0;
        CGRect lastRect = CGRectMake(0.0f, - CGFLOAT_MAX, 0.0f, 0.0f);
        CGPoint lastPosition = CGPointMake(0.0f, - CGFLOAT_MAX);
        lines = [[NSMutableArray alloc] init];
        ctLines = CTFrameGetLines(ctFrame);
        lineCount = CFArrayGetCount(ctLines);
        if (lineCount > 0) {
            lineOrigins = malloc(lineCount * sizeof(CGPoint));
            CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
        }
        CGRect textBoundingRect = CGRectZero;
        NSUInteger lineCurrentIndex = 0;
        
        //保存高亮状态的数组初始化
        textHighlights = [[NSMutableArray alloc] init];
        
        for (NSUInteger i = 0; i < lineCount; i++) {
            CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
            CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
            CFIndex runCount = CFArrayGetCount(ctRuns);
            if (!ctRuns || runCount == 0){
                continue;
            }
            if (needTruncation && i == numberOfLines-1 && container.truncationType != DDTextTruncationTypeNone) {
                CTLineRef lastCTLine = [self __creatTruncationLineLastCTLine:ctLine  attributedString:text rect:pathRect container:container];
                ctLine = lastCTLine;
            }
            for (NSUInteger i = 0; i < runCount; i ++) {
                CTRunRef run = CFArrayGetValueAtIndex(ctRuns, i);
                CFIndex glyphCount = CTRunGetGlyphCount(run);
                if (glyphCount == 0) {
                    continue;
                }
                //熟悉字符串就算
                NSDictionary* attributes = (id)CTRunGetAttributes(run);
                {
                    //高亮状态
                    DDTextHighlight* highlight = [attributes objectForKey:DDTextHighlightAttributeName];
                    if (highlight) {
                        //判断高亮数组里面是否已经存在了
                        bool isContain = NO;
                        for (DDTextHighlight* one in textHighlights) {
                            if ([one isEqual:highlight]) {
                                isContain = YES;
                            }
                        }
                        if (!isContain) {//不存在，计算坐标
                            if (needTruncation && container.truncationType != DDTextTruncationTypeNone && i == numberOfLines-1) {
                                
                            }
                            
                            if (highlight.selectedRangeType != DDTextHighLightTextSelectedRangeWholeView) {
                                //不等于 整个view被选中 就开始 计算
                                NSArray* highlightPositions = [self _searchTextFrameWithCtFrame:ctFrame
                                                                                      highlight:highlight
                                                                                       pathRect:pathRect];
                                highlight.positions = highlightPositions;
                            }
                            //添加 highlight 到 高亮数组
                            [textHighlights addObject:highlight];
                        }
                    }//是否包含高亮
                }
            }
            
            CGPoint ctLineOrigin = lineOrigins[i];
            CGPoint position;
            position.x = pathRect.origin.x + ctLineOrigin.x;
            position.y = pathRect.size.height + pathRect.origin.y - ctLineOrigin.y;
            
            DDTextLine* line = [DDTextLine textLineWithCTlineRef:ctLine lineOrigin:position];
            CGRect rect = line.frame;
            BOOL newRow = YES;
            if (position.x != lastPosition.x) {
                if (rect.size.height > lastRect.size.height) {
                    if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) {
                        newRow = NO;
                    }
                } else {
                    if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) {
                        newRow = NO;
                    }
                }
            }
            if (newRow){
                rowIndex ++;
            }
            lastRect = rect;
            lastPosition = position;
            line.index = lineCurrentIndex;
            line.row = rowIndex;
            [lines addObject:line];
            rowCount = rowIndex + 1;
            lineCurrentIndex ++;
            if (i == 0){
                textBoundingRect = rect;
            } else {
                textBoundingRect = CGRectUnion(textBoundingRect,rect);
            }
            
        }
        
        textBoundingRect.size.height = height;
        
        //统计附件的信息
        attachments = [[NSMutableArray alloc] init];
        attachmentRects = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < lines.count; i ++) {
            DDTextLine* line = lines[i];
            if (line.attachments.count > 0) {
                [attachments addObjectsFromArray:line.attachments];
                [attachmentRects addObjectsFromArray:line.attachmentRects];
            }
        }
        
        CGRect newPathRect = CGRectMake(pathRect.origin.x - container.edgeInsets.left + origin.x,
                                        pathRect.origin.y - container.edgeInsets.top + origin.y,
                                        pathRect.size.width + container.edgeInsets.left + container.edgeInsets.right,
                                        textBoundingRect.size.height + container.edgeInsets.top + container.edgeInsets.bottom);
        
        CGRect newTextBoundingRect = CGRectMake(pathRect.origin.x - container.edgeInsets.left + origin.x,
                                                pathRect.origin.y - container.edgeInsets.top + origin.y,
                                                textBoundingRect.size.width + container.edgeInsets.left + container.edgeInsets.right,
                                                textBoundingRect.size.height + container.edgeInsets.top + container.edgeInsets.bottom);
        
        
        for (DDTextHighlight* highlight in textHighlights) {
            if (highlight.selectedRangeType == DDTextHighLightTextSelectedRangeViewXAndWidth) {
                NSMutableArray * positions = [NSMutableArray array];
                for (NSValue* rectValue in highlight.positions) {
                    CGRect rect = [rectValue CGRectValue];
                    CGRect newRect = [rectValue CGRectValue];
                    if (rect.origin.x == pathRect.origin.x) {
                        newRect.origin.x = newPathRect.origin.x;
                    }
                    if (rect.origin.x + rect.size.width == pathRect.origin.x + pathRect.size.width) {
                        newRect.size.width = newPathRect.size.width;
                    } else {
                        newRect.size.width = rect.origin.x + rect.size.width;
                    }
                    newRect.origin.x += origin.x;
                    newRect.origin.y += origin.y;
                    [positions addObject:[NSValue valueWithCGRect:newRect]];
                }
                highlight.positions = positions;
            } else {
                NSMutableArray * positions = [NSMutableArray array];
                for (NSValue* rectValue in highlight.positions) {
                    CGRect newRect = [rectValue CGRectValue];
                    newRect.origin.x += origin.x;
                    newRect.origin.y += origin.y;
                    [positions addObject:[NSValue valueWithCGRect:newRect]];
                }
                highlight.positions = positions;
            }
        }
        
        layout = [[DDTextLayout alloc] init];
        layout.container = container;
        layout.text = text;
        layout.path = CTFrameGetPath(ctFrame);
        layout.textBoundingRect = newTextBoundingRect;
        layout.textBoundingSize = newTextBoundingRect.size;
        layout.boundingRect = newPathRect;
        layout.boundingSize = newPathRect.size;
        layout.range = range;
        layout.linesArray = lines;
        layout.attachments = attachments;
        layout.attachmentRects = attachmentRects;
        layout.textHighlights = textHighlights;
        layout.needTruncation = needTruncation;
        
        layout.origin = origin;
        
        if (layout.attachments.count > 0) layout.needAttachmentDraw = YES;
        if (lineOrigins) free(lineOrigins);
        if (frameSetter) CFRelease(frameSetter);
        if (ctFrame) CFRelease(ctFrame);
        if (ctLines) ctLines = nil;
        
        return layout;
    }
fail:
    if (frameSetter) CFRelease(frameSetter);
    if (ctFrame) CFRelease(ctFrame);
    if (ctLines) CFRelease(ctLines);
    if (lineOrigins) free(lineOrigins);
    return nil;
}

#pragma mark - 根据最后一行CTLineRef 创建 带有折行 的 CTLineRef
+ (CTLineRef)__creatTruncationLineLastCTLine:(CTLineRef)line attributedString:(NSAttributedString *)attributedString rect:(CGRect)rect container:(DDTextContainer *)container {
    
    //最后一行 rage
    CFRange lastLineRange = CTLineGetStringRange(line);
    
    //判断这行方式
    CTLineTruncationType truncationType;
    CFIndex truncationAttributePosition = lastLineRange.location;
    switch (container.truncationType) {
        case DDTextTruncationTypeStart:
            truncationType = kCTLineTruncationStart;
            break;
        case DDTextTruncationTypeMiddle:
            truncationType = kCTLineTruncationMiddle;
            truncationAttributePosition += (lastLineRange.length / 2);
            break;
        case DDTextTruncationTypeEnd:
        default:
            truncationType = kCTLineTruncationEnd;
            truncationAttributePosition += (lastLineRange.length - 1);
            break;
    }
    
    NSDictionary *truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];
    
    NSMutableAttributedString *attributedTruncationString = [[NSMutableAttributedString alloc]init];
    if (!container.truncationToken) {
        NSString *truncationTokenString = @"\u2026"; // \u2026 对应"…"的Unicode编码
        attributedTruncationString = [[NSMutableAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
    }else{
        NSDictionary *attributedTruncationTokenAttributes = [container.truncationToken attributesAtIndex:(NSUInteger)0 effectiveRange:NULL];
        [attributedTruncationString appendAttributedString:container.truncationToken];
        if (attributedTruncationTokenAttributes.count == 0) {
            [attributedTruncationString addAttributes:truncationTokenStringAttributes range:NSMakeRange(0, attributedTruncationString.length)];
        }
    }
    
    CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTruncationString);
    
    NSUInteger lenght = lastLineRange.length;
    if (truncationType == kCTLineTruncationStart || truncationType == kCTLineTruncationMiddle) {
        lenght = attributedString.length - lastLineRange.location;
    }
    NSAttributedString *lastStr = [attributedString attributedSubstringFromRange:NSMakeRange((NSUInteger)lastLineRange.location,MIN(attributedString.length-lastLineRange.location, lenght))];
    // 获取最后一行的NSAttributedString
    NSMutableAttributedString *truncationString = [[NSMutableAttributedString alloc] initWithAttributedString:lastStr];
    if (lastLineRange.length > 0) {
        // 判断最后一行的最后是不是完整单词，避免出现 "…" 前面是一个不完整单词的情况
        unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(MIN(lastLineRange.length - 1, truncationString.length -1))];
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
            [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
        }
    }
    NSInteger lastLineLength = truncationString.length;
    switch (truncationType) {
        case kCTLineTruncationStart:
            [truncationString insertAttributedString:attributedTruncationString atIndex:0];
            break;
        case kCTLineTruncationMiddle:
            [truncationString insertAttributedString:attributedTruncationString atIndex:lastLineLength/2.0];
            break;
        case kCTLineTruncationEnd:
        default:
            [truncationString appendAttributedString:attributedTruncationString];
            break;
    }
    
    CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
    
    // 截取CTLine，以防其过长
    CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
    if (!truncatedLine) {
        // 不存在，则取truncationToken
        truncatedLine = CFRetain(truncationToken);
    }
    
    CTLineRef lastLine = CFRetain(truncatedLine);
    
    CFRelease(truncatedLine);
    CFRelease(truncationLine);
    CFRelease(truncationToken);
    
    return lastLine;
}


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
               cancel:(nullable BOOL (^)(void))cancel
{
    /** 绘制文字 */
    [self _drawTextInContext:context textLayout:self size:size point:point cancel:cancel];
    
    //需要绘制附件
    if (self.needAttachmentDraw && (context ||containerLayer || containerView)) {
        if (cancel && cancel()) return;
        [self _drawAttachmentsIncontext:context textLayou:self size:size point:point containerView:containerView containerLayer:containerLayer cancel:cancel];
    }
}

#pragma mark - 绘制 文字
- (void)_drawTextInContext:(CGContextRef)context
                textLayout:(DDTextLayout *)textLayout
                      size:(CGSize)size
                     point:(CGPoint)point
                    cancel:(nullable BOOL (^)(void))cancel
{
    if (!context) {
        return;
    }
    if (cancel && cancel()) return;
    
    @autoreleasepool {
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        NSArray* lines = textLayout.linesArray;
        [lines enumerateObjectsUsingBlock:^(DDTextLine*  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cancel && cancel()) return;
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, line.lineOrigin.x ,size.height - line.lineOrigin.y);
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger j = 0; j < CFArrayGetCount(runs);j ++) {
                if (cancel && cancel()) return;
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }];
        CGContextRestoreGState(context);
    }
}

- (void)_drawAttachmentsIncontext:(CGContextRef)context
                        textLayou:(DDTextLayout *)textLayout
                             size:(CGSize)size
                            point:(CGPoint)point
                    containerView:(UIView *)containerView
                   containerLayer:(CALayer *)containerLayer
                           cancel:(nullable BOOL (^)(void))cancel
{
    @autoreleasepool {
        
        for (NSUInteger i = 0; i < textLayout.attachments.count; i++) {
            if (cancel && cancel()) return;
            DDTextAttachment* attachment = textLayout.attachments[i];
            if (!attachment.content) {
                continue;
            }
            
            UIImage * image = nil;
            UIView  * view = nil;
            CALayer * layer = nil;
            
            if ([attachment.content isKindOfClass:[UIImage class]]) {
                image = attachment.content;
            } else if ([attachment.content isKindOfClass:[UIView class]]) {
                view = attachment.content;
            } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                layer = attachment.content;
            }
            
            if ((!image && !view && !layer) ||
                (image && !context) || (view && !containerView)
                || (layer && !containerLayer)) {
                continue;
            }
            if (cancel && cancel()) break;
            
            CGSize asize = image ? image.size : view ? view.frame.size : layer.frame.size;
            CGRect rect = ((NSValue *)textLayout.attachmentRects[i]).CGRectValue;
            rect = UIEdgeInsetsInsetRect(rect,attachment.contentEdgeInsets);
            rect =  dd_CGRectFitWithContentMode(rect,asize,attachment.contentMode);
            rect = CGRectStandardize(rect);
            rect.origin.x += point.x;
            rect.origin.y += point.y;
            
            if (image) {
                CGImageRef ref = image.CGImage;
                if (ref) {
                    CGContextSaveGState(context);
                    CGContextTranslateCTM(context, 0,CGRectGetMaxY(rect) + CGRectGetMinY(rect));
                    CGContextScaleCTM(context, 1, -1);
                    CGContextDrawImage(context, rect, ref);
                    CGContextRestoreGState(context);
                }
            } else if (view) {
                view.frame = rect;
                [containerView addSubview:view];
                dd_dispatch_main_async_safe(^{
                    layer.frame = rect;
                    [containerLayer addSublayer:layer];
                });
                
            } else if (layer) {
                dd_dispatch_main_async_safe(^{
                    layer.frame = rect;
                    [containerLayer addSublayer:layer];
                });
                
            }
        }
    }
}


/**
 *  将文本附件从UIView或CALayer上移除，在即将开始绘制时调用
 */
- (void)removeAttachmentFromSuperViewOrLayer
{
    if (!self.attachments && self.attachments.count == 0) {
        return;
    }
    for (DDTextAttachment* attachment in self.attachments) {
        @autoreleasepool {
            if ([attachment.content isKindOfClass:[UIView class]]) {
                dd_dispatch_main_async_safe(^{
                    UIView* view = attachment.content;
                    [view removeFromSuperview];
                });
            } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                dd_dispatch_main_async_safe(^{
                    CALayer* layer = attachment.content;
                    [layer removeFromSuperlayer];
                });
            }
        }
    }
}

#pragma mark - Private
#pragma mark - 根据传过来的range，计算对应的 textFrame
+ (NSArray<NSValue *> *)_searchTextFrameWithCtFrame:(CTFrameRef)ctFrame
                                          highlight:(DDTextHighlight *)highlight
                                           pathRect:(CGRect)pathRect {
    @autoreleasepool {
        
        /** 文字选中模式 */
        DDTextHighLightTextSelectedRangeType textSelectedRangeType = highlight.selectedRangeType;
        
        if (textSelectedRangeType == DDTextHighLightTextSelectedRangeWholeView) {
            //整个富文本绘制view 的 frame,这里不用计算了，在异步绘制的时候 使用 绘制view的frame就行了
            return nil;
        }
        
        CGPathRef path = CTFrameGetPath(ctFrame);
        CGRect boundsRect = CGPathGetBoundingBox(path);
        NSMutableArray* positions = [[NSMutableArray alloc] init];//记录位置坐标
        NSInteger selectionStartPosition = highlight.range.location;
        NSInteger selectionEndPosition = highlight.range.location + highlight.range.length;
        if (selectionEndPosition <= selectionStartPosition) {
            return nil;
        }
        CFArrayRef lines = CTFrameGetLines(ctFrame);
        if (!lines) {
            return nil;
        }
        
        CFIndex count = CFArrayGetCount(lines);
        CGPoint origins[count];
        CGAffineTransform transform = CGAffineTransformIdentity;
        /**
         CGAffineTransformMakeTranslation 相对平移，实现以初始位置为基准,在x轴方向上平移x单位,在y轴方向上平移y单位
         每次移动都是相对，屏幕的左上角(以左上角为相对移动的(0,0)点)，不是上次的移动到的位置，在X、Y轴平移
         */
        transform = CGAffineTransformMakeTranslation(0, boundsRect.size.height);
        /**
         CGAffineTransformScale  相对缩放，已经存在的形变为基准
         在x轴方向上缩放x倍,在y轴方向上缩放y倍
         */
        transform = CGAffineTransformScale(transform, 1.f, -1.f);
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0,0), origins);
        
        
        for (int i = 0; i < count; i++) {
            CGPoint linePoint = origins[i];
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);//获取当前 CTLineRef
            CFRange range = CTLineGetStringRange(line);//获取当前的 range
            
            ///获取换行 高度
            CGFloat lineBlankSpacing = 0;
            CFArrayRef ctRuns = CTLineGetGlyphRuns(line);
            CTRunRef run = CFArrayGetValueAtIndex(ctRuns, 0);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount > 0) {
                //熟悉字符串就算
                NSDictionary* attributes = (id)CTRunGetAttributes(run);
                NSMutableParagraphStyle* paragraphStyle = [attributes objectForKey:NSParagraphStyleAttributeName];
                //            UIFont* runFont = [attributes objectForKey:NSFontAttributeName];
                if (paragraphStyle) {
                    lineBlankSpacing = paragraphStyle.lineSpacing;
                }
            }
            
            /** 开始位置和结束位置，在当前的这一行范围之内 */
            if (selectionStartPosition >= range.location && selectionEndPosition <= (range.location+range.length)) {
                
                CGFloat ascent, descent, leading, offset, offset2;
                //获取整段文字中charIndex位置的字符相对line的原点的x值
                offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
                offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
                
                
                CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                if (lineBlankSpacing == 0 || i == count-1) {
                    lineBlankSpacing = leading;
                }
                CGFloat newWidth = offset2 - offset;
                CGFloat newX = linePoint.x + offset;
                CGFloat newY = linePoint.y - descent;
                
                if (textSelectedRangeType == DDTextHighLightTextSelectedRangeViewXAndWidth) {
                    //增加点击范围
                    if (selectionStartPosition == range.location && selectionEndPosition == (range.location+range.length)) {
                        //整行，从开始到结束
                        newX = 0;
                        newWidth = pathRect.size.width;
                    }
                }
                
                //获取当前行的rect信息，此时是 CoreText坐标
                CGRect lineRect = CGRectMake(newX,
                                             newY,
                                             newWidth,
                                             ascent + descent);
                
                ////将CoreText坐标转换为UIKit坐标
                CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
                //获取 boundsRect 中的坐标系
                CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                               rect.origin.y + boundsRect.origin.y,
                                               rect.size.width,
                                               rect.size.height);
                [positions addObject:[NSValue valueWithCGRect:adjustRect]];
                break;//结束循环
            }
            /** 上面处理了 在同一行的情况，下面是处理多行情况 */
            
            //开始 在这 一行，结束在下一行
            if (selectionStartPosition >= range.location && selectionStartPosition < (range.location+range.length))
            {
                CGFloat ascent, descent, leading, width, offset;
                offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
                width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                if (lineBlankSpacing == 0 || i == count-1) {
                    lineBlankSpacing = leading;
                }
                
                CGFloat newWidth = width - offset;
                CGFloat newHeight = ascent + descent;
                CGFloat newY = linePoint.y - descent;
                CGFloat newX = linePoint.x + offset;
                
                if (textSelectedRangeType == DDTextHighLightTextSelectedRangeWholeText) {
                    if (selectionStartPosition == range.location) {
                        newX = 0;
                    }
                    newWidth = pathRect.size.width - newX;
                    newY = ceilf(newY - lineBlankSpacing);
                    newHeight = ceilf(newHeight + lineBlankSpacing);
                } else if (textSelectedRangeType == DDTextHighLightTextSelectedRangeViewXAndWidth) {
                    if (selectionStartPosition == range.location) {
                        newX = 0;
                    }
                    newWidth = pathRect.size.width - newX;
                    newY = ceilf(newY - lineBlankSpacing);
                    newHeight = ceilf(newHeight + lineBlankSpacing);
                }
                
                CGRect lineRect = CGRectMake(newX,
                                             newY,
                                             newWidth,
                                             newHeight);
                
                CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
                CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                               rect.origin.y + boundsRect.origin.y,
                                               rect.size.width,
                                               rect.size.height);
                [positions addObject:[NSValue valueWithCGRect:adjustRect]];
                
            } else if (selectionStartPosition < range.location &&
                       selectionEndPosition >= (range.location + range.length)) {
                // 高亮状态 第二行、其他行或者最后一行
                CGFloat ascent, descent, leading, width;
                width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                if (lineBlankSpacing == 0 || i == count-1) {
                    lineBlankSpacing = leading;
                }
                
                CGFloat newWidth = width;
                CGFloat newHeight = ascent + descent;
                CGFloat newX = linePoint.x;
                CGFloat newY = linePoint.y - descent;
                
                if (textSelectedRangeType == DDTextHighLightTextSelectedRangeWholeText) {
                    newX = 0;
                    if (selectionEndPosition >= (range.location + range.length)) {
                        newWidth = pathRect.size.width;
                    } else {
                        newWidth = newWidth + linePoint.x;
                    }
                    newY = ceilf(newY - lineBlankSpacing);
                    newHeight = ceilf(newHeight + lineBlankSpacing);
                } else if (textSelectedRangeType == DDTextHighLightTextSelectedRangeViewXAndWidth) {
                    newX = 0;
                    if (selectionEndPosition >= (range.location + range.length)) {
                        newWidth = pathRect.size.width;
                    } else {
                        newWidth = newWidth + linePoint.x;
                    }
                    newY = ceilf(newY - lineBlankSpacing);
                    newHeight = ceilf(newHeight + lineBlankSpacing);
                }
                
                CGRect lineRect = CGRectMake(newX,
                                             newY,
                                             newWidth,
                                             newHeight);
                CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
                CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                               rect.origin.y + boundsRect.origin.y,
                                               rect.size.width,
                                               rect.size.height);
                [positions addObject:[NSValue valueWithCGRect:adjustRect]];
                
            } else if (selectionStartPosition < range.location && selectionEndPosition <= range.location + range.length) {
                //一直检索到最后一行的末尾之处
                CGFloat ascent, descent, leading, width, offset;
                offset = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
                width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                if (lineBlankSpacing == 0 || i == count-1) {
                    lineBlankSpacing = leading;
                }
                
                CGFloat newWidth = offset;
                CGFloat newX = linePoint.x;
                CGFloat newY = linePoint.y - descent;
                CGFloat newHeight = ascent + descent;
                
                if (textSelectedRangeType == DDTextHighLightTextSelectedRangeWholeText) {
                    newX = 0;
                    if (selectionEndPosition == (range.location + range.length)) {
                        newWidth = pathRect.size.width;
                    } else {
                        newWidth = newWidth + linePoint.x;
                    }
                    newY = ceilf(newY - lineBlankSpacing);
                    newHeight = ceilf(newHeight + lineBlankSpacing);
                } else if (textSelectedRangeType == DDTextHighLightTextSelectedRangeViewXAndWidth) {
                    newX = 0;
                    if (selectionEndPosition == (range.location + range.length)) {
                        newWidth = pathRect.size.width;
                    } else {
                        newWidth = newWidth + linePoint.x;
                    }
                    newY = ceilf(newY - lineBlankSpacing);
                    newHeight = ceilf(newHeight + lineBlankSpacing);
                }
                
                CGRect lineRect = CGRectMake(newX, newY, newWidth, newHeight);
                
                CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
                CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                               rect.origin.y + boundsRect.origin.y,
                                               rect.size.width,
                                               rect.size.height);
                if (adjustRect.size.width && adjustRect.size.height) {
                    [positions addObject:[NSValue valueWithCGRect:adjustRect]];
                }
            }
        }
        return positions;
    }
}


//- (void)setOrigin:(CGPoint)origin
//{
//    _origin = origin;
//}

- (void)dealloc {
    NSLog(@"dealloc: %@", NSStringFromClass(self.class));
    for (DDTextAttachment* attachment in self.attachments) {
        @autoreleasepool {
            if ([attachment.content isKindOfClass:[UIImage class]]) {
                attachment.content = nil;
            }
        }
    }
    
    self.attachments = nil;
    self.linesArray = nil;
    self.textHighlights = nil;
    
    if (self.path) {
        CGPathRelease(self.path);
    }
}


@end
