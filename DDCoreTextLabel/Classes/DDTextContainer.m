//
//  DDTextContainer.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/16.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDTextContainer.h"

@interface DDTextContainer ()

@property (nonatomic,assign) CGSize size;
@property (nonatomic,strong) UIBezierPath* path;
@property (nonatomic,assign) UIEdgeInsets edgeInsets;

@end


@implementation DDTextContainer {
//    dispatch_semaphore_t _lock;
//    CGFloat _pathLineWidth;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DDTextContainer* one = [[DDTextContainer alloc] init];
//    one.verticalAlignment = self.verticalAlignment;
    one.size = self.size;
    one.path = [self.path copy];
    one.edgeInsets = self.edgeInsets;
    one.maxNumberOfLines = self.maxNumberOfLines;
    one.truncationType = self.truncationType;
    return one;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    //    [aCoder encodeInteger:self.verticalAlignment forKey:@"verticalAlignment"];
    [aCoder encodeInteger:self.truncationType forKey:@"truncationType"];
    [aCoder encodeCGSize:self.size forKey:@"size"];
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeUIEdgeInsets:self.edgeInsets forKey:@"edgeInsets"];
    [aCoder encodeInteger:self.maxNumberOfLines forKey:@"maxNumberOfLines"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        //        self.verticalAlignment = [aDecoder decodeIntegerForKey:@"verticalAlignment"];
        self.truncationType = [aDecoder decodeIntegerForKey:@"truncationType"];
        self.size = [aDecoder decodeCGSizeForKey:@"size"];
        self.path = [aDecoder decodeObjectForKey:@"path"];
        self.edgeInsets = [aDecoder decodeUIEdgeInsetsForKey:@"edgeInsets"];
        self.maxNumberOfLines = [aDecoder decodeIntegerForKey:@"maxNumberOfLines"];
    }
    return self;
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
//    _lock = dispatch_semaphore_create(1);
    return self;
}


+ (instancetype)containerWithSize:(CGSize)size;
{
    DDTextContainer* textContainer = [[DDTextContainer alloc] init];
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    textContainer.path = bezierPath;
    textContainer.size = size;
    textContainer.edgeInsets = UIEdgeInsetsZero;
    textContainer.maxNumberOfLines = 0;
    textContainer.truncationType = DDTextTruncationTypeEnd;
    
    return textContainer;
}

+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets
{
    DDTextContainer* textContainer = [[DDTextContainer alloc] init];
    CGRect rect = (CGRect) {CGPointZero,size};
    //UIEdgeInsetsInsetRect 表示在原来的rect基础上根据边缘距离内切一个rect出来
    rect = UIEdgeInsetsInsetRect(rect,insets);
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRect:rect];
    textContainer.path = bezierPath;
    textContainer.size = size;
    textContainer.edgeInsets = insets;
    textContainer.maxNumberOfLines = 0;
    textContainer.truncationType = DDTextTruncationTypeEnd;
    return textContainer;
}

#pragma mark - Getter

//- (CGFloat)pathLineWidth {
//    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
//    CGFloat width = _pathLineWidth;
//    dispatch_semaphore_signal(_lock);
//    return width;
//}



@end
