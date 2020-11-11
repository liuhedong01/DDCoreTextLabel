//
//  UIImageView+DDImage.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/10.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (DDImage)

@property (nonatomic, copy) NSString * _Nullable dd_imageClipURLKey;

- (void)dd_setImageWithURL:(nullable NSURL *)url;

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder;

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options;

- (void)dd_setImageWithURL:(nullable NSURL *)url
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

- (void)dd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock;


- (void)dd_setImageWithURL:(nullable NSURL *)url
                      width:(CGFloat)width
                     height:(CGFloat)height
           placeholderImage:(nullable UIImage *)placeholder clip:(BOOL)clip;

/** clip为YES时(根据self.size和self.contentMode 裁剪),也会缓存裁剪后的图片 */
- (void)dd_setImageWithURL:(nullable NSURL *)url
           placeholderImage:(nullable UIImage *)placeholder
                      width:(CGFloat)width
                     height:(CGFloat)height
                       clip:(BOOL)clip
                    options:(SDWebImageOptions)options
                   progress:(nullable SDImageLoaderProgressBlock)progressBlock
                  completed:(nullable SDExternalCompletionBlock)completedBlock;

@end

