//
//  DDPhotoItem.m
//  DDPhotoBrowser
//
//  Created by 刘和东 on 2015/5/21.
//  Copyright © 2015年 刘和东. All rights reserved.
//

#import "DDPhotoItem.h"

@implementation DDPhotoItem

- (instancetype)initWithSourceView:(UIImageView *)sourceView
                          imageUrl:(NSURL *)imageUrl
                        thumbImage:(UIImage *)thumbImage
                     thumbImageUrl:(NSURL *)thumbImageUrl
                  placeholderImage:(UIImage *)placeholderImage
{
    self = [super init];
    if (self) {
        self.sourceView = sourceView;
        self.imageUrl = imageUrl;
        self.thumbImage = thumbImage;
        self.thumbImageUrl = thumbImageUrl;
        self.placeholderImage = placeholderImage;
    }
    return self;
}
+ (instancetype)itemWithSourceView:(UIImageView *)sourceView
                          imageUrl:(NSURL *)imageUrl
                        thumbImage:(UIImage *)thumbImage
                     thumbImageUrl:(NSURL *)thumbImageUrl
                  placeholderImage:(UIImage *)placeholderImage
{
    return [[DDPhotoItem alloc] initWithSourceView:sourceView imageUrl:imageUrl thumbImage:thumbImage thumbImageUrl:thumbImageUrl placeholderImage:placeholderImage];
}

+ (instancetype)itemWithSourceView:(UIImageView *)sourceView
                          imageUrl:(NSURL *)imageUrl
                        thumbImage:(UIImage *)thumbImage
                     thumbImageUrl:(NSURL *)thumbImageUrl
{
    return [self itemWithSourceView:sourceView imageUrl:imageUrl thumbImage:thumbImage thumbImageUrl:thumbImageUrl placeholderImage:nil];
}

- (CGRect)sourceViewInWindowRect
{
    if (self.sourceView) {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        CGRect rect = [self.sourceView.superview convertRect:self.sourceView.frame toView:window];
        return rect;
    }
    return CGRectZero;
}


- (BOOL)checkIsNetworkImage
{
    if (self.imageUrl) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    NSLog(@"dealloc：%@",NSStringFromClass([self class]));
}

@end
