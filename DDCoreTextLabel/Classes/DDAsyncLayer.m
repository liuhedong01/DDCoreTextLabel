//
//  DDAsyncLayer.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/17.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDAsyncLayer.h"
#import "DDSentinel.h"
#import <libkern/OSAtomic.h>
#import "DDDispatchQueuePool.h"

static dispatch_queue_t DDAsyncLayerGetDisplayQueue() {
    return YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated);
}

static dispatch_queue_t DDAsyncLayerGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

/**
 DDAsyncLayer 内容异步绘制时 的 回调
 */
@implementation DDAsyncLayerDisplayTask
@end


@implementation DDAsyncLayer {
    DDSentinel *_sentinel;
}

/** 返回key这个属性名所对应的属性值的默认值，如果默认值是未知的，返回nil，子类可以重载这个方法，来设定一些默认值 */
+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"displaysAsynchronously"]) {
        return @(YES);
    } else {
        return [super defaultValueForKey:key];
    }
}

/**初始化*/
- (instancetype)init
{
    self = [super init];
    if (self) {
        static CGFloat scale;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            scale = [UIScreen mainScreen].scale;
        });
        self.contentsScale = scale;
        _sentinel = [DDSentinel new];
        _displaysAsynchronously = YES;
    }
    return self;
}

/** 释放的时候自增 ，用来取消异步绘制*/
- (void)dealloc
{
    [_sentinel increase];
}

/**  异步执行，自动调用drawInContext （view调用 drawRect ）（rect不能为0时）方法，拿到 UIGraphicsGetCurrentContext */
- (void)setNeedsDisplay
{
    /** 取消上次的绘制 */
    [self _cancelAsyncDisplay];
    [super setNeedsDisplay];
}

/** 立即绘制，在主线程 */
- (void)displayImmediately
{
    [_sentinel increase];
    [self _displayAsync:NO];
}

/**
 layer方法响应链有两种:
 1：setNeedDisplay -> displayIfNeed —> display -> displayLayer:
 2：setNeedDisplay -> displayIfNeed —> display -> drawInContext: -> [layerDelegate drawLayer: inContext:]
 */
- (void)display
{
    super.contents = super.contents;
    [self _displayAsync:_displaysAsynchronously];
}

#pragma mark - Private
- (void)_displayAsync:(BOOL)async
{
    //    默认持有 CALayer的delegate 是 持有它的view
    __strong id<DDAsyncLayerDelegate> delegate = (id)self.delegate;
    /**初始化*/
    DDAsyncLayerDisplayTask * task = [delegate newAsyncDisplayTask];
    
    //没有绘制block，再调用其他的两个block
    if (!task.display) {
        if (task.willDisplay) task.willDisplay(self);
        //获取contents内容
        CGImageRef imageRef = (__bridge_retained CGImageRef)self.contents;
        //清空contents内容
        self.contents = nil;
        if (imageRef) {
            //如果图片，异步 release image
            dispatch_async(DDAsyncLayerGetReleaseQueue(), ^{
                CFRelease(imageRef);
            });
        }
        if (task.didDisplay) task.didDisplay(self, YES);
        return;
    }
    
    //判断是否是异步
    if (async) {//异步绘制
        //先通知 willDisplay
        
            
            
            if (task.willDisplay) task.willDisplay(self);
            //获取哨兵，用于处理绘制取消
            DDSentinel * sentinel = _sentinel;
            int32_t value = sentinel.value;
            //一个block变量，返回判断是否取消绘制
            BOOL (^isCancelled)(void) = ^BOOL() {
                return value != sentinel.value;
            };
            CGSize size = self.bounds.size;
            BOOL opaque = self.opaque;//是否透明
            CGFloat scale = self.contentsScale;
            CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
            //长宽 < 1 ,清除 contents 内容
            if (size.width < 1 || size.height < 1) {
                //获取contents内容
                CGImageRef imageRef = (__bridge_retained CGImageRef)self.contents;
                //清空contents内容
                self.contents = nil;
                if (imageRef) {
                    //如果图片，异步 release image
                    dispatch_async(DDAsyncLayerGetReleaseQueue(), ^{
                        CFRelease(imageRef);
                    });
                }
                //已经完成
                if (task.didDisplay) task.didDisplay(self, YES);
                CGColorRelease(backgroundColor);
                return;//返回
            }
            
        @autoreleasepool {
#pragma mark - 异步绘制
            dispatch_async(DDAsyncLayerGetDisplayQueue(), ^{
                //判断是否取消,取消就返回
                if (isCancelled()) {
                    CGColorRelease(backgroundColor);
                    return;
                }
                //1.开启上下文
                UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
                //1.获取当前上下文
                CGContextRef context = UIGraphicsGetCurrentContext();
                if (opaque && context) {
                    /**
                     CGContextSaveGState：压栈操作，保存一份当前图形上下文
                     CGContextRestoreGState：出栈操作，恢复一份当前图形上下文
                     */
                    //CGContextSaveGState记录上下文的当前状态,保存当前状态,填充背景颜色
                    CGContextSaveGState(context); {
                        //背景颜色不存在 或者 背景颜色的alpha值小于1的时候
                        if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                            //设置颜色
                            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                            //CGContextAddRect 画矩形
                            CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                            //CGContextFillPath填充路径
                            CGContextFillPath(context);
                        }
                        if (backgroundColor) {//背景存在，而且没有alpha通道
                            CGContextSetFillColorWithColor(context, backgroundColor);
                            CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                            CGContextFillPath(context);
                        }
                    } CGContextRestoreGState(context);//CGContextRestoreGState函数将当前状态恢复到绘图之前的状态
                    //释放掉背景颜色
                    CGColorRelease(backgroundColor);
                }//设置背景颜色完毕
                //这里不用判断 display 是否存在，在开始已经判断了
                //回调给 拥有此layer的view 去绘制
                task.display(context, size, isCancelled);
                //判断是否取消绘制
                if (isCancelled()) {//取消绘制
                    //关闭上下文
                    UIGraphicsEndImageContext();
                    //在主线程中返回 didDisplay回调，绘制取消
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (task.didDisplay) task.didDisplay(self, NO);
                    });
                    return;
                }
                //从上下文当中生成一张图片
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                //关闭上下文
                UIGraphicsEndImageContext();
                if (isCancelled()) {//取消绘制
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (task.didDisplay) task.didDisplay(self, NO);
                    });
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isCancelled()) {
                        if (task.didDisplay) task.didDisplay(self, NO);
                    } else {
                        self.contents = (__bridge id)(image.CGImage);
                        if (task.didDisplay) task.didDisplay(self, YES);
                    }
                });
                
            });
        }
    } else {
        @autoreleasepool {
            //不是异步绘制
            [_sentinel increase];
            if (task.willDisplay) task.willDisplay(self);
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (self.opaque && context) {
                CGSize size = self.bounds.size;
                size.width *= self.contentsScale;
                size.height *= self.contentsScale;
                CGContextSaveGState(context); {
                    if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                        CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                        CGContextFillPath(context);
                    }
                    if (self.backgroundColor) {
                        CGContextSetFillColorWithColor(context, self.backgroundColor);
                        CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                        CGContextFillPath(context);
                    }
                } CGContextRestoreGState(context);
            }
            task.display(context, self.bounds.size, ^{return NO;});
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.contents = (__bridge id)(image.CGImage);
            if (task.didDisplay) task.didDisplay(self, YES);
        }
    }
}

/** 用于标记 取消异步绘制 */
- (void)_cancelAsyncDisplay {
    [_sentinel increase];
}


@end
