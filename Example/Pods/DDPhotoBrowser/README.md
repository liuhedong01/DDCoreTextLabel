# DDPhotoBrowser

## Example

![](https://github.com/liuhedong01/DDPhotoBrowser/blob/master/2020-10-25%20153349.gif)

### 简单实用
```objc

NSMutableArray *imageDataArray = [NSMutableArray array];
NSInteger startIndex = tap.view.tag - 1;
[self.urls enumerateObjectsUsingBlock:^(NSString *   _Nonnull urlString, NSUInteger idx, BOOL * _Nonnull stop) {
                
    UIImageView * imageView = [self.view viewWithTag:1+idx];
    
    DDPhotoItem *item = [DDPhotoItem itemWithSourceView:imageView imageUrl:[NSURL URLWithString:urlString] thumbImage:nil thumbImageUrl:nil];
    
    if (idx == startIndex) {
        item.firstShowAnimation = YES;
    }
    
    [imageDataArray addObject:item];
}];

/// 配置自定义下载
DDPhotoSDImageDownloadEngine * downloadEngine = [DDPhotoSDImageDownloadEngine new];

/// DDSDAnimatedImageView 配置显示图片 的 view

/** 图片选择器展示*/
DDPhotoBrowser * b = [DDPhotoBrowser photoBrowserWithPhotoItems:imageDataArray currentIndex:startIndex getImageViewClass:DDSDAnimatedImageView.class downloadEngine:downloadEngine];

/** 设置page类型 */
b.pageIndicateStyle = DDPhotoBrowserPageIndicateStylePageLabel;

b.longPressGestureClickedBlock = ^(DDPhotoBrowser * photoBrowser ,NSInteger index, DDPhotoItem *item,NSData * imageData) {
    NSLog(@"长按手势回调：%ld", index);
};
    
[b showFromVC:self];

```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DDPhotoBrowser is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DDPhotoBrowser'
```

## Author

liuhedong01@163.com, liuhedong01@163.com

## License

DDPhotoBrowser is available under the MIT license. See the LICENSE file for more info.
