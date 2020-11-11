//
//  DDFriendCircleItemLayoutModel.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleItemLayoutModel.h"

@implementation DDFriendCircleItemLayoutModel

+ (DDFriendCircleItemLayoutModel *)layoutWithDynamicModel:(DDFriendCircleItemModel *)model section:(NSInteger)section
{
    DDFriendCircleItemLayoutModel * layoutModel = [[DDFriendCircleItemLayoutModel alloc] initWithDynamicModel:model section:section];
    return layoutModel;
}

- (instancetype)initWithDynamicModel:(DDFriendCircleItemModel *)model section:(NSInteger)section
{
    self = [super init];
    if (self) {
        self.model = model;
        self.section = section;
        [self __setup];
    }
    return self;
}

#pragma mark - 初始化
- (void)__setup
{
    [self resetLayout];
    /** 布局评论 */
    [self __layoutComment];
    
    [self __reloadAllCalculateFrame];
}

#pragma mark - 重新计算布局
- (void)resetLayout
{
    /** 名字 */
    [self __layoutNameNick];
    
    /** 内容 */
    [self __layoutContent];
    
    /** 全文(收起) 和 立即参加 */
    [self __layoutExpandPackUpJoinFrame];
    
    /** 图片 */
    [self __layoutPhotoContainer];
        
    /** 时间 */
    [self __layoutTime];
    
    /** 删除按钮 BSHLocalizedString(@"删除", nil) */
    [self __layoutDeleteButton];
    
    /** 点赞 */
    [self __layoutLike];
    
    
}

#pragma mark - 布局评论
- (void)__layoutComment
{
    if (self.commentArray) {
        [self.commentArray removeAllObjects];
    } else {
        self.commentArray = [NSMutableArray array];
    }
    if (self.model.commentArray && self.model.commentArray.count) {
        for (NSInteger i = 0; i < self.model.commentArray.count; i++) {
            DDFriendCircleCommentModel * replyModel = self.model.commentArray[i];
            DDFriendCircleCommentLayoutModel * commentLayoutModel = [DDFriendCircleCommentLayoutModel layoutWithModel:replyModel section:self.section row:i];
            [self.commentArray addObject:commentLayoutModel];
        }
    }
}

