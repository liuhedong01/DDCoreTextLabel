//
//  DDFriendCircleContentSectionHeaderView.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleContentSectionHeaderView.h"
#import "DDFriendCirclePhotoContainerView.h"
#import "DDSDAnimatedImageView.h"
#import "DDPhotoSDImageDownloadEngine.h"
#import <DDPhotoBrowser/DDPhotoBrowser.h>

@interface DDFriendCircleContentSectionHeaderView ()

/** 头像 */
@property (nonatomic, strong) SDAnimatedImageView * avatarImageView;

/** 姓名 */
@property (nonatomic, strong) DDCoreTextLabel * nameLabel;

/** 内容 */
@property (nonatomic, strong) DDCoreTextLabel * contentLabel;

/** 全文、收起 按钮 */
@property (nonatomic, strong) UIButton * expandPackUpButton;
    
/** 图片容器 */
@property (nonatomic, strong) DDFriendCirclePhotoContainerView * photoContainerView;

/** 时间 */
@property (nonatomic, strong) DDCoreTextLabel * timeLabel;

/** 删除动态按钮 */
@property (nonatomic, strong) UIButton * deleteDynamicButton;

/** 菜单按钮 */
@property (nonatomic, strong) UIButton * menuButton;

/** 向上的箭头 */
@property (nonatomic, strong) UIImageView * arrowImageView;

/** 点赞 */
@property (nonatomic, strong) DDCoreTextLabel * likeLabel;

@property (nonatomic, strong) UIView * likeBottomLineLayer;

/** 记录当前要复制的文字 */
@property (nonatomic, copy) NSString * recordCopyText;

@end


@implementation DDFriendCircleContentSectionHeaderView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self __configUI];
    }
    return self;
}

#pragma mark - 获取头像
- (NSString *)_getPortraitUrl
{
    return dd_toString(self.layoutModel.model.avatar);
}

- (NSString *)_getUserno
{
    NSString * userno = @"";
    return dd_toString(userno);
}

- (NSString *)_getNickName
{
    return dd_toString(self.layoutModel.model.nick);
}

#pragma mark - 头像被点击了
- (void)_avatarImageViewClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:nil];
    
}

#pragma 展开、收起 点击事件
- (void)__expandPackUpButtonClicked
{
    BOOL expanContentBool = NO;
    NSInteger section = 0;
    section = self.layoutModel.section;
    expanContentBool =  self.layoutModel.model.expanContentBool;

    [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:nil];
    
    if ([self.delegate respondsToSelector:@selector(dd_friendCircleClickedExpandPackUp:section:)]) {
        [self.delegate dd_friendCircleClickedExpandPackUp:!expanContentBool section:section];
    }
    
}

#pragma mark - 删除按钮点击了
- (void)__deleteDynamicButtonClicked
{
    NSLog(@"点击了删除按钮");
    [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:nil];
}

#pragma mark - 菜单按钮被点击了
- (void)__menuButtonClicked
{
    NSLog(@"点击了更多菜单");
}

#pragma mark - 处理富文本单点处理
- (void)_handleCoreTextSingleTapClickedWithHighlight:(DDTextHighlight *)highlight
{
    if (highlight.tag == DD_FriendCircle_TextHighlightPhoneNumberClickedTag) {
        //手机号
        NSLog(@"点击了手机号: %@",highlight.content);

    } else if (highlight.tag == DD_FriendCircle_TextHighlightLinkClickedTag) {
        //连接
        NSLog(@"点击了连接: %@", highlight.content);
        
    } else if (highlight.tag == DD_FriendCircle_TextHighlightUserClickedTag) {
        //用户信息点击了
        NSLog(@"用户信息点击了: %@", highlight.content);

    }
}

