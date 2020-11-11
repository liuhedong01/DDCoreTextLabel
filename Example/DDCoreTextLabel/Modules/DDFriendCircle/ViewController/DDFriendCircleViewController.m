//
//  DDFriendCircleViewController.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/18.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDFriendCircleViewController.h"
#import "DDFriendCircleViewController+Data.h"
#import "FriendCircleData.h"

@interface DDFriendCircleViewController ()

@end

@implementation DDFriendCircleViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.displaysAsynchronously = YES;
    
    [self __configUI];
    
    
    [self _reqeustData];

}

/** 点击了 全文收起  */
- (void)dd_friendCircleClickedExpandPackUp:(BOOL)expand section:(NSInteger)section
{
    DDFriendCircleItemLayoutModel * layoutModel = self.dataArray[section];
    layoutModel.expanContentBool = expand;
    [self _reloadDataWithSection:section];
}



/** 点击了 单个评论, row == -1 代表整个动态评论 */
- (void)dd_friendCircleCellClickedCommentSection:(NSInteger)section row:(NSInteger)row
{
    NSLog(@"需要 评论---？");
}

#pragma mark - 刷新点击事件
- (void)_refreshData
{
    [self _reqeustData];
}

#pragma mark - 请求数据
- (void)_reqeustData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _makeData];
    });
}

#pragma mark - 界面布局
- (void)__configUI
{
    [self.view addSubview:self.tableView];

    CGFloat top = [UIApplication sharedApplication].statusBarFrame.size.height + 20;
    
    self.tableView.frame = CGRectMake(0, top, kScreenWidth, kScreenHeight - top);
    
    [self.tableView registerClass:DDFriendCircleCommentTableViewCell.class forCellReuseIdentifier:@"DDFriendCircleCommentTableViewCell"];
    
    [self.tableView registerClass:DDFriendCircleContentSectionHeaderView.class forHeaderFooterViewReuseIdentifier:@"DDFriendCircleContentSectionHeaderView"];
    
    [self.tableView registerClass:DDFriendCircleSectionFooterLineView.class forHeaderFooterViewReuseIdentifier:@"DDFriendCircleSectionFooterLineView"];

    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(_refreshData)];
    self.navigationItem.leftBarButtonItem = item;
        
}

#pragma mark - 刷新数据
- (void)_reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)_reloadDataWithSection:(NSInteger)section
{
    if (section >= self.dataArray.count) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.displaysAsynchronously = NO;
        [self.tableView reloadData];
        self.displaysAsynchronously = YES;
    });
}


#pragma mark - 制造假数据
- (void)_makeData
{
    [self.dataArray removeAllObjects];
    
    [self _reloadData];

    for (NSInteger i = 0; i < [FriendCircleData randomMin]; i++) {
        DDFriendCircleItemModel * model = [[DDFriendCircleItemModel alloc] init];
        model.nick = [FriendCircleData randomName];
        model.avatar = [FriendCircleData randomImageUrl];
        model.text = [FriendCircleData randomContent];
        model.time = [FriendCircleData randomTime];
        
        //添加点赞 假数据
        NSMutableArray * likeArray = [NSMutableArray array];
        for (NSInteger i = 0; i < [FriendCircleData random]; i++) {
            DDFriendCircleLikeModel * like = [[DDFriendCircleLikeModel alloc] init];
            like.nick = [FriendCircleData randomName];
            [likeArray addObject:like];
        }
        model.praise = likeArray.copy;
        
        //添加评论 假数据
        NSMutableArray * commentArray = [NSMutableArray array];

        for (NSInteger i = 0; i < [FriendCircleData random]; i++) {
            DDFriendCircleCommentModel * comment = [[DDFriendCircleCommentModel alloc] init];
            comment.text = [FriendCircleData randomCommentContent];
            comment.fromNick = [FriendCircleData randomName];
            if (i % 3 == 0) {
                comment.toNick = [FriendCircleData randomName];
            }
            [commentArray addObject:comment];
        }
        
        model.commentArray = commentArray.copy;
        
        int row = arc4random() % 10;
        
        /// 添加图片
        NSMutableArray * photoArray = [NSMutableArray array];
        for (NSInteger i = 0; i < row; i++) {
            [photoArray addObject:[FriendCircleData randomImageUrl]];
        }
        
        model.photoArray = photoArray.copy;
        
        DDFriendCircleItemLayoutModel * layoutModel = [DDFriendCircleItemLayoutModel layoutWithDynamicModel:model section:i];
        [self.dataArray addObject:layoutModel];
    }
    
    [self _reloadData];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
