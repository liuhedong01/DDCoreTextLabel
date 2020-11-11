//
//  DDPhotoBrowser.m
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/28.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import "DDPhotoBrowser.h"
#import "DDPhotoBrowserCollectionViewCell.h"

#define kDD___PhotoBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)

@interface DDPhotoBrowser () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

/**图片边距*/
@property (nonatomic, assign) CGFloat kDDPhotoImageViewPadding;

/** 记录进来之前的 状态栏状态 */
@property (nonatomic, assign) BOOL recordStatusBarHidden;

/**背景*/
@property (nonatomic, strong) UIView *backgroundView;

/**collectionView*/
@property (nonatomic, strong) UICollectionView * collectionView;

/**DDPhotoItem 数组*/
@property (nonatomic, strong) NSMutableArray *photoItems;

/** 当前第几个 */
@property (nonatomic, assign) NSUInteger currentPage;

/** 指示页码 */
@property (nonatomic, strong) UIPageControl * pageControl;

/** 数字 - 指示页码 */
@property (nonatomic, strong) UILabel * pageLabel;

/**  获取图片 */
@property (nonatomic, copy) Class<DDGetImageViewEngine> getImageViewClass;

/**  图片下载 */
@property (nonatomic, strong) id<DDPhotoImageDownloadEngine> imageDownloadEngine;

@end

@implementation DDPhotoBrowser

- (instancetype)init {
    NSAssert(NO, @"Use photoBrowserWithPhotoItems: instead.");
    return nil;
}

/**
 * 默认使用 初始化
 */
+ (instancetype)photoBrowserWithPhotoItems:(NSArray<DDPhotoItem *> *)photoItems
                              currentIndex:(NSUInteger)currentIndex
                         getImageViewClass:(Class<DDGetImageViewEngine>)getImageViewClass
                            downloadEngine:(id<DDPhotoImageDownloadEngine>)downloadEngine
{
    DDPhotoBrowser * bVC = [[DDPhotoBrowser alloc] initWithPhotoItems:photoItems currentIndex:currentIndex getImageViewClass:getImageViewClass downloadEngine:downloadEngine];
    return bVC;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (instancetype)initWithPhotoItems:(NSArray<DDPhotoItem *> *)photoItems
                      currentIndex:(NSUInteger)currentIndex
                 getImageViewClass:(Class<DDGetImageViewEngine>)getImageViewClass
                    downloadEngine:(id<DDPhotoImageDownloadEngine>)downloadEngine

{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.photoItems = [NSMutableArray array];
        [self.photoItems addObjectsFromArray:photoItems];
        self.currentPage = currentIndex;
        self.pageIndicateStyle = DDPhotoBrowserPageIndicateStylePageLabel;
        self.getImageViewClass = getImageViewClass;
        self.imageDownloadEngine = downloadEngine;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIView animateWithDuration:kDDPhotoBrowserAnimationTime animations:^{
        self.backgroundView.alpha = 1.0;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self _configUI];
    
}

#pragma mark - 布局 UI 界面
- (void)_configUI
{
 
    _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = 0.0;
    
    [self.view addSubview:self.backgroundView];
    
    
    [self.view addSubview:self.collectionView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.collectionView.contentOffset = CGPointMake(self.currentPage*kDD___PhotoBrowserWidth, 0);

    //判断是否 添加 page
    if (self.photoItems && self.photoItems.count > 1) {
        //大于一个的时候

        if (_pageControl) {
            [_pageControl removeFromSuperview];
            _pageControl = nil;
        }
        
        if (_pageLabel) {
            [_pageLabel removeFromSuperview];
            _pageLabel = nil;
        }
        if (self.pageIndicateStyle == DDPhotoBrowserPageIndicateStylePageControl) {

            self.pageControl.numberOfPages = self.photoItems.count;

            [self.view addSubview:self.pageControl];
            
        } else if (self.pageIndicateStyle == DDPhotoBrowserPageIndicateStylePageLabel) {
            
            [self.view addSubview:self.pageLabel];
            
        }

        [self __setupPageIndicateStyleUI];

    }

}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate  代理
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoItems.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDPhotoBrowserCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DDPhotoBrowserCollectionViewCell" forIndexPath:indexPath];
    cell.getImageViewClass = self.getImageViewClass;
    
    cell.imageDownloadEngine = self.imageDownloadEngine;
    
    DDPhotoItem * item = self.photoItems[indexPath.row];
    
    cell.item = item;
    
    __weak typeof(self) weakSelf = self;
    
    cell.imageView.scrollAnimateBlock = ^(DDPhotoImageScrollAnimateType type, CGFloat scale) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (type == DDPhotoImageScrollAnimateSlidingDownType) {
            strongSelf.backgroundView.alpha = scale;
        } else if (type == DDPhotoImageScrollAnimateDisappearingType) {
            strongSelf.backgroundView.alpha = 0;
        } else if (type == DDPhotoImageScrollAnimateFinishedType) {
            //结束，返回上一个界面
            [strongSelf _dismissViewController];
        } else if (type == DDPhotoImageScrollAnimateFinishedType) {
            //下滑中止
            strongSelf.backgroundView.alpha = 1;
        }
    };
    
#pragma mark - 长按手势回传
    cell.imageView.longPressGestureClickedBlock = ^(NSData * _Nonnull imageData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.longPressGestureClickedBlock) {
            strongSelf.longPressGestureClickedBlock(strongSelf,strongSelf.currentPage, item, imageData);
        }
    };
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
}

