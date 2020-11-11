//
//  DDSentinel.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/17.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 一个自增的标示符，用来取消绘制
 */
@interface DDSentinel : NSObject

/**
 *  标示符值，当两次值不相等时，说明开始了一个新的绘制任务，取消当前的绘制
 *
 *  @return 标示符的值
 */
- (int32_t)value;

/**
 *  表示赋值增加1
 *
 *  @return 增加1后的标示符的值
 */
- (int32_t)increase;

@end
