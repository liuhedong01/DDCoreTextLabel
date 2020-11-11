//
//  DDFriendCircleSectionFooterLineView.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCircleSectionFooterLineView.h"

@interface DDFriendCircleSectionFooterLineView ()

@property (nonatomic, strong) CALayer * bottomLineLayer;

@end

@implementation DDFriendCircleSectionFooterLineView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self __configUI];
    }
    return self;
}

#pragma mark - 布局
- (void)__configUI
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView.layer addSublayer:self.bottomLineLayer];
    self.bottomLineLayer.frame = CGRectMake(0, 16-0.5, CGRectGetWidth(self.bounds), 0.5);
}

#pragma mark - 懒加载 初始化
- (CALayer *)bottomLineLayer
{
    if (!_bottomLineLayer) {
        _bottomLineLayer = [CALayer layer];
        _bottomLineLayer.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
    }
    return _bottomLineLayer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
