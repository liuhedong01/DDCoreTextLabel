//
//  DDSystemImageView.m
//  DDPhotoBrowser
//
//  Created by 刘和东 on 2015/5/21.
//  Copyright © 2015年 刘和东. All rights reserved.
//

#import "DDSystemImageView.h"

@interface DDSystemImageView ()

@property (nonatomic,strong) UIImageView * imageView;

@end

@implementation DDSystemImageView

- (UIImageView *)getImageViewWithFrame:(CGRect)frame
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
    }
    return _imageView;
}
- (UIImageView *)getImageView
{
    return [self getImageViewWithFrame:CGRectZero];
}

- (NSData *)getImageData
{
    UIImage * image = self.imageView.image;
    NSData * imageData = UIImagePNGRepresentation(image);
    if (!imageData || imageData.length == 0) {
        //空
        imageData = UIImageJPEGRepresentation(image, 1);
    }
    
    return imageData;
}

- (UIImage *)getImage {
    return self.imageView.image;
}

@end
