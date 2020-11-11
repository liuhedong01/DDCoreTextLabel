//
//  DDTransaction.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/17.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDTransaction.h"
#import <objc/message.h>

@interface DDTransactionManager : NSObject

@property (nonatomic,strong) NSMutableSet * transactionSet;

@end

@implementation DDTransactionManager

static DDTransactionManager * transactionManager = nil;
+ (instancetype)sharedInstance
{
    if (transactionManager == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            transactionManager = [[DDTransactionManager alloc] init];
            transactionManager.transactionSet = [NSMutableSet new];
        });
    }
    return transactionManager;
}

@end

/** 任务 */
@interface DDTransaction()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) id object;

/** 发送消息 */
- (void)__objcMsgSend;

@end

static void DDRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if ([DDTransactionManager sharedInstance].transactionSet.count == 0) return;
    NSSet *currentSet = [DDTransactionManager sharedInstance].transactionSet;
    [currentSet enumerateObjectsUsingBlock:^(DDTransaction *transaction, BOOL *stop) {
        //发送消息
        [transaction __objcMsgSend];
    }];
    
}

static void DDTransactionSetup(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //返回主线程的RunLoop引用
        CFRunLoopRef runLoopRef = CFRunLoopGetMain();
        //CFRunLoopObserverRef  runloop观察者，CFRunLoopObserverCreate 创建Runloop的观察者
        //kCFRunLoopBeforeWaiting | kCFRunLoopExit 观察者观察的事件(状态)，进入等待或即将退出的时候开始执行观察者
        //repeats 观察者是否重复 YES
        //CFIndex order,知道观察者的优先级，CFRunLoopMode中是数组形式存储的observer，_order就是他在数组中的位置
        //CFRunLoopObserverCallBack callout 观察者函数回调
        //最后一个参数CFRunLoopObserverContext,，不需要传 NULL
        //        CFRunLoopObserverContext context = {
        //            0,
        //            (__bridge void *)obj,//需要传递的参数
        //            &CFRetain,
        //            &CFRelease,
        //            NULL
        //        };
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting | kCFRunLoopExit, YES, 0xFFFFFF, DDRunLoopObserverCallBack, NULL);
        //CFRunLoopGetMain() 添加观察者 observer，在 commonModes
        CFRunLoopAddObserver(runLoopRef, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

@implementation DDTransaction

+ (DDTransaction *)transactionWithTarget:(id)target
                                selector:(SEL)selector
                                  object:(id)object
{
    if (!target || !selector) return nil;
    DDTransaction *t = [DDTransaction new];
    t.target = target;
    t.selector = selector;
    t.object = object;
    return t;
}

- (void)commit {
    if (!_target || !_selector) return;
    DDTransactionSetup();
    [[DDTransactionManager sharedInstance].transactionSet addObject:self];
}

/** 发送消息 */
- (void)__objcMsgSend
{
    //    CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();
    //    CFRunLoopMode model =  CFRunLoopCopyCurrentMode(runLoopRef);
    //    if (model == kCFRunLoopDefaultMode) {
    //    }
//    NSLog(@"fff");
    if (!_target || !_selector) return;
    if (_object) {
        void (*objc_msgSendToPerform)(id, SEL, id) = (void*)objc_msgSend;
        objc_msgSendToPerform(self.target,self.selector,self.object);
    } else {
        void (*objc_msgSendToPerform)(id, SEL) = (void*)objc_msgSend;
        objc_msgSendToPerform(self.target,self.selector);
    }
    self.target = nil;
    self.selector = nil;
    self.object = nil;
}

- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    DDTransaction *other = object;
    return other.selector == _selector && other.target == _target && other.object == _object;
}


@end


