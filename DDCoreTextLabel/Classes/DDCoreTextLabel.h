//
//  DDCoreTextLabel.h
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/18.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTextLayout.h"

@interface DDCoreTextLabel : UIView

/** 是否需要异步绘制，默认YES */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/** 异步绘制的线程 */
@property (nonatomic, strong) dispatch_queue_t asyncDisplayQueue;

/** 只有第一个的情况 */
@property (nonatomic, strong) DDTextLayout *textLayout;

/** 高亮状态点击回调 */
@property (nonatomic, copy) void (^highlightTapAndLongPressAction)(DDCoreTextLabel * label,DDTextHighlight * highlight,BOOL isLongPress);


/** 普通的点击回调，高亮状态优先 */
@property (nonatomic, copy) void (^tapAndLongPressAction)(DDCoreTextLabel * label,BOOL isLongPress);

/** 清除 */
- (void)clearHighlight;

@end
