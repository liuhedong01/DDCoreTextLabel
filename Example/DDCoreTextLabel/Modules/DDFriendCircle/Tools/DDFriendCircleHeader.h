//
//  DDFriendCircleHeader.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDFriendCircleUtils.h"


/** 最多显示的图片数 */
FOUNDATION_EXTERN NSUInteger const DDFriendCirclePhotosMaxCount;

FOUNDATION_EXTERN NSUInteger const DDFriendCircleContentMaxNumberOfLines;

/** 朋友圈头像宽度和高度 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleAvatarWH;

/** 朋友圈单个图片的宽和高 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleSingleImageWH;

/** 朋友圈图片最大宽度 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleSingleImageMaxWidth;

/** 朋友圈图片最大高度 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleSingleImageMaxHeight;



/**  箭头 宽度 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleArrowWidth;

/**  箭头 高度 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleArrowHeight;

/**  菜单按钮 宽度 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleMenuButtonWidth;

/**  菜单按钮 高度 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleMenuButtonHeight;


#pragma mark - 单个动态详情
/** 单个动态详情，评论的头像宽和高 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleDetailCommentAvatarWH;

/** 动态详情，点赞一排 显示几个 */
FOUNDATION_EXTERN NSInteger const DDFriendCircleDetailPraiseARowShowCount;



/**  正则表达手机号最大长度 23 */
FOUNDATION_EXTERN CGFloat const DDFriendCircleRegexPhoneNumberMaxLength;

#pragma mark - 一些通知
/** 通知取消对应cell的 高亮状态 */
FOUNDATION_EXTERN NSString * const DDFriendCircleClearHighlight;



#pragma mark - 一些间距定义

/** 间距 16 */
#define DDFriendCircle_space_16 (16)

/** 间距 5 */
#define DDFriendCircle_space_5 (5)

/** 间距 8 */

#define DDFriendCircle_space_7 (7)

/** 间距 8 */
#define DDFriendCircle_space_8 (8)

/** 间距 10 */
#define DDFriendCircle_space_10 (10)

/** 间距 12 */
#define DDFriendCircle_space_12 (12)

/** 间距 12 */
#define DDFriendCircle_space_15 (15)

/** 间距 20 */
#define DDFriendCircle_space_20 (20)

/** 间距 25 */
#define DDFriendCircle_space_25 (25)

/** 内容左边边距，除了头像 */
#define DDFriendCircle_space_contentLeft (DDFriendCircle_space_16+DDFriendCircle_space_10+DDFriendCircleAvatarWH)

/** 内容文字的宽度 */
#define DDFriendCircle_content_textWidth (kScreenWidth - DDFriendCircle_space_contentLeft - DDFriendCircle_space_16)

#pragma mark - 点击事件定义

/** 高亮状态点击类型，100 代表点击了手机号 */
#define DD_FriendCircle_TextHighlightPhoneNumberClickedTag       100

/** 高亮状态点击类型，101 代表点击了连接 */
#define DD_FriendCircle_TextHighlightLinkClickedTag              101

/** 高亮状态点击类型，102 代表点击了用户 */
#define DD_FriendCircle_TextHighlightUserClickedTag              102

/** 高亮状态点击类型，103 代表点击了评论 */
#define DD_FriendCircle_TextHighlightCommentClickedTag           103

@protocol DDFriendCircleDelegate  <NSObject>

@optional

/** 点击了 全文收起  */
- (void)dd_friendCircleClickedExpandPackUp:(BOOL)expand section:(NSInteger)section;

/** 点击了 单个评论, row == -1 代表整个动态评论 */
- (void)dd_friendCircleCellClickedCommentSection:(NSInteger)section row:(NSInteger)row;

@end

