//
//  DDPhotoImageView.h
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import "DDBrowseImageView.h"
#import "DDPhotoItem.h"


/** 登录类型 */
typedef NS_ENUM(NSUInteger,DDPhotoImageScrollAnimateType) {
    DDPhotoImageScrollAnimateSlidingDownType              = 1, //向下滑动中
    DDPhotoImageScrollAnimateDisappearingType             = 2, //消失中..渐渐变浅
    DDPhotoImageScrollAnimateFinishedType                 = 3, //结束
    DDPhotoImageScrollAnimateDiscontinueType              = 4, //下滑中止
};

#define kDDPhotoBrowserAnimationTime 0.33

NS_ASSUME_NONNULL_BEGIN

/** 对单个图片查看的扩展，图片加载、下滑缩放、首次加载 */
@interface DDPhotoImageView : DDBrowseImageView

/** 图片的item */
@property (nonatomic, strong) DDPhotoItem * item;

/** type 1:下滑进行中，scale用于控制背景颜色的透明度 ,, 2:消失动画 进行中 ,, 3:消失动画结束 */
@property (nonatomic, copy) void (^scrollAnimateBlock)(DDPhotoImageScrollAnimateType type,CGFloat scale);

@end

NS_ASSUME_NONNULL_END
