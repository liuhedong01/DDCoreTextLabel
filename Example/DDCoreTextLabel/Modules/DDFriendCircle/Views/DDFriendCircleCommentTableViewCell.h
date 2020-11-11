//
//  DDFriendCircleCommentTableViewCell.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDFriendCircleCommentLayoutModel.h"

/// 显示评论
@interface DDFriendCircleCommentTableViewCell : UITableViewCell

@property (nonatomic, strong) DDFriendCircleCommentLayoutModel * layoutModel;

/** 是否异步绘制，默认YES */
@property (nonatomic, assign) BOOL displaysAsynchronously;

@property (nonatomic, weak) id<DDFriendCircleDelegate> delegate;

@end

