//
//  UIImage+DDTools.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/10.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (DDTools)

- (NSData *)processedToMaxSizeKB:(int)maxSizeKB;

- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

- (UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

@end

