//
//  DDFriendCircleCommentLayoutModel.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDFriendCircleItemModel.h"


@interface DDFriendCircleCommentLayoutModel : NSObject

/** 数据模型 */
@property (nonatomic, strong) DDFriendCircleCommentModel * model;

/** 评论 */
@property (nonatomic, strong) DDTextLayout * commentLayout;

/** 坐标 */
@property (nonatomic, assign) CGRect commentFrame;


/** 第几个组 */
@property (nonatomic, assign) NSInteger section;

/** 第几个 */
@property (nonatomic, assign) NSInteger row;

/** 高度 */
@property (nonatomic, assign) CGFloat height;

+ (DDFriendCircleCommentLayoutModel *)layoutWithModel:(DDFriendCircleCommentModel *)model section:(NSInteger)section row:(NSInteger)row;

@end

