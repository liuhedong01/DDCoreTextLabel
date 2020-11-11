//
//  DDFriendCircleViewController.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/18.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDFriendCircleBaseViewController.h"

#import "DDFriendCircleContentSectionHeaderView.h"
#import "DDFriendCircleCommentTableViewCell.h"
#import "DDFriendCircleSectionFooterLineView.h"

@interface DDFriendCircleViewController : DDFriendCircleBaseViewController<DDFriendCircleDelegate>

/** 是否异步绘制，默认YES */
@property (nonatomic, assign) BOOL displaysAsynchronously;

@property (nonatomic, strong) NSMutableArray * dataArray;

@end

