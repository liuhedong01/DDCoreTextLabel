//
//  DDTextRunDelegate.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>


/**
 *  对CTRunDelegateRef的封装
 */
@interface DDTextRunDelegate : NSObject<NSCoding,NSMutableCopying,NSCopying>

- (nullable CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED;//CoreText中的CTRunDelegateRef

@property (nullable,nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息
@property (nonatomic,assign) CGFloat ascent;//上部距离
@property (nonatomic,assign) CGFloat descent;//下部距离
@property (nonatomic,assign) CGFloat width;//宽度
@property (nonatomic,assign) CGFloat height;//高度


@end
