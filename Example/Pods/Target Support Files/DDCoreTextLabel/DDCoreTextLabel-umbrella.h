#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DDAsyncLayer.h"
#import "DDCGUtilities.h"
#import "DDCoreTextHeader.h"
#import "DDCoreTextLabel.h"
#import "DDTextAttribute.h"
#import "DDTextContainer.h"
#import "DDTextGlyph.h"
#import "DDTextLayout.h"
#import "DDTextLine.h"
#import "DDTextRunDelegate.h"
#import "NSMutableAttributedString+DDCoreText.h"
#import "DDDispatchQueuePool.h"
#import "DDSentinel.h"
#import "DDTransaction.h"
#import "DDWeakProxy.h"

FOUNDATION_EXPORT double DDCoreTextLabelVersionNumber;
FOUNDATION_EXPORT const unsigned char DDCoreTextLabelVersionString[];

