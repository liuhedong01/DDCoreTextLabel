//
//  DDTextRunDelegate.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDTextRunDelegate.h"

static void DDDeallocCallback(void *ref) {
    DDTextRunDelegate *self = (__bridge_transfer DDTextRunDelegate *)(ref);
    self = nil; // release
}

static CGFloat DDGetAscentCallback(void *ref) {
    DDTextRunDelegate *self = (__bridge DDTextRunDelegate *)(ref);
    return self.ascent;
}

static CGFloat DDGetDecentCallback(void *ref) {
    DDTextRunDelegate *self = (__bridge DDTextRunDelegate *)(ref);
    return self.descent;
}

static CGFloat DDGetWidthCallback(void *ref) {
    DDTextRunDelegate *self = (__bridge DDTextRunDelegate *)(ref);
    return self.width;
}


@implementation DDTextRunDelegate

- (CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED {
    CTRunDelegateCallbacks callbacks;
    //memset将已开辟内存空间 callbacks 的首 n 个字节的值设为值 0, 相当于对CTRunDelegateCallbacks内存空间初始化
    memset(&callbacks,0,sizeof(CTRunDelegateCallbacks));
    //设置回调版本，默认 kCTRunDelegateCurrentVersion
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = DDDeallocCallback;
    callbacks.getAscent = DDGetAscentCallback;
    callbacks.getDescent = DDGetDecentCallback;
    callbacks.getWidth = DDGetWidthCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(self.copy));
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.ascent = [aDecoder decodeFloatForKey:@"ascent"];
        self.descent = [aDecoder decodeFloatForKey:@"descent"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeFloat:self.ascent forKey:@"ascent"];
    [aCoder encodeFloat:self.descent forKey:@"descent"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.height forKey:@"height"];
}


#pragma mark - NSCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DDTextRunDelegate* delegate = [[[self class] alloc] init];
    delegate.ascent = self.ascent;
    delegate.descent = self.descent;
    delegate.width = self.width;
    delegate.height = self.height;
    delegate.userInfo = [self.userInfo copy];
    return delegate;
}

@end
