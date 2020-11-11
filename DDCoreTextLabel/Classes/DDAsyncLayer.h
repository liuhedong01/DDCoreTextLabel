//
//  DDAsyncLayer.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/17.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class DDAsyncLayerDisplayTask;

NS_ASSUME_NONNULL_BEGIN

/** 引用 YYAsyncLayer*/
@interface DDAsyncLayer : CALayer

/** 是否需要异步绘制，默认YES */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/** 立即绘制，在主线程 */
- (void)displayImmediately;

@end

/**
 DDAsyncLayer 的代理协议，用于 任务异步 回调
 */
@protocol DDAsyncLayerDelegate <NSObject>
@required
/** 必须遵循的协议 */
- (DDAsyncLayerDisplayTask *)newAsyncDisplayTask;
@end


/**
 DDAsyncLayer 内容异步绘制时 的 回调
 */
@interface DDAsyncLayerDisplayTask : NSObject

/** 开始绘制 */
@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);

/** 绘制过程中 */
@property (nullable, nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));

/** 绘制完成 */
@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

NS_ASSUME_NONNULL_END
