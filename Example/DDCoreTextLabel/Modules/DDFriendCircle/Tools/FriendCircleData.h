//
//  FriendCircleData.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/30.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendCircleData : NSObject

/** 名字 */
+ (NSArray *)namesArray;

/** 内容数组 */
+ (NSArray *)contentArray;

/** 图片数组 */
+ (NSArray *)imageUrlArray;

/** 时间数组 */
+ (NSArray *)timeArray;

/** 评论内容数组 */
+ (NSArray *)commentContentArray;

/** 随机名字 */
+ (NSString *)randomName;
/** 随机内容 */
+ (NSString *)randomContent;
/** 随机图片地址 */
+ (NSString *)randomImageUrl;
/** 随机时间 */
+ (NSString *)randomTime;
/** 随机评论内容 */
+ (NSString *)randomCommentContent;

/** 随机数 */
+ (NSInteger)randomMin;

/** 随机数 */
+ (NSInteger)random;

@end
