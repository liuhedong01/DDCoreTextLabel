//
//  DDPhotoImageView.m
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import "DDPhotoImageView.h"
#import "DDPhotoLoadingView.h"

@interface DDPhotoImageView ()

@property (nonatomic, assign) NSUInteger numberOfTouches;

/** 拖拽时显示的 imageView  */
@property (nonatomic,strong) UIImageView * panGestureImageView;

@property (nonatomic,strong) DDPhotoLoadingView * loadingView;

@end



@implementation DDPhotoImageView

- (void)setupPhotoImageView
{
    __weak typeof(self) weakSelf = self;
    
    /////  单击 手势点击了
    
    self.singleTapGestureClickedBlock = ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf _dismissView];
        });

    };
    
    [self addSubview:self.loadingView];
    
    self.loadingView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);

    [self.loadingView stopAnimating];
    
    
}

- (void)setItem:(DDPhotoItem *)item
{
    _item = item;
    
    
    [self _loadImageData];
    
}

#pragma mark - 下滑手势处理  核心的 地方 在这下面 代理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.numberOfTouches = scrollView.panGestureRecognizer.numberOfTouches;
    self.scrollView.clipsToBounds = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    if (contentOffsetY < 0 && self.numberOfTouches == 1) {
        
        double percent = 1 - fabs(-contentOffsetY)/(CGRectGetHeight(self.frame)/2.0);
        
        percent = MAX(percent, 0);
        
        double scale = MAX(percent, 0.5);
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        
        self.scrollView.transform = scaleTransform;
        
        self.scrollView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2 + (-contentOffsetY*0.5));
        
        if (self.scrollAnimateBlock) {
            
            self.scrollAnimateBlock(DDPhotoImageScrollAnimateSlidingDownType, scale);
            
        }
        
    }
    
    if (contentOffsetY == 0 && self.numberOfTouches == 1) {
        self.scrollView.transform = CGAffineTransformIdentity;
        self.scrollView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
        self.imageView.center = [self centerInScrollView:scrollView];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.scrollView.transform = CGAffineTransformIdentity;
    self.scrollView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    scrollView.clipsToBounds = YES;
}

//结束拖拽
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    double scale = 1;
    
    if (contentOffsetY < 0 && self.numberOfTouches == 1) {
        
        
        contentOffsetY = - contentOffsetY;
        
        double percent = 1 - fabs(contentOffsetY)/(CGRectGetHeight(self.frame)/2.0);
        
        percent = MAX(percent, 0);
        
        scale = MAX(percent, 0.5);
        
    }
    
    if ((velocity.y <= -0.5 && scrollView.contentOffset.y <= 0) || scale < 0.85 ) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _dismissView];
        });
        
    } else {
        if (self.scrollAnimateBlock) {
            
            self.scrollAnimateBlock(DDPhotoImageScrollAnimateDiscontinueType, 1);
            
        }
    }
    
}

#pragma mark - view  消失
- (void)_dismissView
{
    ///// 移除所有的手势
    [self removeAllGestureRecognizers];
    
    CGRect imageNewRect =  [self.scrollView convertRect:self.imageView.frame toView:self];
    
    [self.imageView removeFromSuperview];
    
    self.imageView.frame = imageNewRect;
    
    [self addSubview:self.imageView];
    
    CGRect dsImageRect = CGRectMake((CGRectGetWidth(self.frame)-CGRectGetWidth(self.imageView.frame))/2.0, CGRectGetHeight(self.frame), CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.imageView.frame));
    // 给一个 初始值
    
    if (self.item.sourceView && self.item.sourceView.hidden == NO) {
        //存在，说明 frame 存在, 而且没有隐藏
        dsImageRect = [self.item.sourceView.superview convertRect:self.item.sourceView.frame toView:self];
        self.imageView.contentMode = self.item.sourceView.contentMode;
        self.imageView.clipsToBounds = self.item.sourceView.clipsToBounds;
    }
    
    __weak typeof(self) weakSelf = self;
    
    /** type 1:下滑进行中，scale用于控制背景颜色的透明度 ,, 2:消失动画 进行中 ,, 3:消失动画结束 */
    
    [UIView animateWithDuration:kDDPhotoBrowserAnimationTime animations:^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.scrollAnimateBlock) {
            strongSelf.scrollAnimateBlock(DDPhotoImageScrollAnimateDisappearingType,0);
        }

        strongSelf.imageView.frame = dsImageRect;
        
    } completion:^(BOOL finished) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.scrollAnimateBlock) {
            strongSelf.scrollAnimateBlock(DDPhotoImageScrollAnimateFinishedType,0);
        }
        
    }];
    
}

