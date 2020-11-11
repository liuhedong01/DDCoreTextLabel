//
//  DDFriendCircleCommentLayoutModel.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleCommentLayoutModel.h"

@implementation DDFriendCircleCommentLayoutModel

+ (DDFriendCircleCommentLayoutModel *)layoutWithModel:(DDFriendCircleCommentModel *)model section:(NSInteger)section row:(NSInteger)row
{
    DDFriendCircleCommentLayoutModel * layoutModel = [[DDFriendCircleCommentLayoutModel alloc] initWithModel:model section:section row:row];
    return layoutModel;
}

- (instancetype)initWithModel:(DDFriendCircleCommentModel *)model section:(NSInteger)section row:(NSInteger)row
{
    self = [super init];
    if (self) {
        self.model = model;
        self.section = section;
        self.row = row;
        [self __setup];
    }
    return self;
}

- (void)__setup
{
    CGFloat topEdgeInsets = 5;//顶部偏移量
    CGFloat bottomEdgeInsets = 5;//下面偏移量
    CGFloat leftRightEdgeInsets = 10;//左边和右边偏移量
    CGFloat lineSpacing = 3;
    if (self.row == 0) {
//        topEdgeInsets = BSHFriendCircle_space_10;
    }
    
    NSMutableAttributedString * commentAttr = [[NSMutableAttributedString alloc] init];
    
    NSString * content = self.model.text;
    
    /** 正文 */
    NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"：%@",content]];
    [textAttr dd_setLineBreakMode:NSLineBreakByWordWrapping];
    
    [textAttr dd_setTextColor:dd_ColorHex(151515)];
    [textAttr dd_setFont:[UIFont systemFontOfSize:14]];
    
    NSString * fromeNickName = self.model.fromNick;
        
    /** 拼接姓名 */
    NSMutableAttributedString * fromeAttr =[[NSMutableAttributedString alloc] initWithString:fromeNickName];
    [fromeAttr dd_setTextColor:dd_ColorHex(576B95)];
    [fromeAttr dd_setFont:[UIFont boldSystemFontOfSize:14]];
    
    NSString * replyText = @"回复";
    
    NSString * replyUsernick = self.model.toNick;
    

    
    if (replyUsernick.length) {
        /** 回复谁 */
        
        NSMutableAttributedString * toAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",replyText,replyUsernick]];
        
        [toAttr dd_setTextColor:dd_ColorHex(151515)];
        [toAttr dd_setFont:[UIFont systemFontOfSize:14]];
        
        [toAttr dd_setFont:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(replyText.length, replyUsernick.length)];

        
        [fromeAttr appendAttributedString:toAttr];
    }
    
    [commentAttr appendAttributedString:fromeAttr];
    [commentAttr appendAttributedString:textAttr];
    
    /** 整段添加高亮 */
    DDTextHighlight * textHighlight = [[DDTextHighlight alloc] init];
    textHighlight.normalColor = nil;
    textHighlight.content = content;
    textHighlight.highlightBackgroundColor = dd_ColorHex(CCD0D9);
    textHighlight.tag = DD_FriendCircle_TextHighlightCommentClickedTag;
    textHighlight.selectedRangeType = DDTextHighLightTextSelectedRangeWholeView;
    
    
    /** 添加扩展数据 */
    
    [commentAttr dd_setTextHighlight:textHighlight range:NSMakeRange(0, commentAttr.length)];
    
    /** 谁的评论  添加高亮 */
    DDTextHighlight * fromHighlight = [[DDTextHighlight alloc] init];
    fromHighlight.normalColor = dd_ColorHex(576B95);
    fromHighlight.highlightBackgroundColor = dd_ColorHex(CCD0D9);
    fromHighlight.content  = fromeNickName;
//    fromHighlight.tag = BSH_FriendCircle_TextHighlightUserClickedTag;
    
    /** 添加用户点击扩展信息 */
//    BSHFriendCircleDynamicUserModel * userModel = [[BSHFriendCircleDynamicUserModel alloc] init];
//    userModel.userno = self.model.createUserno;
//    userModel.nickName = fromeNickName;
//    userModel.portraitUrl = self.model.portraitUrl;
//    fromHighlight.userInfo = @{@"tag":@(BSH_FriendCircle_TextHighlightUserClickedTag),@"data":userModel};
    
    [commentAttr dd_setTextHighlight:fromHighlight range:NSMakeRange(0, fromeNickName.length)];
    
    
    
    if (replyUsernick.length) {
        DDTextHighlight * toHighlight = [[DDTextHighlight alloc] init];
        toHighlight.normalColor = dd_ColorHex(576B95);
        toHighlight.highlightBackgroundColor = dd_ColorHex(CCD0D9);
        toHighlight.tag = DD_FriendCircle_TextHighlightUserClickedTag;
        toHighlight.content = replyUsernick;
        /** 添加用户点击扩展信息 */
//        BSHFriendCircleDynamicUserModel * userModel = [[BSHFriendCircleDynamicUserModel alloc] init];
//        userModel.userno = self.model.replyUserno;
//        userModel.nickName = replyUsernick;
//        userModel.portraitUrl = @"";
//
//        toHighlight.userInfo = @{@"tag":@(BSH_FriendCircle_TextHighlightUserClickedTag),@"data":userModel};
        
        
        [commentAttr dd_setTextHighlight:toHighlight range:NSMakeRange([NSString stringWithFormat:@"%@%@",fromeNickName,replyText].length, replyUsernick.length)];
        
        
    }
    /** 正则表达 手机号 和 网址 */
    [DDFriendCircleUtils checkPhoneAndLinkAddHighlight:commentAttr range:NSMakeRange(fromeAttr.length+1, textAttr.length-1) highlightBackgroundColor:dd_ColorHex(CCD0D9)];
    [commentAttr dd_setLineSpacing:lineSpacing];
    
    
    DDTextContainer * commentContainer = [DDTextContainer containerWithSize:CGSizeMake(DDFriendCircle_content_textWidth, 100) insets:UIEdgeInsetsMake(topEdgeInsets, leftRightEdgeInsets, bottomEdgeInsets, leftRightEdgeInsets)];
    
    DDTextLayout * commentLayout = [DDTextLayout layoutWithContainer:commentContainer text:commentAttr];
    
    self.commentLayout = commentLayout;
    
    self.commentFrame = CGRectMake(DDFriendCircle_space_contentLeft, 0, commentLayout.boundingSize.width, commentLayout.boundingSize.height);
    
    
#pragma mark - 优化 高度
    
    self.height = CGRectGetHeight(self.commentFrame);
    
    
}

@end
