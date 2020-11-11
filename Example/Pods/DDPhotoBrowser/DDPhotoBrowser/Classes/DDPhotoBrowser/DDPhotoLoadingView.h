//
//  DDPhotoLoadingView.h
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/29.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDPhotoLoadingView : UIView

@property BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