/**监听滑动*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {

        if (!self.photoItems || self.photoItems.count <= 1) {
            //小于 等于  1 是 不用计算的
            return;
        }

        NSInteger pageIndex =  (NSInteger)scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);

        if (pageIndex <= 0) {
            pageIndex = 0;
        }

        if (pageIndex >= self.photoItems.count) {
            pageIndex = self.photoItems.count - 1;
        }

        self.currentPage = pageIndex;

        if (self.photoBrowserScrollToIndexBlock) {

            DDPhotoItem * item = self.photoItems[self.currentPage];

            //返回到 调用方，目前滑动到哪里了
            self.photoBrowserScrollToIndexBlock(self.currentPage, item);
        }

        [self __setupPageIndicateStyleUI];

    }

}

/**布局pageIndicate*/
- (void)__setupPageIndicateStyleUI
{
    if (self.pageIndicateStyle == DDPhotoBrowserPageIndicateStylePageControl) {

        self.pageControl.hidden = NO;

        self.pageControl.numberOfPages = self.photoItems.count;
        self.pageControl.currentPage = self.currentPage;
                
    } else if (self.pageIndicateStyle == DDPhotoBrowserPageIndicateStylePageLabel) {
        self.pageLabel.hidden = NO;
        
        NSString * string = [NSString stringWithFormat:@"%ld/%ld",(self.currentPage+1), self.photoItems.count];
        self.pageLabel.text = string;
    }
}

#pragma mark - 弹出 控制器
- (void)showFromVC:(UIViewController *)vc
{
    [vc presentViewController:self animated:NO completion:^{
    }];
}

#pragma mark - 控制器  dismiss 消失
- (void)_dismissViewController
{
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            [obj removeFromSuperview];
        }
    }];
    
    self.backgroundView.hidden = YES;
    
    [self dismissViewControllerAnimated:NO completion:^{
    }];
    
    if (self.viewDismissCompletionBlock) {
        self.viewDismissCompletionBlock();
    }
    
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(kDD___PhotoBrowserWidth, [UIScreen mainScreen].bounds.size.height);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kDD___PhotoBrowserWidth, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = YES;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[DDPhotoBrowserCollectionViewCell class] forCellWithReuseIdentifier:@"DDPhotoBrowserCollectionViewCell"];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-40, CGRectGetWidth(self.view.frame), 20)];
    }
    return _pageControl;
}

/** 数字 - 指示页码 */
- (UILabel *)pageLabel
{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont boldSystemFontOfSize:16];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        
        CGFloat minY = 30.f;
        if (@available(iOS 11.0, *)) minY = 10+ UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;

        _pageLabel.frame = CGRectMake(15, minY, CGRectGetWidth(self.view.frame)-30, _pageLabel.font.lineHeight);
        
    }
    return _pageLabel;
}

- (void)dealloc
{
    NSLog(@"dealloc：%@",NSStringFromClass([self class]));
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