#pragma mark - 展示 复制
- (void)_showCopyMenuItemWithHighlight:(DDTextHighlight *)highlight label:(DDCoreTextLabel *)label
{
    CGRect frame = [self __getCopyMenuItemFrameWithPositions:highlight.positions];
    
    if (frame.size.width == 0) {
        frame.size.width = label.frame.size.width;
        frame.size.height = CGRectGetHeight(label.bounds);
    }
    frame = [label convertRect:frame toView:self];
    self.recordCopyText = highlight.content;
    [self _showCopyMenuItemWithFrame:frame];
}

#pragma mark - 弹出复制 menu
- (void)_showCopyMenuItemWithFrame:(CGRect)frame
{
    [self becomeFirstResponder];
    
    CGRect resultRect = [self convertRect:frame toView:[UIApplication sharedApplication].delegate.window];
    UIMenuControllerArrowDirection arrowDirection = UIMenuControllerArrowDown;
    if (resultRect.origin.y < [[UIApplication sharedApplication] statusBarFrame].size.height+20 + 50) {
        arrowDirection = UIMenuControllerArrowUp;
    }
    
    UIMenuItem* copyLink = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                      action:@selector(__menuItemCopyText)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
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
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - 图片点击
- (void)_photoImageClickedSelectedRow:(NSInteger)selectedRow
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:nil];
    
    NSMutableArray * itemArray = [NSMutableArray array];

    [self.layoutModel.model.photoArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull urlString, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImageView * imageView = self.photoContainerView.photoViewArray[idx];
        
        DDPhotoItem *item = [DDPhotoItem  itemWithSourceView:imageView imageUrl:[NSURL URLWithString:urlString] thumbImage:nil thumbImageUrl:nil];
        
        if (idx == selectedRow) {
            item.firstShowAnimation = YES;
        }
        
        [itemArray addObject:item];

    }];
    
    
    /// 配置自定义下载
    DDPhotoSDImageDownloadEngine * downloadEngine = [DDPhotoSDImageDownloadEngine new];
    
    /// DDSDAnimatedImageView 配置显示图片 的 view
    
    /** 图片选择器展示*/
    DDPhotoBrowser * b = [DDPhotoBrowser photoBrowserWithPhotoItems:itemArray currentIndex:selectedRow getImageViewClass:DDSDAnimatedImageView.class downloadEngine:downloadEngine];
    
    /** 设置page类型 */
    b.pageIndicateStyle = DDPhotoBrowserPageIndicateStylePageLabel;
    
    b.longPressGestureClickedBlock = ^(DDPhotoBrowser * photoBrowser ,NSInteger index, DDPhotoItem *item,NSData * imageData) {
        NSLog(@"长按手势回调：%ld", index);
    };
        
    [b showFromVC:self.superViewController];
    
}

- (void)__receiveClearHighlight:(NSNotification *)nf
{
    id objc = nf.object;
    [self removeHighlight:objc];
    if (objc && ![objc isKindOfClass:[DDCoreTextLabel class]]) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    if (!objc) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
}

#pragma mark - 移除高亮状态
- (void)removeHighlight:(id)label
{
    if (label != self.nameLabel)  [self.nameLabel clearHighlight];
    if (label != self.contentLabel)  [self.contentLabel clearHighlight];
    if (label != self.timeLabel) [self.timeLabel clearHighlight];
    if (label != self.likeLabel) [self.likeLabel clearHighlight];
}

