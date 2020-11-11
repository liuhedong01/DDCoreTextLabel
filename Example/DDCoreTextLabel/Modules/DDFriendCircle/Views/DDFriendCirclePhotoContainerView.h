//
//  DDFriendCirclePhotoContainerView.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 图片容器
@interface DDFriendCirclePhotoContainerView : UIView

/** 图片数组 */
@property (nonatomic, strong) NSMutableArray * photoViewArray;

/**
 刷新图片坐标和图片
 */
- (void)bindPhotoFrames:(NSArray *)photoFrames photoArray:(NSArray *)photoArray;

/**
 imageViewVisibleArray 可以见 图片数组
 selectedRow 当前选中的第几个
 */
@property (nonatomic, copy) void (^imageViewClickedBlock)(NSInteger selectedRow);


@end

