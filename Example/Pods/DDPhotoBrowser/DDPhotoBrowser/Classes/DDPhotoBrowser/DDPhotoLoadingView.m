//
//  DDPhotoLoadingView.m
//  BSHEnterpriseProject
//
//  Created by 刘和东 on 2020/8/29.
//  Copyright © 2020 刘和东. All rights reserved.
//

#import "DDPhotoLoadingView.h"

@implementation DDPhotoLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self _configUI];
        
    }
    return self;
}

- (void)_configUI
{
    CGFloat rabius1 = CGRectGetWidth(self.frame)/2;
    CGFloat starAgle1 = 0;
    CGFloat endAngle1 = 2 * M_PI;
    CGPoint point1 = CGPointMake(CGRectGetWidth(self.frame)/2,CGRectGetWidth(self.frame)/2);
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:point1 radius:rabius1 startAngle:starAgle1 endAngle:endAngle1 clockwise:YES];
    
    CAShapeLayer *layer1 = [[CAShapeLayer alloc]init];
    layer1.path = path1.CGPath;
    layer1.fillColor = [UIColor clearColor].CGColor;
    
    layer1.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    layer1.lineWidth = 4;
    [self.layer addSublayer:layer1];
    
    
    CGFloat rabius = CGRectGetWidth(self.frame)/2 ;
    CGFloat starAngle = 2 * M_PI * 0.85;
    CGPoint point = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetWidth(self.frame)/2);
    CGFloat endAngle = 2 * M_PI;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:rabius startAngle:starAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.path = path.CGPath;
    layer.lineCap = kCALineCapRound;
    
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 4;
    [self.layer addSublayer:layer];
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)startAnimating
{
    if (self.isAnimating) {
        return;
    }
    
    self.isAnimating = YES;
    
    [self __removeAnimation];
    
    self.hidden = NO;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI*2];
    animation.duration = 0.8;
    animation.repeatCount = CGFLOAT_MAX;
    
    animation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:animation forKey:@"animation"];

}

- (void)stopAnimating
{
    if (self.isAnimating) {
        self.isAnimating = NO;
        [self __removeAnimation];
    }
    self.hidden = YES;
}

- (void)__removeAnimation{
    if (self && self.layer) {
        [self.layer removeAnimationForKey:@"animation"];
        [self.layer removeAllAnimations];
    }
}

- (void)dealloc
{
    [self __removeAnimation];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
