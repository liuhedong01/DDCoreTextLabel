//
//  DDFriendCircleItemLayoutModel.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDFriendCircleItemModel.h"
#import "DDFriendCircleCommentLayoutModel.h"


@interface DDFriendCircleItemLayoutModel : NSObject

/** 当前数据模型 */
@property (nonatomic, strong) DDFriendCircleItemModel * model;

/** 第几个组 */
@property (nonatomic, assign) NSInteger section;

/** 名字 */
@property (nonatomic, strong) DDTextLayout * nameLayout;

/** 内容 */
@property (nonatomic, strong) DDTextLayout * contentLayout;

/** 时间 */
@property (nonatomic, strong) DDTextLayout * timeLayout;

/** 点赞的 */
@property (nonatomic, strong) DDTextLayout * likeLayout;

#pragma mark - 评论相关
@property (nonatomic, strong) NSMutableArray <DDFriendCircleCommentLayoutModel *> * commentArray;

#pragma mark - 坐标计算
/** 名字frame */
@property (nonatomic, assign) CGRect nameFrame;

/** 发布类型frame */
@property (nonatomic, assign) CGRect publishTypeImageViewFrame;

/** 内容frame */
@property (nonatomic, assign) CGRect contentFrame;

/** 全文、收起 frame */
@property (nonatomic, assign) CGRect expandPackUpFrame;



/** 活动参加按钮frame */
@property (nonatomic, assign) CGRect joinButtonFrame;

/** 图片 占用的 frame */
@property (nonatomic, assign) CGRect photoBackgroundFrame;

/** 单个图片 frame 的数组 */
@property (nonatomic, strong) NSMutableArray * photoFrameArray;

/** 时间frame */
@property (nonatomic, assign) CGRect timeFrame;

/** 删除按钮 */
@property (nonatomic, assign) CGRect deleteButtonFrame;

/** 更多操作按钮frame */
@property (nonatomic, assign) CGRect menuButtonFrame;

/** (点赞和评论上面的箭头)箭头frame */
@property (nonatomic, assign) CGRect arrowFrame;

/** 点赞 frame */
@property (nonatomic, assign) CGRect likeFrame;

/** 点赞下面的线，只有当 点赞和评论都存在的时候有 */
@property (nonatomic, assign) CGRect likeBottomLineFrame;

/** 正文默认不展开 */
@property (nonatomic, assign) BOOL expanContentBool;

/** 高度 */
@property (nonatomic, assign) CGFloat height;


+ (DDFriendCircleItemLayoutModel *)layoutWithDynamicModel:(DDFriendCircleItemModel *)model section:(NSInteger)section;

@end

