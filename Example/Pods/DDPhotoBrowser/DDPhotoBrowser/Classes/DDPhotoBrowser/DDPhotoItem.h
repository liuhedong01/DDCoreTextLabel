//
//  DDPhotoItem.h
//  DDPhotoBrowser
//
//  Created by 刘和东 on 2015/5/21.
//  Copyright © 2015年 刘和东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DDPhotoItem : NSObject

/**来自哪个图*/
@property (nonatomic, weak) UIImageView * sourceView;
/**原图Image*/
@property (nonatomic, strong) UIImage *image;
/**原图URL*/
@property (nonatomic, strong) NSURL *imageUrl;
/**缩略图,默认是placeholder*/
@property (nonatomic, strong) UIImage *thumbImage;
/**缩略图URL，如果thumbImage为空，会根据thumbImageUrl从内存和磁盘中查找图片*/
@property (nonatomic, strong) NSURL *thumbImageUrl;
/**占位符*/
@property (nonatomic, strong) UIImage * placeholderImage;
@property (nonatomic, assign,readonly) CGRect sourceViewInWindowRect;//sourceView位于UIWindow坐标系中的位置）
/**用于点击图片时，从sourceView 转场到现在的window*/
@property (nonatomic, assign) BOOL firstShowAnimation;

/** 检测是否是网络图片 ，如果 imageUrl 为空 就是 本地图片， 不判断 thumbImageUrl是否存在 */
- (BOOL)checkIsNetworkImage;

+ (instancetype)itemWithSourceView:(UIImageView *)sourceView
                          imageUrl:(NSURL *)imageUrl
                        thumbImage:(UIImage *)thumbImage
                     thumbImageUrl:(NSURL *)thumbImageUrl
                  placeholderImage:(UIImage *)placeholderImage;

+ (instancetype)itemWithSourceView:(UIImageView *)sourceView
                          imageUrl:(NSURL *)imageUrl
                        thumbImage:(UIImage *)thumbImage
                     thumbImageUrl:(NSURL *)thumbImageUrl;


@end