- (void)setLayoutModel:(DDFriendCircleItemLayoutModel *)layoutModel
{
    _layoutModel = layoutModel;
        
    //头像
    
    [self.avatarImageView dd_setImageWithURL:[NSURL URLWithString:[self _getPortraitUrl]] width:CGRectGetWidth(self.avatarImageView.bounds) height:CGRectGetHeight(self.avatarImageView.bounds) placeholderImage:nil clip:YES];
    
    //姓名
    self.nameLabel.frame = layoutModel.nameFrame;
    self.nameLabel.textLayout = layoutModel.nameLayout;
    
    //内容
    self.contentLabel.frame = layoutModel.contentFrame;
    self.contentLabel.textLayout = layoutModel.contentLayout;
    
    //全文、收起 button
    self.expandPackUpButton.frame = layoutModel.expandPackUpFrame;
    self.expandPackUpButton.selected = layoutModel.expanContentBool;
    

    //图片容器
    self.photoContainerView.frame = layoutModel.photoBackgroundFrame;
    
    [self.photoContainerView bindPhotoFrames:layoutModel.photoFrameArray photoArray:layoutModel.model.photoArray];

    // 时间
    self.timeLabel.frame = layoutModel.timeFrame;
    self.timeLabel.textLayout = layoutModel.timeLayout;
    
    /** 删除按钮 */
    self.deleteDynamicButton.frame = layoutModel.deleteButtonFrame;
    
    // meun，点赞评论按钮
    self.menuButton.frame = layoutModel.menuButtonFrame;
    
    
    // 点赞评论 上面的 箭头
    self.arrowImageView.frame = layoutModel.arrowFrame;
    
    // 点赞
    self.likeLabel.frame = layoutModel.likeFrame;
    self.likeLabel.textLayout = layoutModel.likeLayout;
    
    //点赞下面的线
    self.likeBottomLineLayer.frame = layoutModel.likeBottomLineFrame;

}

#pragma mark - 界面布局
- (void)__configUI
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];

    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.avatarImageView];
    /** 开启异步绘制 */
    self.displaysAsynchronously = YES;
    self.exclusiveTouch = YES;
    
    //头像
    [self.contentView addSubview:self.avatarImageView];
    
    self.avatarImageView.frame = CGRectMake(DDFriendCircle_space_16, DDFriendCircle_space_16, DDFriendCircleAvatarWH, DDFriendCircleAvatarWH);
    
    self.avatarImageView.backgroundColor = dd_ColorHex(DEDEDE);
    
    //姓名
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.backgroundColor = self.contentView.backgroundColor;
    
    //内容
    [self.contentView addSubview:self.contentLabel];
    self.contentLabel.backgroundColor = self.contentView.backgroundColor;
    
    //全文、收起 button
    [self.contentView addSubview:self.expandPackUpButton];
    self.expandPackUpButton.backgroundColor = self.contentView.backgroundColor;

    //图片容器
    [self.contentView addSubview:self.photoContainerView];
    self.photoContainerView.backgroundColor = self.contentView.backgroundColor;
    // 时间
    [self.contentView addSubview:self.timeLabel];
    self.timeLabel.backgroundColor = self.contentView.backgroundColor;
    /** 删除按钮 */
    [self.contentView addSubview:self.deleteDynamicButton];
    self.deleteDynamicButton.backgroundColor = self.contentView.backgroundColor;
    // meun，点赞评论按钮
    [self.contentView addSubview:self.menuButton];
    self.menuButton.backgroundColor = self.contentView.backgroundColor;
    /** 点赞和评论menu */
    
    // 点赞评论 上面的 箭头
    [self.contentView addSubview:self.arrowImageView];
    self.arrowImageView.backgroundColor = self.contentView.backgroundColor;
    // 点赞
    [self.contentView addSubview:self.likeLabel];
    //点赞下面的线
//    [self.contentView.layer addSublayer:self.likeBottomLineLayer];
    [self.contentView addSubview:self.likeBottomLineLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__receiveClearHighlight:) name:DDFriendCircleClearHighlight object:nil];
    
}

#pragma mark - 设置是否异步绘制
- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously
{
    if (_displaysAsynchronously != displaysAsynchronously) {
        _displaysAsynchronously = displaysAsynchronously;
        self.nameLabel.displaysAsynchronously = displaysAsynchronously;
        self.contentLabel.displaysAsynchronously = displaysAsynchronously;
        self.timeLabel.displaysAsynchronously = displaysAsynchronously;
        self.likeLabel.displaysAsynchronously = displaysAsynchronously;
    }
}


