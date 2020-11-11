//
//  UIImageView+DDImage.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/10.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "UIImageView+DDImage.h"
#import <objc/runtime.h>

@implementation UIImageView (DDImage)

#pragma mark - 缩略图key
- (NSString *)dd_imageClipURLKey
{
    return objc_getAssociatedObject(self, @selector(dd_imageClipURLKey));
}

- (void)setDd_imageClipURLKey:(NSString *)dd_imageClipURLKey
{
    objc_setAssociatedObject(self, @selector(dd_imageClipURLKey), dd_imageClipURLKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)dd_setImageWithURL:(nullable NSURL *)url
{
    [self dd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
{
    [self dd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
{
    [self dd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)dd_setImageWithURL:(nullable NSURL *)url
                 completed:(nullable SDExternalCompletionBlock)completedBlock
{
    [self dd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable SDExternalCompletionBlock)completedBlock
{
    [self dd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                 completed:(nullable SDExternalCompletionBlock)completedBlock
{
    [self dd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock
{
    [self dd_setImageWithURL:url placeholderImage:placeholder width:0 height:0 clip:NO options:options progress:progressBlock completed:completedBlock];
}

- (void)dd_setImageWithURL:(nullable NSURL *)url
                     width:(CGFloat)width
                    height:(CGFloat)height
          placeholderImage:(nullable UIImage *)placeholder clip:(BOOL)clip;
{
    [self dd_setImageWithURL:url placeholderImage:placeholder width:width height:height clip:clip options:0 progress:nil completed:nil];
}

/** clip为YES时(根据self.size和self.contentMode 裁剪),也会缓存裁剪后的图片 */
- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                     width:(CGFloat)width
                    height:(CGFloat)height
                      clip:(BOOL)clip
                   options:(SDWebImageOptions)options
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock
{
    /** 缓存key */
    NSString *urlKey = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    
    if ((!urlKey || urlKey.length == 0) || ( clip && (width <=0 || height <= 0) )) {
        [self _cancelCurrentImageLoad];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = placeholder;
        });
        if (completedBlock) {
            completedBlock(nil,nil,SDImageCacheTypeNone,url);
        }
        return;
    }
    
    [self _cancelCurrentImageLoad];
    
    NSString * clipUrlCacheKey = [NSString stringWithFormat:@"%@_%d%d",urlKey, (int)width,(int)height];
    
    /** 缓存key */
    self.dd_imageClipURLKey = clip ? clipUrlCacheKey : nil;
    
    @autoreleasepool {
        
        if (clip) {
            
            /** 判断 本地 是否存在剪切后的图片 */
            UIImage * clipImage =  [[SDImageCache sharedImageCache] imageFromCacheForKey:clipUrlCacheKey];;
            if (clipImage) {
                /** 获取到 了裁剪后的图片 */
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = clipImage;
                    if (completedBlock) {
                        completedBlock(clipImage,nil,SDImageCacheTypeMemory,url);
                    }
                });
                [self _cancelCurrentImageLoad];
                return;
            } else {
                /** 不存在 , 看原图是否存在*/
                UIImage * image =  [[SDImageCache sharedImageCache] imageFromCacheForKey:urlKey];
                if (image) {
                    self.image = image;
                    /** 原图存在,裁剪 */
                    UIViewContentMode contentMode = self.contentMode;
                    
                    CGSize size = CGSizeMake(width, height);
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        UIImage * clipImage = [self _processedWithImage:image contentMode:contentMode size:size];
                        
                        if (clipImage) {
                            
                            /** 获取到 了裁剪后的图片 */
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                self.image = clipImage;
                                
                                if (completedBlock) {
                                    
                                    completedBlock(clipImage,nil,SDImageCacheTypeMemory,url);
                                    
                                }
                                
                            });
                            
                            [[SDImageCache sharedImageCache] storeImage:clipImage forKey:clipUrlCacheKey completion:nil];
                            
                        } else {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.image = image;
                                if (completedBlock) {
                                    completedBlock(image,nil,SDImageCacheTypeMemory,url);
                                }
                            });
                        }
                        
                        [[SDImageCache sharedImageCache] removeImageForKey:urlKey fromDisk:NO withCompletion:^{
                            
                        }];
                        
                    });
                    [self _cancelCurrentImageLoad];
                    return;
                }
            }
        } else {
            /**  看原图是否存在*/
            UIImage * image =  [[SDImageCache sharedImageCache] imageFromCacheForKey:urlKey];
            if (image) {
                //存在
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = image;
                    if (completedBlock) {
                        completedBlock(image,nil,SDImageCacheTypeMemory,url);
                    }
                });
                [self _cancelCurrentImageLoad];
                return;
            }
        }
        
        if (placeholder) {
            dispatch_main_async_safe(^{
                self.image = placeholder;
            });
        } else {
            self.image = nil;
        }
        
    }
    __weak typeof(self) weakSelf = self;
    ///////////////////////////////////////////////
    /** 缓存不存在，去下载 */
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        
        
        @autoreleasepool {
            
            NSString * clipUrlCacheKey = strongSelf.dd_imageClipURLKey;
            
            NSString * imageURLKey = [[SDWebImageManager sharedManager] cacheKeyForURL:imageURL];
            
            if (image && clip && clipUrlCacheKey && clipUrlCacheKey.length && [clipUrlCacheKey containsString:imageURLKey]) {
                
                UIViewContentMode contentMode = strongSelf.contentMode;
                
                CGSize size = CGSizeMake(width, height);
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    UIImage * clipImage = [strongSelf _processedWithImage:image contentMode:contentMode size:size];
                    
                    [[SDImageCache sharedImageCache] storeImage:clipImage forKey:clipUrlCacheKey completion:nil];
                    
                    [[SDImageCache sharedImageCache] removeImageForKey:urlKey fromDisk:NO withCompletion:nil];
                    
                    /** 获取到 了裁剪后的图片 */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        strongSelf.layer.contents = nil;
                        
                        strongSelf.image = clipImage;
                        if (completedBlock) {
                            completedBlock(clipImage,nil,SDImageCacheTypeMemory,url);
                        }
                    });
                    
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completedBlock) {
                        completedBlock(image,nil,SDImageCacheTypeMemory,url);
                    }
                });
                
            }
            
            [strongSelf _cancelCurrentImageLoad];
        }
    }];
    
}

- (void)_cancelCurrentImageLoad
{
    [self sd_cancelCurrentImageLoad];
    self.dd_imageClipURLKey = nil;
}


- (UIImage *)_processedWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode size:(CGSize)size
{
    image = [image imageByResizeToSize:size contentMode:contentMode];
    
    NSData * data = [image processedToMaxSizeKB:10];

    image = [UIImage sd_imageWithData:data];
    
//    image = [UIImage sd_decodedImageWithImage:image];
    
    return image;
}

@end