#pragma mark - 刷新所有的frame计算
- (void)__reloadAllCalculateFrame
{
    /** 内容 */
    if (self.contentLayout) {
        self.contentFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.nameFrame)+DDFriendCircle_space_7, self.contentLayout.textBoundingSize.width, self.contentLayout.textBoundingSize.height+0.5);
    } else {
        self.contentFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.nameFrame), 0, 0);
    }
    
    /** 全文(收起) 和 立即参加 */
    [self __layoutExpandPackUpJoinFrame];
    
    //全文与收起
    if (!self.model.contentNeedTruncation) {
        //不需要折叠
        self.expandPackUpFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.contentFrame), 0, 0);
    } else {
        self.expandPackUpFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.contentFrame)+DDFriendCircle_space_10, CGRectGetWidth(self.expandPackUpFrame), CGRectGetHeight(self.expandPackUpFrame)+0.5);
    }
    
    
    NSUInteger photosCount = self.model.photoArray.count;
    if (photosCount == 0) {
        self.photoBackgroundFrame = CGRectMake(0, CGRectGetMaxY(self.expandPackUpFrame), 0, 0);
    } else {
        self.photoBackgroundFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.expandPackUpFrame)+DDFriendCircle_space_16, CGRectGetWidth(self.photoBackgroundFrame), CGRectGetHeight(self.photoBackgroundFrame));
    }
    
    //活动参加按钮
    //topicType; //动态类型（0:APP前端发布 1:运营后台官方发布）
    if (CGRectGetWidth(self.joinButtonFrame) && CGRectGetHeight(self.joinButtonFrame)) {
        
        self.joinButtonFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.photoBackgroundFrame)+DDFriendCircle_space_16, CGRectGetWidth(self.joinButtonFrame), CGRectGetHeight(self.joinButtonFrame));

    } else {
        self.joinButtonFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.photoBackgroundFrame), 0, 0);
    }
    
    /** 时间 */
    self.timeFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.joinButtonFrame)+DDFriendCircle_space_16, self.timeLayout.textBoundingSize.width, self.timeLayout.textBoundingSize.height+0.5);
    
    /** 删除按钮 */
    BOOL need = arc4random()%2;
    if (need) {
        self.deleteButtonFrame = CGRectMake(CGRectGetMaxX(self.timeFrame)+DDFriendCircle_space_12, CGRectGetMidY(self.timeFrame)-CGRectGetHeight(self.deleteButtonFrame)/2.0-1, CGRectGetWidth(self.deleteButtonFrame), CGRectGetHeight(self.deleteButtonFrame)+0.5);
    } else {
        self.deleteButtonFrame = CGRectMake(CGRectGetMaxX(self.timeFrame)+DDFriendCircle_space_12, CGRectGetMidY(self.timeFrame)-CGRectGetHeight(self.deleteButtonFrame)/2.0, 0, 0);
    }
    
    /** 更多menu */
    self.menuButtonFrame = CGRectMake(kScreenWidth-DDFriendCircle_space_16-DDFriendCircleMenuButtonWidth, CGRectGetMidY(self.timeFrame)-DDFriendCircleMenuButtonHeight/2.0, DDFriendCircleMenuButtonWidth, DDFriendCircleMenuButtonHeight);
    
    /** 箭头 */
    if ((self.model.praise.count) || (self.model.commentArray.count)) {
        self.arrowFrame = CGRectMake(DDFriendCircle_space_contentLeft+DDFriendCircle_space_10, CGRectGetMaxY(self.timeFrame)+DDFriendCircle_space_8, DDFriendCircleArrowWidth, DDFriendCircleArrowHeight);
    } else {
        self.arrowFrame = CGRectMake(DDFriendCircle_space_contentLeft+DDFriendCircle_space_10, CGRectGetMaxY(self.timeFrame), 0, 0);
    }
    
    /** 点赞 数据处理 */
    if (self.model.praise&&self.model.praise.count) {
        self.likeFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.arrowFrame), self.likeLayout.boundingRect.size.width, self.likeLayout.boundingRect.size.height);
    } else {
        self.likeFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.arrowFrame), 0, 0);
    }
    
    /** 点赞下面的线 */
    if ((self.model.praise.count) && (self.model.commentArray.count)) {
        self.likeBottomLineFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.likeFrame), DDFriendCircle_content_textWidth, 0.5);
    } else {
        self.likeBottomLineFrame = CGRectMake(DDFriendCircle_space_contentLeft, CGRectGetMaxY(self.likeFrame), 0, 0);
    }
    
    /** 计算整体的高度 */
    self.height = CGRectGetMaxY(self.likeBottomLineFrame);
}

