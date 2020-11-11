//
//  DDFriendCirclePhotoContainerView.m
//  DDCoreTextLabel_Example
//
//  Created by 刘和东 on 2020/11/9.
//  Copyright © 2020 liuhedong01@163.com. All rights reserved.
//

#import "DDFriendCirclePhotoContainerView.h"

@implementation DDFriendCirclePhotoContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self __setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __setupUI];
    }
    return self;
}

- (void)__setupUI
{
    self.photoViewArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 9; i++) {
        SDAnimatedImageView * imageView = [[SDAnimatedImageView alloc] init];
        imageView.runLoopMode = NSDefaultRunLoopMode;
        imageView.highlighted = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        imageView.hidden = YES;
        imageView.tag = i;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_imageTagClicked:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
        [self.photoViewArray addObject:imageView];
    }
}

- (void)_imageTagClicked:(UITapGestureRecognizer *)tap
{
    if (self.imageViewClickedBlock) {
        self.imageViewClickedBlock(tap.view.tag);
    }
}

- (void)bindPhotoFrames:(NSArray *)photoFrames photoArray:(NSArray *)photoArray
{
    [self.photoViewArray enumerateObjectsUsingBlock:^(SDAnimatedImageView *  _Nonnull imageView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < photoArray.count) {
            imageView.hidden = NO;
            NSValue * frameValue = photoFrames[idx];
            CGRect frame = [frameValue CGRectValue];

            [imageView dd_setImageWithURL:[NSURL URLWithString:photoArray[idx]] width:CGRectGetWidth(frame) height:CGRectGetHeight(frame) placeholderImage:nil clip:YES];
            
            imageView.frame = frame;
        } else {
            imageView.hidden = YES;
            imageView.image = nil;
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
