//
//  DDFriendCircleViewController+Data.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleViewController+Data.h"

@implementation DDFriendCircleViewController (Data)


#pragma mark - 数据源 数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DDFriendCircleItemLayoutModel * layoutModel = self.dataArray[section];
    
    return layoutModel.commentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    DDFriendCircleItemLayoutModel * layoutModel = self.dataArray[section];

    return layoutModel.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return DDFriendCircle_space_16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDFriendCircleItemLayoutModel * layoutModel = self.dataArray[indexPath.section];
    
    DDFriendCircleCommentLayoutModel * commentLayoutModel = layoutModel.commentArray[indexPath.row];
    return commentLayoutModel.height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DDFriendCircleContentSectionHeaderView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDFriendCircleContentSectionHeaderView"];
    headerView.superViewController = self;
    headerView.delegate = self;
    
    headerView.displaysAsynchronously = self.displaysAsynchronously;
    
    DDFriendCircleItemLayoutModel * layoutModel = self.dataArray[section];
    
    headerView.layoutModel = layoutModel;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDFriendCircleCommentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDFriendCircleCommentTableViewCell" forIndexPath:indexPath];
    
    DDFriendCircleItemLayoutModel * layoutModel = self.dataArray[indexPath.section];
    
    DDFriendCircleCommentLayoutModel * commentLayoutModel = layoutModel.commentArray[indexPath.row];

    cell.delegate = self;
    
    cell.displaysAsynchronously = self.displaysAsynchronously;
    cell.layoutModel = commentLayoutModel;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    DDFriendCircleSectionFooterLineView * footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDFriendCircleSectionFooterLineView"];
    return footerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:nil];
    }
}

@end
