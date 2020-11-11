//
//  DDPhotoSDImageDownloadEngine.m
//  DDPhotoBrowser
//
//  Created by 刘和东 on 2015/5/21.
//  Copyright © 2015年 刘和东. All rights reserved.
//

#import "DDPhotoSDImageDownloadEngine.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>


@implementation DDPhotoSDImageDownloadEngine

/**请求数据*/
- (void)setImageWithImageView:(nullable UIImageView *)imageView
                     imageURL:(nullable NSURL *)imageURL
                thumbImageUrl:(nullable NSURL *)thumbImageUrl
                  placeholder:(nullable UIImage *)placeholder
                     progress:(nullable DDPhotoImageDownloadEngineProgressBlock)progress
                       finish:(nullable DDPhotoImageDownloadEngineFinishBlock)finish
{
    if (thumbImageUrl) {
        
        UIImage * image = [self imageFromCacheForURL:thumbImageUrl];
        
        if (image) {
            
            placeholder = image;
            
        }
        
    }
    
    [self setImageWithImageView:imageView imageURL:imageURL placeholder:placeholder progress:progress finish:finish];
    
}
- (void)setImageWithImageView:(nullable UIImageView *)imageView
                     imageURL:(nullable NSURL *)imageURL
                  placeholder:(nullable UIImage *)placeholder
                     progress:(nullable DDPhotoImageDownloadEngineProgressBlock)progress
                       finish:(nullable DDPhotoImageDownloadEngineFinishBlock)finish
{
    
    [imageView sd_setImageWithURL:imageURL placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        if (progress) {
            progress(receivedSize,expectedSize);
        }
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if (finish) {
            finish(image, imageURL, !error, error);
        }
        
    }];
}
/**取消请求*/
- (void)cancelImageRequestWithImageView:(nullable UIImageView *)imageView
{
    [imageView sd_cancelCurrentImageLoad];
}
/**通过url从内存中获取图片*/
- (UIImage *_Nullable)imageFromMemoryCacheForURL:(nullable NSURL *)url
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
}
/**通过url从磁盘中获取图片*/
- (UIImage *_Nullable)imageFromDiskCacheForURL:(nullable NSURL *)url
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
}
/**通过url获取图片*/
- (nullable UIImage *)imageFromCacheForURL:(nullable NSURL *)url
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
}

@end
