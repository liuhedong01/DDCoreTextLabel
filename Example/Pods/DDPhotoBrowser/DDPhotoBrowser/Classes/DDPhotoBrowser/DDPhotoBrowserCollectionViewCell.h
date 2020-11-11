//
//  DDPhotoBrowserCollectionViewCell.h
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPhotoImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPhotoBrowserCollectionViewCell : UICollectionViewCell


/**  获取图片 */
@property (nonatomic, copy) Class<DDGetImageViewEngine> getImageViewClass;

/**  图片下载 */
@property (nonatomic, strong) id<DDPhotoImageDownloadEngine> imageDownloadEngine;

@property (nonatomic, strong, readonly) DDPhotoImageView * imageView;


@property (nonatomic, strong) DDPhotoItem * item;

@end

NS_ASSUME_NONNULL_END