#pragma mark - 名字 layout 初始化
- (void)__layoutNameNick
{
    NSString * nickName = self.model.nick;

    nickName = dd_toString(nickName);

    if (nickName.length == 0) {
        nickName = @" ";
    }
    
    NSMutableAttributedString * nameAttributedStr = [[NSMutableAttributedString alloc] initWithString:nickName];
    [nameAttributedStr dd_setFont:[UIFont boldSystemFontOfSize:16]];
    [nameAttributedStr dd_setTextColor:dd_ColorHex(506590)];
    
    DDTextHighlight * highlight = [nameAttributedStr dd_addHighlightWithContent:nickName range:[nameAttributedStr dd_rangeOfAll] normalColor:nil highlightBackgroundColor:dd_ColorHex(E0E0E0)];
    highlight.tag = DD_FriendCircle_TextHighlightUserClickedTag;
    /** 添加扩展数据 */
    NSDictionary * userInfo = @{@"nickName": nickName};
    highlight.userInfo = @{@"tag":@(DD_FriendCircle_TextHighlightUserClickedTag),@"data":userInfo};
    
    
    DDTextContainer * nameContainer = [DDTextContainer containerWithSize:CGSizeMake(DDFriendCircle_content_textWidth, 100) insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    nameContainer.maxNumberOfLines = 1;
    DDTextLayout * nameLayout = [DDTextLayout layoutWithContainer:nameContainer text:nameAttributedStr];
    
    self.nameLayout = nameLayout;
    
    self.nameFrame = CGRectMake(DDFriendCircle_space_contentLeft, DDFriendCircle_space_16, self.nameLayout.textBoundingSize.width, self.nameLayout.textBoundingSize.height);
    
}

#pragma mark - 内容
- (void)__layoutContent
{
    NSString * content = self.model.text;
    
    if (!content.length) {
        /** 内容为空 */
        self.contentLayout = nil;
        self.contentFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, 0, 0);
        return;
    }
    
    NSMutableAttributedString * contentAttributedStr = [[NSMutableAttributedString alloc] initWithString:content];
    [contentAttributedStr dd_setFont:[UIFont systemFontOfSize:16]];
    [contentAttributedStr dd_setTextColor:dd_ColorHex(333333)];
    [contentAttributedStr dd_setLineSpacing:3];
    [contentAttributedStr dd_setLineBreakMode:NSLineBreakByWordWrapping];
    
    /** 整体添加高亮点击效果 */
    [contentAttributedStr dd_addHighlightWithContent:content range:[contentAttributedStr dd_rangeOfAll] normalColor:nil highlightBackgroundColor:dd_ColorHex(E0E0E0) selectedRangeType:DDTextHighLightTextSelectedRangeWholeView gestureType:DDTextHighLightGestureTypeLongPressClick userInfo:nil];
    
    /** 正则一下 手机号 和 链接地址 */
    [DDFriendCircleUtils checkPhoneAndLinkAddHighlight:contentAttributedStr range:contentAttributedStr.dd_rangeOfAll highlightBackgroundColor:dd_ColorHex(CCD0D9)];
    
#pragma mark --- ---- ---- -------
    
    DDTextContainer * contentContainer = [DDTextContainer containerWithSize:CGSizeMake(DDFriendCircle_content_textWidth, 100) insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    contentContainer.maxNumberOfLines = DDFriendCircleContentMaxNumberOfLines;
    
    DDTextLayout * contentLayout = [DDTextLayout layoutWithContainer:contentContainer text:contentAttributedStr];
    
    self.model.contentNeedTruncation = contentLayout.needTruncation;
    
    if (contentLayout.needTruncation && self.expanContentBool) {
        /** 需要折叠 , 大于最大行， 目前是要显示展开的情况，需要重新计算 全文的情况 */
        contentContainer.maxNumberOfLines = 0;
        contentLayout = [DDTextLayout layoutWithContainer:contentContainer text:contentAttributedStr];
    }
    
    self.contentLayout = nil;
    self.contentLayout = contentLayout;

    self.contentFrame = CGRectMake(DDFriendCircle_space_contentLeft,0, self.contentLayout.textBoundingSize.width, self.contentLayout.textBoundingSize.height);
    
}

#pragma mark - 计算全文 , 必须放在内容之后
- (void)__layoutExpandPackUpJoinFrame
{
    
    if (!self.model.contentNeedTruncation) {
        //不需要折行
        self.expandPackUpFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, 0, 0);
    } else {
        NSString * expandPackUpString = self.model.expanContentBool?@"收起":@"全文";
        
        UIFont * font = [UIFont systemFontOfSize:16];
        CGSize textSize = [DDFriendCircleUtils returnSizeWithText:expandPackUpString font:font height:font.lineHeight];
        
        self.expandPackUpFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, textSize.width+2, textSize.height);
    }
    
}

