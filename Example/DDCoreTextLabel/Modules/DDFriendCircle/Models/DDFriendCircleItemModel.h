//
//  DDFriendCircleItemModel.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleBaseModel.h"


@interface DDFriendCircleCommentModel : DDFriendCircleBaseModel

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *fromNick;
@property (nonatomic, copy) NSString *toNick;

@end

@interface DDFriendCircleLikeModel : DDFriendCircleBaseModel

@property (nonatomic, copy) NSString * nick;//用户昵称

@end


@interface DDFriendCircleItemModel : DDFriendCircleBaseModel

@property (nonatomic, copy) NSString * avatar;//用户头像
@property (nonatomic, copy) NSString * nick;//用户昵称
@property (nonatomic, copy) NSString * text;// 正文
@property (nonatomic, copy) NSString * time;// 正文

@property (nonatomic, copy) NSArray * photoArray;//图片数组

/** 正文默认不展开 */
@property (nonatomic, assign) BOOL expanContentBool;

/** 内容是否折叠 */
@property (nonatomic, assign) BOOL contentNeedTruncation;

/// 评论数组
@property (nonatomic, copy) NSArray<DDFriendCircleCommentModel *>  *commentArray;

/// 点赞数组
@property (nonatomic, copy) NSArray<DDFriendCircleLikeModel *>  *praise;

@end

