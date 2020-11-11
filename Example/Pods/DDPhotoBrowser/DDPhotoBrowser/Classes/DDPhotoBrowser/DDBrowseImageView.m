//
//  DDBrowseImageView.m
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import "DDBrowseImageView.h"

@interface DDBrowseImageView () 

/**最多缩放比例*/
@property (nonatomic,assign) CGFloat kMaximumZoomScale;

/**  获取图片 */
@property (nonatomic, strong) id<DDGetImageViewEngine> getImageViewEngine;

@end

@implementation DDBrowseImageView


- (instancetype)init {
    NSAssert(NO, @"Use initWithFrame:imageViewEngineType instead.");
    return nil;
}

- (instancetype)initWithFrame {
    NSAssert(NO, @"Use initWithFrame:imageViewEngineType instead.");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
           getImageViewEngine:(id<DDGetImageViewEngine>)getImageViewEngine
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.getImageViewEngine = getImageViewEngine;
        
        [self __setupPhotoImageView];
        
    }
    return self;
}

- (void)setupPhotoImageView
{
}

#pragma mark - 初始化基础数据
- (void)__setupPhotoImageView
{
    self.kMaximumZoomScale = 3.0;
    
    [self addSubview:self.scrollView];
    
    _imageView = [self.getImageViewEngine getImageViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.hidden = YES;
    [self.scrollView addSubview:_imageView];
    

    [self __addGestureRecognizers];
    
    self.userInteractionEnabled = NO;

    [self setupPhotoImageView];
    
}

#pragma mark - 移除所有的手势
- (void)removeAllGestureRecognizers
{
    self.scrollView.delegate = nil;
    
    self.userInteractionEnabled = NO;
    
    if (self.doubleGestureRecognizer) {
        [self.doubleGestureRecognizer removeTarget:self action:@selector(__doubleHandler:)];
    }
    
    if (self.singleTapGestureRecognizer) {
        [self.singleTapGestureRecognizer removeTarget:self action:@selector(__singleTapGestureClicked)];
    }
    
    if (self.longPressGestureRecognizer) {
        [self.longPressGestureRecognizer removeTarget:self action:@selector(__longPressGestureClicked:)];
    }
    
}

#pragma mark - 添加手势
- (void)__addGestureRecognizers
{
    ////////  添加双击手势
    self.doubleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__doubleHandler:)];
    self.doubleGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.doubleGestureRecognizer];
    
    ////////  添加单机手势
    self.singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__singleTapGestureClicked)];
    self.singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:self.singleTapGestureRecognizer];
    
    ////////  添加长按手势
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__longPressGestureClicked:)];
    [self addGestureRecognizer:self.longPressGestureRecognizer];

    
    [self.singleTapGestureRecognizer  requireGestureRecognizerToFail:self.doubleGestureRecognizer];

    
}

#pragma mark - 双击手势响应事件
- (void)__doubleHandler:(UITapGestureRecognizer *)recognizer
{
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale)
    {
        
        CGPoint selfTouchPoint = [recognizer locationInView:self];
        
        if (!CGRectContainsPoint(self.imageView.frame, selfTouchPoint)) {
            
            return;
        }
        
        self.singleTapGestureRecognizer.enabled = NO;
                
        CGPoint touchPoint = [recognizer locationInView:self.imageView];

        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        
        CGFloat xsize = self.scrollView.bounds.size.width / newZoomScale;
        CGFloat ysize = self.scrollView.bounds.size.height / newZoomScale;
        
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        
    }
    else
    {
        self.singleTapGestureRecognizer.enabled = NO;
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.singleTapGestureRecognizer.enabled = YES;
    });
}

#pragma mark - 单击手势响应事件
- (void)__singleTapGestureClicked
{
    if (self.singleTapGestureClickedBlock) {
        self.singleTapGestureClickedBlock();
    }
}

#pragma mark - 长按手势响应事件
- (void)__longPressGestureClicked:(UILongPressGestureRecognizer *)longGesture
{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        if (self.longPressGestureClickedBlock) {
            NSData * imageData = [self.getImageViewEngine getImageData];
            self.longPressGestureClickedBlock(imageData);
        }
    }
}


#pragma mark - 改变图片大小
- (void)resizeImageView
{
    _imageView.hidden = YES;
    if (_imageView.image) {
        
        CGSize imageSize = _imageView.image.size;
        CGFloat width = _imageView.frame.size.width;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        _imageView.frame = rect;
        // If image is very high, show top content.
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
    } else {
        
        CGFloat width = self.frame.size.width;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
    }
    
    _imageView.hidden = NO;
    self.scrollView.contentSize = _imageView.frame.size;
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    self.scrollView.maximumZoomScale = self.kMaximumZoomScale;
    [self setNeedsLayout];
    
    self.userInteractionEnabled = YES;
    
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale
{
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
}

#pragma mark - ScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _imageView.center = [self centerInScrollView:scrollView];
}

#pragma mark - imageview的center
- (CGPoint)centerInScrollView:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = self.kMaximumZoomScale;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.delaysContentTouches = NO;
        _scrollView.alwaysBounceVertical = YES;//设置上下回弹
        _scrollView.clipsToBounds = YES;
        
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return _scrollView;
}

- (void)dealloc
{
    NSLog(@"dealloc：%@",NSStringFromClass([self class]));
    //删除通知
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
