//
//  UIImage+DDTools.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/10.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "UIImage+DDTools.h"

@implementation UIImage (DDTools)


- (NSData *)processedToMaxSizeKB:(int)maxSizeKB
{
    @autoreleasepool {
        
        CGFloat compression = 1.0f;
        CGFloat minCompression = 0.1f;//最小压缩
        
        int maxFileSize = maxSizeKB*1024;
        
        NSData *imageData = UIImageJPEGRepresentation(self, compression);
        
        while ([imageData length]>maxFileSize && compression>minCompression) {
            
            compression -= 0.02;
            
            imageData = UIImageJPEGRepresentation(self, compression);
            
        }
        return imageData;
    }
}

- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips{
    @autoreleasepool {
        
        CGRect drawRect = dd_CGRectFitWithContentMode(rect, self.size, contentMode);
        if (drawRect.size.width == 0 || drawRect.size.height == 0) return;
        if (clips) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (context) {
                CGContextSaveGState(context);
                CGContextAddRect(context, rect);
                CGContextClip(context);
                [self drawInRect:drawRect];
                CGContextRestoreGState(context);
            }
        } else {
            [self drawInRect:drawRect];
        }
    }
}

- (UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    if (size.width <= 0 || size.height <= 0) return nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height) withContentMode:contentMode clipsToBounds:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

@end
