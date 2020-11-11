//
//  DDTransaction.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/17.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDTransaction : NSObject

/** object 可以为空 */
+ (DDTransaction *)transactionWithTarget:(id)target
                                selector:(SEL)selector
                                  object:(id)object;

- (void)commit;


@end
