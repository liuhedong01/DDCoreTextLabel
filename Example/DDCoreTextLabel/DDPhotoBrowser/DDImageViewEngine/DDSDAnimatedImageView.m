//
//  DDSDAnimatedImageView.m
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/3/4.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import "DDSDAnimatedImageView.h"
#import <SDWebImage/SDAnimatedImageView.h>
#import <SDWebImage/SDAnimatedImage.h>

@interface DDSDAnimatedImageView ()

@property (nonatomic,strong) SDAnimatedImageView * imageView;

@end

@implementation DDSDAnimatedImageView

- (UIImageView *)getImageViewWithFrame:(CGRect)frame
{
    if (!_imageView) {
        _imageView = [[SDAnimatedImageView alloc] initWithFrame:frame];
        NSLog(@"image allock");
    }
    NSLog(@"%@", _imageView);
    return _imageView;
}

- (UIImageView *)getImageView
{
    return [self getImageViewWithFrame:CGRectZero];
}


- (NSData *)getImageData
{
    NSData * imageData = nil;
    
    if ([self.imageView.image conformsToProtocol:@protocol(SDAnimatedImage)]) {
        
        UIImage <SDAnimatedImage> *animatedImage = (UIImage<SDAnimatedImage> *)self.imageView.image;
        
        imageData = animatedImage.animatedImageData;
        
    }
    
    if (!imageData || imageData.length == 0) {
        
        imageData = UIImagePNGRepresentation(self.imageView.image);
        if (!imageData || imageData.length == 0) {
            
            //空
            
            imageData = UIImageJPEGRepresentation(self.imageView.image, 1);
            
        }
    }
    return imageData;
}

- (UIImage *)getImage {
    return self.imageView.image;
}


@end
