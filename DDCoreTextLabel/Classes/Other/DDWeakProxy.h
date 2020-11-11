//
//  DDWeakProxy.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/23.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 完全引用 YYWeakProxy
 A proxy used to hold a weak object.
 It can be used to avoid retain cycles, such as the target in NSTimer or CADisplayLink.
 
 sample code:
 
    @implementation MyView {
        NSTimer *_timer;
    }
    - (void)initTimer {
    DDWeakProxy *proxy = [DDWeakProxy proxyWithTarget:self];
    _timer = [NSTimer timerWithTimeInterval:0.1 target:proxy selector:@selector(tick:) userInfo:nil repeats:YES];
 }
 
 - (void)tick:(NSTimer *)timer {...}
 @end
 */


/** 这个代理对象有一个weak的target对象，用来实现转发消息,并避免循环引用 */
@interface DDWeakProxy : NSProxy

/** 代理对象 */
@property (nonatomic, weak, readonly) id target;

+ (instancetype)proxyWithTarget:(id)target;

@end
