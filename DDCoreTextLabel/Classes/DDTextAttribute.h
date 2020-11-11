//
//  DDTextAttribute.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - 给字符串添加的自定义属性 key
UIKIT_EXTERN NSString *const DDTextAttachmentAttributeName;//添加附件
UIKIT_EXTERN NSString *const DDTextHighlightAttributeName;//添加高亮


UIKIT_EXTERN NSString *const DDTextTruncationToken;//折行显示什么


/**  定义 富文本 多少秒后属于长按事件 */
#define ddText_kLongPressMinimumDuration 0.5f

/** 高亮状态的被点击时 文字 选中时的 位置 与高宽类型 */
typedef NS_ENUM(NSUInteger, DDTextHighLightTextSelectedRangeType) {
    DDTextHighLightTextSelectedRangeNormal,          //只选中标记的文字部分,连接 姓名 标签 等等,优先级第一
    DDTextHighLightTextSelectedRangeWholeText,       //选中标记的文字部分及其中间和最后一行空白处，优先级第二
    DDTextHighLightTextSelectedRangeWholeView,       //整个富文本绘制view 的 frame，优先级第四
    DDTextHighLightTextSelectedRangeViewXAndWidth,   //使用富文本绘制view x 和 width，用于处理 整行多行，优先级第三
};

/** 高亮的点击事件 */
typedef NS_ENUM(NSUInteger, DDTextHighLightGestureType) {
    DDTextHighLightGestureTypeSingleClick,//单点
    DDTextHighLightGestureTypeLongPressClick,//长按
    DDTextHighLightGestureTypeSingleAndLongPressClick,//单点和长按都支持
};

/**
 *  垂直方向对齐方式
 */
typedef NS_ENUM(NSUInteger, DDTextVerticalAlignment) {
    /**
     *  顶部对齐
     */
    DDTextVerticalAlignmentTop,
    /**
     *  居中对齐
     */
    DDTextVerticalAlignmentCenter,
    /**
     *  底部对齐
     */
    DDTextVerticalAlignmentBottom
};

/** 折行类型 */
typedef NS_ENUM (NSUInteger, DDTextTruncationType) {
    // 不需要
    DDTextTruncationTypeNone   = 0,
    DDTextTruncationTypeStart  = 1,//开始的部位
    DDTextTruncationTypeEnd    = 2,//结束的部位
    DDTextTruncationTypeMiddle = 3,//中间这行
};


/** 附件，content 可以是UIImage对象、UIView对象、CALayer对象  */
@interface DDTextAttachment : NSObject<NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,strong) id content;//内容
@property (nonatomic,assign) NSRange range;//在string中的range
@property (nonatomic,assign) CGRect frame;//frame
@property (nonatomic,strong) NSURL* URL;//URL，网页图片链接
@property (nonatomic,assign) UIViewContentMode contentMode;//内容模式
@property (nonatomic,assign) UIEdgeInsets contentEdgeInsets;//边缘内嵌大小
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

/**
 构造方法

 @param content 可以是UIImage对象、UIView对象、CALayer对象。
 @return DDTextAttachment 实例对象
 */
+ (instancetype)attachmentWithContent:(id)content;

@end

/**
 *  高亮点击封装
 */
@interface DDTextHighlight : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) NSInteger tag;//标记
@property (nonatomic,assign) NSInteger row;//第几个
@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* normalColor;//链接的颜色，点击前颜色
@property (nonatomic,strong) UIColor* highlightBackgroundColor;//点击后背景颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;//位置数组CGRect
@property (nonatomic,strong) id content;//一些连接地址等等标签文字
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息
@property (nonatomic,assign) DDTextHighLightTextSelectedRangeType selectedRangeType;//文字 选中时的 位置 与 高宽类型
@property (nonatomic,assign) DDTextHighLightGestureType gestureType;//支持的点击事件回调

@end

