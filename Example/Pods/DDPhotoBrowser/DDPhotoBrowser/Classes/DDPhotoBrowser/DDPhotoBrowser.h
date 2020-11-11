//
//  DDPhotoBrowser.h
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPhotoImageDownloadEngine.h"
#import "DDGetImageViewEngine.h"
#import "DDPhotoItem.h"

@protocol DDPhotoImageDownloadEngine;


typedef NS_ENUM(NSUInteger, DDPhotoBrowserPageIndicateStyle) {
    DDPhotoBrowserPageIndicateStylePageLabel = 1,/**pageLabel*/
    DDPhotoBrowserPageIndicateStylePageControl/**pageControl*/
};

@interface DDPhotoBrowser : UIViewController

/**page指示类型,默认是DDPhotoBrowserPageIndicateStylePageLabel*/
@property (nonatomic, assign) DDPhotoBrowserPageIndicateStyle pageIndicateStyle;

/** view消失回调 */
@property (nonatomic, copy) void (^viewDismissCompletionBlock)(void);

/** 返回当前的滑动的那个 */
@property (nonatomic, copy) void (^photoBrowserScrollToIndexBlock)(NSInteger index,DDPhotoItem * item);

/** 长按手势 手势点击了 回调 */
@property (nonatomic, copy) void (^longPressGestureClickedBlock)(DDPhotoBrowser * browser,NSInteger index,DDPhotoItem * item,NSData * imageData);

/**
 * 默认使用 初始化
 */
+ (instancetype)photoBrowserWithPhotoItems:(NSArray<DDPhotoItem *> *)photoItems
                              currentIndex:(NSUInteger)currentIndex
                         getImageViewClass:(Class<DDGetImageViewEngine>)getImageViewClass
                            downloadEngine:(id<DDPhotoImageDownloadEngine>)downloadEngine;

/**弹出*/
- (void)showFromVC:(UIViewController *)vc;

@end

