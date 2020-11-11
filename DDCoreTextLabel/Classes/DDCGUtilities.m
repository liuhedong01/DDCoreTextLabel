//
//  DDCGUtilities.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDCGUtilities.h"
#import <CoreText/CoreText.h>

CGRect dd_CGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode)
{
    rect = CGRectStandardize(rect);
    if (size.width == 0) {
        size.width = rect.size.width;
    }
    if (size.height == 0) {
        size.height = rect.size.height;
    }
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (mode) {
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (mode == UIViewContentModeScaleAspectFit) {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / size.height;
                    } else {
                        scale = rect.size.width / size.width;
                    }
                } else {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / size.width;
                    } else {
                        scale = rect.size.height / size.height;
                    }
                }
                size.width *= scale;
                size.height *= scale;
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
        } break;
        case UIViewContentModeCenter: {
            rect.size = size;
            rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
        } break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeTopLeft: {
            rect.size = size;
        } break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }
    return rect;
}

/*** 获取高度，最大行数maxNumberOfLines为0表示不限制，返回多少行numberOfLines */
CGFloat dd_getStringHeightAndNumberOfLinesAndRange(NSAttributedString * attributedString,CGFloat width,NSUInteger maxNumberOfLines,int * numberOfLines, CFRange* range)
{
    if (!attributedString && attributedString.length == 0) {
        return 0;
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGRect drawingRect = CGRectMake(0, 0, width, 100000000);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *)CTFrameGetLines(textFrame);
        
    NSUInteger lineCount = linesArray.count;

    CGPoint *lineOrigins = NULL;

    lineOrigins = malloc(lineCount * sizeof(CGPoint));

    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), lineOrigins);
    
    int lastLineRow = (int)linesArray.count - 1;
    
    if (maxNumberOfLines > 0) {
        if (linesArray.count > maxNumberOfLines) {//大于最大行数
            lastLineRow = (int)maxNumberOfLines - 1;
        }
    }
    
    int line_y = (int)lineOrigins[lastLineRow].y;  //最后一行line的原点y坐标
    
    //行数
    *numberOfLines = lastLineRow + 1;
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef lastLine = (__bridge CTLineRef)[linesArray objectAtIndex:lastLineRow];
    CTLineGetTypographicBounds(lastLine, &ascent, &descent, &leading);
    
    CFRange lastRange = CTLineGetStringRange(lastLine);
    
    *range = CFRangeMake(0, lastRange.location + lastRange.length);
    
    if (textFrame) {
        CFRelease(textFrame);
    }
    
    if (lineOrigins) free(lineOrigins);

    linesArray = nil;


    CGFloat totalHeight = ceilf(100000000-line_y + ceilf(fabs(descent)));
    
    return totalHeight;
}
