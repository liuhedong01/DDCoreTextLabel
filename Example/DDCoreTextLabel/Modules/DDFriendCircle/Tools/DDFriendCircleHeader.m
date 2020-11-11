//
//  DDFriendCircleHeader.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleHeader.h"

/** 最多显示的图片数 */
NSUInteger const DDFriendCirclePhotosMaxCount = 9;

/** 内容最多展示的行数 */
NSUInteger const DDFriendCircleContentMaxNumberOfLines = 6;

/** 朋友圈头像宽度和高度 */
CGFloat const DDFriendCircleAvatarWH = 40.0f;

/** 朋友圈单个图片的宽和高 */
CGFloat const DDFriendCircleSingleImageWH = 78;

/** 朋友圈图片最大宽度 */
CGFloat const DDFriendCircleSingleImageMaxWidth = (78*3+10);

/** 朋友圈图片最大高度 */
CGFloat const DDFriendCircleSingleImageMaxHeight = (78*2+5);

/**  箭头 宽度 */
CGFloat const DDFriendCircleArrowWidth = 12.0f;

/**  箭头 高度 */
CGFloat const DDFriendCircleArrowHeight = 5.0f;

/**  菜单按钮 宽度 */
CGFloat const DDFriendCircleMenuButtonWidth = 16;

/**  菜单按钮 高度 */
CGFloat const DDFriendCircleMenuButtonHeight = 20;

#pragma mark - 单个动态详情
/** 单个动态详情，评论的头像宽和高 */
CGFloat const DDFriendCircleDetailCommentAvatarWH = 36;

/** 动态详情，点赞一排 显示几个 */
NSInteger const DDFriendCircleDetailPraiseARowShowCount = 7;

/**  正则表达手机号最大长度 23 */
CGFloat const DDFriendCircleRegexPhoneNumberMaxLength = 23;

#pragma mark - 一些通知
/** 通知取消对应cell的 高亮状态 */
NSString * const DDFriendCircleClearHighlight = @"DDFriendCircleClearHighlight";