#pragma mark - 加载图片数据
- (void)_loadImageData
{
    [self cancelImageRequest];
    
    if ([self.item checkIsNetworkImage]) {
        
        //网络图片
        [self _downloadImageData];
        
    } else {
        
        __weak typeof(self) weakSelf = self;

        dispatch_async(dispatch_get_main_queue(), ^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;

            strongSelf.userInteractionEnabled = YES;

            //本地图片
            strongSelf.imageView.image = strongSelf.item.image;

            [strongSelf resizeImageView];

        });

        
    }

}

#pragma mark - 下载图片数据
- (void)_downloadImageData
{
    __weak typeof(self) weakSelf = self;
    
    /** 如果原图还没有下载下来，缩略图存在，为了避免缩略图是动图 ， 先加载缩略图 */
    if (![self.imageDownloadEngine imageFromCacheForURL:_item.imageUrl] && _item.thumbImageUrl && [self.imageDownloadEngine imageFromCacheForURL:_item.thumbImageUrl]) {
        
        [self.imageDownloadEngine setImageWithImageView:self.imageView imageURL:_item.thumbImageUrl placeholder:self.item.placeholderImage progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } finish:^(UIImage * _Nullable image, NSURL * _Nullable url, BOOL success, NSError * _Nullable error) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
                
            [strongSelf resizeImageView];
            
        }];
    }
    
    [self.imageDownloadEngine setImageWithImageView:self.imageView imageURL:_item.imageUrl thumbImageUrl:_item.thumbImageUrl placeholder:_item.placeholderImage progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.loadingView startAnimating];
        });
        
    } finish:^(UIImage * _Nullable image, NSURL * _Nullable url, BOOL success, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                strongSelf.userInteractionEnabled = YES;
            }
            
            [strongSelf.loadingView stopAnimating];
            
            [strongSelf resizeImageView];
            
        });
        
    }];

    [self resizeImageView];

    
}

#pragma mark - 改变图片大小
- (void)resizeImageView
{
    [super resizeImageView];
    
    if (self.item.firstShowAnimation) {
        self.item.firstShowAnimation = NO;
        
        CGRect  dsImageRect = self.imageView.frame;
        
        CGRect  sImageRect = self.item.sourceViewInWindowRect;

        if (sImageRect.size.width == 0 || sImageRect.size.height == 0) {
            sImageRect.size.width = dsImageRect.size.width;
            sImageRect.size.height = dsImageRect.size.height;
            
            sImageRect.origin.y = -sImageRect.size.height;
            sImageRect.origin.x = (CGRectGetWidth(self.frame) - sImageRect.size.width)/2.0;
        }
        
        self.imageView.frame = sImageRect;
        
        __weak typeof(self) weakSelf = self;
        
        
        [UIView animateWithDuration:kDDPhotoBrowserAnimationTime animations:^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.imageView.frame = dsImageRect;
            
        } completion:^(BOOL finished) {
            
        }];
        
        if (_loadingView && _loadingView.isAnimating) {
            //正在动画, 使动画更流畅
            self.loadingView.alpha = 0;
            [UIView animateWithDuration:kDDPhotoBrowserAnimationTime animations:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.loadingView.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }
    }

}

- (void)cancelImageRequest
{
    if (self.item && self.imageDownloadEngine) {
        [self.imageDownloadEngine cancelImageRequestWithImageView:self.imageView];
    }
}

- (DDPhotoLoadingView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[DDPhotoLoadingView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _loadingView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0);
    }
    return _loadingView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
