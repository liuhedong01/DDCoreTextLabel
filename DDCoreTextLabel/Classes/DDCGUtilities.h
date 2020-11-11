//
//  DDCGUtilities.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "DDTextLine.h"

#ifndef dd_dispatch_main_async_safe
#define dd_dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

/** 转行模式 */
CGRect dd_CGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/*** 获取高度，最大行数maxNumberOfLines为0表示不限制，返回多少行numberOfLines */
CGFloat dd_getStringHeightAndNumberOfLinesAndRange(NSAttributedString * attributedString,CGFloat width,NSUInteger maxNumberOfLines,int * numberOfLines, CFRange* range);
