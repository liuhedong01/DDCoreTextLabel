//
//  DDFriendCircleCommentTableViewCell.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleCommentTableViewCell.h"

@interface DDFriendCircleCommentTableViewCell ()

/** 姓名 */
@property (nonatomic, strong) DDCoreTextLabel * commentLabel;

/** 记录当前要复制的文字 */
@property (nonatomic, copy) NSString * recordCopyText;

@end

@implementation DDFriendCircleCommentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __configUI];
    }
    return self;
}

- (void)__configUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.commentLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__receiveClearHighlight:) name:DDFriendCircleClearHighlight object:nil];
}

- (void)__receiveClearHighlight:(NSNotification *)nf
{
    id objc = nf.object;
    [self removeHighlight:objc];
    if (objc && ![objc isKindOfClass:[DDCoreTextLabel class]]) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
}

- (void)__deleteCommentClicked
{
    NSLog(@"点击了 删除评论");
}

#pragma mark - 移除高亮状态
- (void)removeHighlight:(id)label
{
    if (label != self.commentLabel)  [self.commentLabel clearHighlight];
}

#pragma mark - 处理富文本单点处理
- (void)_handleCoreTextSingleTapClickedWithHighlight:(DDTextHighlight *)highlight
{
    if (highlight.tag == DD_FriendCircle_TextHighlightPhoneNumberClickedTag) {
        //手机号
        
        NSLog(@"点击了手机号: %@",highlight.content);

    } else if (highlight.tag == DD_FriendCircle_TextHighlightLinkClickedTag) {
//        //连接
        NSLog(@"点击了连接: %@", highlight.content);
        
    } else if (highlight.tag == DD_FriendCircle_TextHighlightUserClickedTag) {
        //用户信息点击了
        NSLog(@"用户信息点击了: %@", highlight.content);

    } else if (highlight.tag == DD_FriendCircle_TextHighlightCommentClickedTag) {
        if ([self.delegate respondsToSelector:@selector(dd_friendCircleCellClickedCommentSection:row:)]) {
            [self.delegate dd_friendCircleCellClickedCommentSection:self.layoutModel.section row:self.layoutModel.row];
        }
    }
}

#pragma mark - 展示 复制
- (void)_showCopyMenuItemWithHighlight:(DDTextHighlight *)highlight label:(DDCoreTextLabel *)label
{
    CGRect frame = [self __getCopyMenuItemFrameWithPositions:highlight.positions];
    
    if (highlight.selectedRangeType == DDTextHighLightTextSelectedRangeWholeView) {
        frame = self.commentLabel.bounds;
    }
    
    frame = [label convertRect:frame toView:self];
    self.recordCopyText = highlight.content;
    [self _showCopyMenuItemWithFrame:frame highlight:highlight];
}

#pragma mark - 弹出复制 menu
- (void)_showCopyMenuItemWithFrame:(CGRect)frame highlight:(DDTextHighlight *)highlight
{
    [self becomeFirstResponder];
    
    CGRect resultRect = [self convertRect:frame toView:[UIApplication sharedApplication].delegate.window];
    UIMenuControllerArrowDirection arrowDirection = UIMenuControllerArrowDown;
    if (resultRect.origin.y < [[UIApplication sharedApplication] statusBarFrame].size.height + 20 + 50) {
        arrowDirection = UIMenuControllerArrowUp;
    }
    
    UIMenuItem* copyLink = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                      action:@selector(__menuItemCopyText)];
    
    NSArray * menuItems = @[copyLink];
    
    if (highlight.tag == DD_FriendCircle_TextHighlightCommentClickedTag)
    {
        BOOL needShowDelete = arc4random()%3;
        if (needShowDelete) {
            UIMenuItem* deleteLink = [[UIMenuItem alloc] initWithTitle:@"删除"
                                                                action:@selector(__deleteCommentClicked)];
            
            menuItems = @[copyLink,deleteLink];
        }
    }
    
    [[UIMenuController sharedMenuController] setMenuItems:menuItems];
    [UIMenuController sharedMenuController].arrowDirection = arrowDirection;
    [[UIMenuController sharedMenuController] setTargetRect:frame inView:self];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

- (CGRect)__getCopyMenuItemFrameWithPositions:(NSArray <NSValue *> *)positions
{
    __block CGRect resultRect =CGRectMake(0, 0, 0, 0);
    [positions enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rRect = [obj CGRectValue];
        if (idx == 0) {
            resultRect = rRect;
        } else {
            resultRect = CGRectUnion(resultRect, rRect);
        }
    }];
    return resultRect;
}

#pragma mark - 复制文字
- (void)__menuItemCopyText
{
    if (self.recordCopyText) {
        UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
        

        pasteboard.string = self.recordCopyText;
    }
    self.recordCopyText = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:nil];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action == @selector(__menuItemCopyText)){
        return YES;
    }
    if(action == @selector(__deleteCommentClicked)){
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)setLayoutModel:(DDFriendCircleCommentLayoutModel *)layoutModel
{
    _layoutModel = layoutModel;
    self.commentLabel.textLayout = layoutModel.commentLayout;
    self.commentLabel.frame = layoutModel.commentFrame;
}

#pragma mark - 设置是否异步绘制
- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously
{
    if (_displaysAsynchronously != displaysAsynchronously) {
        _displaysAsynchronously = displaysAsynchronously;
        self.commentLabel.displaysAsynchronously = displaysAsynchronously;
    }
}

#pragma mark - 懒加载 数据初始化
- (DDCoreTextLabel *)commentLabel
{
    if (!_commentLabel) {
        _commentLabel = [[DDCoreTextLabel alloc] init];
        _commentLabel.backgroundColor = dd_ColorHex(F3F3F5);
        __weak typeof(self) weakSelf = self;
        _commentLabel.highlightTapAndLongPressAction = ^(DDCoreTextLabel *label, DDTextHighlight *highlight, BOOL isLongPress) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:label];
            if (isLongPress) {
                /** 长按复制 */
                [strongSelf _showCopyMenuItemWithHighlight:highlight label:label];
            } else {
                //单点
                [strongSelf _handleCoreTextSingleTapClickedWithHighlight:highlight];
            }
        };
    }
    return _commentLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