#pragma mark - 图片布局
- (void)__layoutPhotoContainer
{
    NSUInteger photosCount = self.model.photoArray.count;
    
    if (photosCount == 0) {
        self.photoBackgroundFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, 0, 0);
        return;
    }
    
    CGFloat pictureItemWH = [UIScreen mainScreen].bounds.size.width<=320? 70.0f:86.0f;
    
    NSUInteger maxCols = photosCount == 4 ? 2:3;
    
    // 总列数
    NSUInteger totalCols = photosCount >= maxCols ?  maxCols : photosCount;
    
    // 总行数
    NSUInteger totalRows = (photosCount + maxCols - 1) / maxCols;
    
    if (self.photoFrameArray) {
        [self.photoFrameArray removeAllObjects];
    } else {
        self.photoFrameArray = [NSMutableArray array];
    }
    
    for (NSInteger i = 0; i < photosCount; i++) {
        CGFloat x = (i % maxCols) * (pictureItemWH + DDFriendCircle_space_5);
        CGFloat y = (i / maxCols) * (pictureItemWH + DDFriendCircle_space_5);
        CGRect frame = CGRectMake(x, y, pictureItemWH, pictureItemWH);
        [self.photoFrameArray addObject:[NSValue valueWithCGRect:frame]];
    }
    
    // 计算尺寸
    CGFloat photosW = totalCols * pictureItemWH + (totalCols - 1) * DDFriendCircle_space_5;
    CGFloat photosH = totalRows * pictureItemWH + (totalRows - 1) * DDFriendCircle_space_5;
    
        
    self.photoBackgroundFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, photosW, photosH);
    
}

#pragma mark - 布局时间
- (void)__layoutTime
{
    NSString * timeShowString = dd_toString(self.model.time);
        
    
    NSMutableAttributedString * timeAttributedStr = [[NSMutableAttributedString alloc] initWithString:timeShowString];
    [timeAttributedStr dd_setFont:[UIFont systemFontOfSize:14]];
    [timeAttributedStr dd_setTextColor:dd_ColorHex(737373)];
    
    DDTextContainer * timeContainer = [DDTextContainer containerWithSize:CGSizeMake(DDFriendCircle_content_textWidth, 100) insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    timeContainer.maxNumberOfLines = 1;
    DDTextLayout * timeLayout = [DDTextLayout layoutWithContainer:timeContainer text:timeAttributedStr];
    
    self.timeLayout = timeLayout;
    
    self.timeFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, self.timeLayout.textBoundingSize.width, self.timeLayout.textBoundingSize.height);
    
}

/// 刷新时间数据
- (void)reloadTimeData
{
    [self __layoutTime];
    [self __reloadAllCalculateFrame];
}

#pragma mark - 删除按钮
- (void)__layoutDeleteButton
{
    NSString * deleteStr = @"删除";
    
    UIFont * font = [UIFont systemFontOfSize:12];
    CGSize textSize = [DDFriendCircleUtils returnSizeWithText:deleteStr font:font height:font.lineHeight];
    
    self.deleteButtonFrame = CGRectMake(0, 0, textSize.width+3, textSize.height+2);
}

