//
//  DDTextContainer.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/16.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DDTextAttribute.h"


@interface DDTextContainer : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic, assign, readonly) CGSize size;//容器的大小
@property (nonatomic, strong, readonly) UIBezierPath* path;//容器的路径
@property (nonatomic, assign, readonly) UIEdgeInsets edgeInsets;//边缘内嵌大小
@property (nonatomic, assign) NSInteger maxNumberOfLines;//最大行数限制
@property (nonatomic, assign) DDTextTruncationType truncationType;//折行类型，默认末尾,DDTextTruncationTypeEnd
@property (nonatomic, copy) NSAttributedString *truncationToken;//默认 ...


/**
 *  构造方法
 *
 *  @param size 容器大小
 *
 *  @return 一个DDTextContainer对象
 */
+ (instancetype)containerWithSize:(CGSize)size;

/**
 *  构造方法
 *
 *  @param size       容器大小
 *  @param insets 边缘内嵌大小
 *
 *  @return 一个DDTextContainer对象
 */
+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets;

/**
 *  容器路径的行宽
 *
 *  @return 路径的行宽
 */
//- (CGFloat)pathLineWidth;

@end
