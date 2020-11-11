//
//  DDPhotoImageDownloadEngine.h
//  DDPhotoBrowser
//
//  Created by 刘和东 on 2015/5/21.
//  Copyright © 2015年 刘和东. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DDPhotoImageDownloadEngineProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void (^DDPhotoImageDownloadEngineFinishBlock)(UIImage * image, NSURL * url, BOOL success, NSError * error);

@protocol DDPhotoImageDownloadEngine <NSObject>
@optional
@property (nonatomic,copy) DDPhotoImageDownloadEngineFinishBlock _finish;

/**请求数据*/
- (void)setImageWithImageView:(UIImageView *)imageView
                     imageURL:(NSURL *)imageURL
                thumbImageUrl:(NSURL *)thumbImageUrl
                  placeholder:(UIImage *)placeholder
                     progress:(DDPhotoImageDownloadEngineProgressBlock)progress
                       finish:(DDPhotoImageDownloadEngineFinishBlock)finish;
- (void)setImageWithImageView:(UIImageView *)imageView
                     imageURL:(NSURL *)imageURL
                  placeholder:(UIImage *)placeholder
                     progress:(DDPhotoImageDownloadEngineProgressBlock)progress
                       finish:(DDPhotoImageDownloadEngineFinishBlock)finish;
/** 取消请求 */
- (void)cancelImageRequestWithImageView:(UIImageView *)imageView;
/** 通过url从内存中获取图片 */
- (UIImage *)imageFromMemoryCacheForURL:(NSURL *)url;
/** 通过url从磁盘中获取图片 */
- (UIImage *)imageFromDiskCacheForURL:(NSURL *)url;
/** 通过url获取图片 */
- (UIImage *)imageFromCacheForURL:(NSURL *)url;

@end