#pragma mark - 布局点赞
- (void)__layoutLike
{
    if (self.model.praise.count == 0) {
        self.likeFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, 0, 0);
    } else {
        
        NSMutableAttributedString * likeAttributedString = [[NSMutableAttributedString alloc] init];
        
        UIFont * font = [UIFont systemFontOfSize:14];
        
        //添加 ❤️
        UIImage *  heartImage = [UIImage imageNamed:@"wx_albumInformationLikeHL_15x15"];
        heartImage = [UIImage imageWithCGImage:heartImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        NSMutableAttributedString * heartImgStr = [NSMutableAttributedString dd_attachmentStringWithContent:heartImage contentMode:UIViewContentModeCenter attachmentSize:heartImage.size alignToFont:font alignment:DDTextVerticalAlignmentCenter];
        
        [likeAttributedString appendAttributedString:heartImgStr];
        
        // 拼接一个空格
        NSMutableAttributedString *marginAttr = [[NSMutableAttributedString alloc] initWithString:@"  "];
        [likeAttributedString appendAttributedString:marginAttr];
        
        for (DDFriendCircleLikeModel * likeModel in self.model.praise) {
                        
            NSString * nickName = dd_toString(likeModel.nick);
                        
            NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@，", nickName]];
            [nameAttStr dd_setFont:[UIFont systemFontOfSize:14]];
            [nameAttStr dd_setTextColor:dd_ColorHex(151515)];
            
            
            //设置高亮
            NSRange range = NSMakeRange(likeAttributedString.length ,nickName.length);
            
            [likeAttributedString appendAttributedString:nameAttStr];
            
            DDTextHighlight * likeHighlight = [[DDTextHighlight alloc] init];
            likeHighlight.normalColor = dd_ColorHex(576B95);
            likeHighlight.content = nickName;
            likeHighlight.highlightBackgroundColor = dd_ColorHex(CCD0D9);
            likeHighlight.tag = DD_FriendCircle_TextHighlightUserClickedTag;
            
            /** 添加扩展数据 */
            
            NSDictionary * userInfoData = @{@"nickName": nickName};
            
            likeHighlight.userInfo = @{@"tag":@(DD_FriendCircle_TextHighlightUserClickedTag),@"data":userInfoData};
            
            [likeAttributedString dd_setTextHighlight:likeHighlight range:range];
            
            
        }
        
        // 去掉最后一个 ，
        [likeAttributedString deleteCharactersInRange:NSMakeRange(likeAttributedString.length-1, 1)];
        
        [likeAttributedString dd_setLineSpacing:3];
        
        DDTextContainer * likeContainer = [DDTextContainer containerWithSize:CGSizeMake(DDFriendCircle_content_textWidth, 100) insets:UIEdgeInsetsMake(DDFriendCircle_space_5, DDFriendCircle_space_10, DDFriendCircle_space_5, DDFriendCircle_space_10)];
        DDTextLayout * likeLayout = [DDTextLayout layoutWithContainer:likeContainer text:likeAttributedString];
        self.likeLayout = likeLayout;
        
        self.likeFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, self.likeLayout.boundingRect.size.width, self.likeLayout.boundingRect.size.height);
        
    }
}


#pragma mark - 折叠处理
- (void)setExpanContentBool:(BOOL)expanContentBool
{
    self.model.expanContentBool = expanContentBool;
    [self __layoutContent];
    [self __reloadAllCalculateFrame];
}

- (BOOL)expanContentBool
{
    return self.model.expanContentBool;
}

/** 重新刷新点赞数据 */
- (void)reloadLikePraiseData
{
    [self __layoutLike];
    [self __reloadAllCalculateFrame];
}

/** 重新刷新坐标 */
- (void)reloadAllCalculateFrame
{
    [self __reloadAllCalculateFrame];
}
/** 刷新评论数据 */
- (void)reloadCommentRowData
{
    [self.commentArray enumerateObjectsUsingBlock:^(DDFriendCircleCommentLayoutModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.row = idx;
    }];
    [self __reloadAllCalculateFrame];
}

/** section 改变了，刷新下对应的数据 */
- (void)reloadDataSectionChange
{
    
    [self.commentArray enumerateObjectsUsingBlock:^(DDFriendCircleCommentLayoutModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.section = self.section;
    }];
//    [self __reloadAllCalculateFrame];
}


#pragma mark - 懒加载
- (NSMutableArray<DDFriendCircleCommentLayoutModel *> *)commentArray
{
    if (!_commentArray) {
        _commentArray = [NSMutableArray array];
    }
    return _commentArray;
}

@end
