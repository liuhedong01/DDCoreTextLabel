//
//  DDFriendCircleContentSectionHeaderView.h
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDFriendCircleItemLayoutModel.h"

/// 用于显示 头像、昵称、内容、图片、点赞
@interface DDFriendCircleContentSectionHeaderView : UITableViewHeaderFooterView

/** 网络动态 -- 布局模型 */
@property (nonatomic, strong) DDFriendCircleItemLayoutModel * layoutModel;

/** 是否异步绘制，默认YES */
@property (nonatomic, assign) BOOL displaysAsynchronously;

@property (nonatomic, weak) id<DDFriendCircleDelegate> delegate;

@property (nonatomic, weak) UIViewController * superViewController;


@end