#pragma mark - 懒加载
/** 头像 */
- (SDAnimatedImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
        _avatarImageView.runLoopMode = NSDefaultRunLoopMode;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

/** 姓名 */
- (DDCoreTextLabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[DDCoreTextLabel alloc] init];
        __weak typeof(self) weakSelf = self;
        _nameLabel.highlightTapAndLongPressAction = ^(DDCoreTextLabel *label, DDTextHighlight *highlight, BOOL isLongPress) {
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
    return _nameLabel;
}

/** 内容 */
- (DDCoreTextLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[DDCoreTextLabel alloc] init];
        __weak typeof(self) weakSelf = self;
        _contentLabel.highlightTapAndLongPressAction = ^(DDCoreTextLabel *label, DDTextHighlight *highlight, BOOL isLongPress) {
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
    return _contentLabel;
}

/** 全文、收起 按钮 */
- (UIButton *)expandPackUpButton
{
    if (!_expandPackUpButton) {
        _expandPackUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_expandPackUpButton setTitleColor:dd_ColorHex(506590) forState:UIControlStateNormal];
        [_expandPackUpButton setTitle:@"全文" forState:UIControlStateNormal];
        [_expandPackUpButton setTitle:@"收起" forState:UIControlStateSelected];
        
        _expandPackUpButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        
        CGRect rect = CGRectMake(0.0f, 0.0f, 1, 1);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, dd_ColorHex(rCCD0D9).CGColor);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [_expandPackUpButton setBackgroundImage:image forState:UIControlStateHighlighted];
        [_expandPackUpButton addTarget:self action:@selector(__expandPackUpButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _expandPackUpButton;
}

/** 图片容器 */
- (DDFriendCirclePhotoContainerView *)photoContainerView
{
    if (!_photoContainerView) {
        _photoContainerView = [[DDFriendCirclePhotoContainerView alloc] init];
        __weak typeof(self) weakSelf = self;
        _photoContainerView.imageViewClickedBlock = ^(NSInteger selectedRow) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf _photoImageClickedSelectedRow:selectedRow];
        };
    }
    return _photoContainerView;
}

/** 时间 */
- (DDCoreTextLabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[DDCoreTextLabel alloc] init];
    }
    return _timeLabel;
}
/** 删除动态按钮 */
- (UIButton *)deleteDynamicButton
{
    if (!_deleteDynamicButton) {
        _deleteDynamicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteDynamicButton setTitleColor:dd_ColorHex(8696B3) forState:UIControlStateNormal];
        _deleteDynamicButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_deleteDynamicButton setTitle:@"删除" forState:UIControlStateNormal];
        CGRect rect = CGRectMake(0.0f, 0.0f, 1, 1);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, dd_ColorHex(CCD0D9).CGColor);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [_deleteDynamicButton setBackgroundImage:image forState:UIControlStateHighlighted];
        [_deleteDynamicButton addTarget:self action:@selector(__deleteDynamicButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    }
    return _deleteDynamicButton;
}

/** 菜单按钮 */
- (UIButton *)menuButton
{
    if (!_menuButton) {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuButton setImage:[UIImage imageNamed:@"wx_albumOperateMoreHL_25x25"] forState:UIControlStateNormal];
        [_menuButton addTarget:self action:@selector(__menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

/** 向上的箭头 */
- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wx_albumTriangleB_45x6"]];
    }
    return _arrowImageView;
}

/** 点赞 */
- (DDCoreTextLabel *)likeLabel
{
    if (!_likeLabel) {
        _likeLabel = [[DDCoreTextLabel alloc] init];
        _likeLabel.backgroundColor = dd_ColorHex(F3F3F5);
        __weak typeof(self) weakSelf = self;
        _likeLabel.highlightTapAndLongPressAction = ^(DDCoreTextLabel *label, DDTextHighlight *highlight, BOOL isLongPress) {
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
    return _likeLabel;
}

/** 点赞 下面的线 */
- (UIView *)likeBottomLineLayer
{
    if (!_likeBottomLineLayer) {
        _likeBottomLineLayer = [UIView new];
        _likeBottomLineLayer.backgroundColor = dd_ColorHex(E5E5E5);
    }
    return _likeBottomLineLayer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DDFriendCircleClearHighlight object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
