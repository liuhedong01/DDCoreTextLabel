//
//  DDBrowseImageView.h
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDGetImageViewEngine.h"
#import "DDPhotoImageDownloadEngine.h"

NS_ASSUME_NONNULL_BEGIN

/** 查看单个图片 */
@interface DDBrowseImageView : UIView <UIScrollViewDelegate,UIGestureRecognizerDelegate>

/** 图片索引，具体图片 根据 getImageViewEngine 生成 */
@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) UIScrollView * scrollView;

/** 双击手势 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleGestureRecognizer;

/** 单点手势 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;

/** 长按手势 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

/** 单点 手势点击了 回调 */
@property (nonatomic, copy) void (^singleTapGestureClickedBlock)(void);

/** 长按手势 手势点击了 回调 */
@property (nonatomic, copy) void (^longPressGestureClickedBlock)(NSData * imageData);

/** 双击手势 手势点击了 回调 */
@property (nonatomic, copy) void (^doubleGestureClickedBlock)(void);


/**  图片下载 */
@property (nonatomic, strong) id<DDPhotoImageDownloadEngine> imageDownloadEngine;

- (instancetype)initWithFrame:(CGRect)frame
           getImageViewEngine:(id<DDGetImageViewEngine>)getImageViewEngine;

#pragma mark - 初始化基础数据
- (void)setupPhotoImageView;

#pragma mark - 改变图片大小
- (void)resizeImageView;

#pragma mark - 移除所有的手势
- (void)removeAllGestureRecognizers;

- (CGPoint)centerInScrollView:(UIScrollView *)scrollView;

@end


NS_ASSUME_NONNULL_END
