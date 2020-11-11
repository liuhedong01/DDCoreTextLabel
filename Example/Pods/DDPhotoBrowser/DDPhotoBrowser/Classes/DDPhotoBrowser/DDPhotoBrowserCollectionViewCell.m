//
//  DDPhotoBrowserCollectionViewCell.m
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import "DDPhotoBrowserCollectionViewCell.h"

@interface DDPhotoBrowserCollectionViewCell ()

@property (nonatomic, strong) DDPhotoImageView * imageView;

/**  获取图片 */
@property (nonatomic, strong) id<DDGetImageViewEngine> getImageViewEngine;

@end



@implementation DDPhotoBrowserCollectionViewCell

- (void)setItem:(DDPhotoItem *)item
{
    _item = item;
    
    self.imageView.item = item;

}

- (void)setGetImageViewClass:(Class<DDGetImageViewEngine>)getImageViewClass
{
    if (!_getImageViewEngine) {
        Class class = getImageViewClass.class;
        self.getImageViewEngine = [[class alloc] init];
    }
}
- (void)setGetImageViewEngine:(id<DDGetImageViewEngine>)getImageViewEngine
{
    _getImageViewEngine = getImageViewEngine;
    if (!_imageView) {
        //没有
        _imageView = [[DDPhotoImageView alloc] initWithFrame:[UIScreen mainScreen].bounds getImageViewEngine:getImageViewEngine];
                
        _imageView.imageDownloadEngine = self.imageDownloadEngine;
                
        [self.contentView addSubview:self.imageView];
    }
    
}

- (void)setImageDownloadEngine:(id<DDPhotoImageDownloadEngine>)imageDownloadEngine
{
    if (!_imageDownloadEngine) {
        _imageDownloadEngine = imageDownloadEngine;
        if (_imageView) {
            self.imageView.imageDownloadEngine = imageDownloadEngine;
        }
    }
}

@end
