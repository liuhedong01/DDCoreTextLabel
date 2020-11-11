//
//  DDTextAttribute.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/15.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDTextAttribute.h"
#import <UIKit/UIKit.h>

NSString *const DDTextAttachmentAttributeName = @"DDTextAttachment__";
NSString *const DDTextHighlightAttributeName = @"DDTextHighlight__";

NSString *const DDTextTruncationToken = @"\u2026";


@implementation DDTextAttachment

+ (instancetype)attachmentWithContent:(id)content
{
    DDTextAttachment * attachment = [[DDTextAttachment alloc] init];
    attachment.content = content;
    attachment.contentMode = UIViewContentModeScaleAspectFill;
    attachment.contentEdgeInsets = UIEdgeInsetsZero;
    return attachment;
}

- (id)init {
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentEdgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeCGRect:self.frame forKey:@"frame"];
    [aCoder encodeObject:self.URL forKey:@"URL"];
    [aCoder encodeInteger:self.contentMode forKey:@"contentMode"];
    [aCoder encodeUIEdgeInsets:self.contentEdgeInsets forKey:@"contentEdgeInsets"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        self.frame = [aDecoder decodeCGRectForKey:@"frame"];
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
        self.contentMode = [aDecoder decodeIntegerForKey:@"contentMode"];
        self.contentEdgeInsets = [aDecoder decodeUIEdgeInsetsForKey:@"contentEdgeInsets"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DDTextAttachment * attachment = [[DDTextAttachment alloc] init];
    if ([self.content conformsToProtocol:@protocol(NSCopying)]) {
        attachment.content = [self.content copy];
    } else {
        attachment.content = self.content;
    }
    attachment.range = self.range;
    attachment.frame = self.frame;
    attachment.URL = [self.URL copy];
    attachment.contentMode = self.contentMode;
    attachment.contentEdgeInsets = self.contentEdgeInsets;
    attachment.userInfo = [self.userInfo copy];
    return attachment;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end


@implementation DDTextHighlight

- (id)init {
    self = [super init];
    if (self) {
        self.content = nil;
        self.tag = 0;
        self.row = 0;
        self.range = NSMakeRange(0, 0);
        self.normalColor = [UIColor clearColor];
        self.highlightBackgroundColor = [UIColor clearColor];
        self.positions = @[];
        self.userInfo = @{};
        self.selectedRangeType = DDTextHighLightTextSelectedRangeNormal;
        self.gestureType = DDTextHighLightGestureTypeSingleAndLongPressClick;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.tag) forKey:@"tag"];
    [aCoder encodeObject:@(self.row) forKey:@"row"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeObject:self.normalColor forKey:@"normalColor"];
    [aCoder encodeObject:self.highlightBackgroundColor forKey:@"highlightBackgroundColor"];
    [aCoder encodeObject:self.positions forKey:@"positions"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeInteger:self.selectedRangeType forKey:@"selectedRangeType"];
    [aCoder encodeInteger:self.gestureType forKey:@"gestureType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.tag = [[aDecoder decodeObjectForKey:@"tag"] integerValue];
        self.row = [[aDecoder decodeObjectForKey:@"row"] integerValue];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        self.normalColor = [aDecoder decodeObjectForKey:@"normalColor"];
        self.highlightBackgroundColor = [aDecoder decodeObjectForKey:@"highlightBackgroundColor"];
        self.positions = [aDecoder decodeObjectForKey:@"positions"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.selectedRangeType = [aDecoder decodeIntegerForKey:@"selectedRangeType"];
        self.gestureType = [aDecoder decodeIntegerForKey:@"gestureType"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DDTextHighlight* highlight = [[DDTextHighlight alloc] init];
    if ([self.content conformsToProtocol:@protocol(NSCopying)]) {
        highlight.content = [self.content copy];
    }
    else {
        highlight.content = self.content;
    }
    highlight.tag = self.tag;
    highlight.row = self.row;
    highlight.range = self.range;
    highlight.normalColor = [self.normalColor copy];
    highlight.highlightBackgroundColor = [self.highlightBackgroundColor copy];
    highlight.positions = [self.positions copy];
    highlight.userInfo = [self.userInfo copy];
    highlight.selectedRangeType = self.selectedRangeType;
    highlight.gestureType = self.gestureType;
    return highlight;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}


#pragma mark -
- (NSUInteger)hash {
    long v1 = (long)((__bridge void *)self.content);
    long v2 = (long)[NSValue valueWithRange:self.range];
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    if (![object isMemberOfClass:self.class]){
        return NO;
    }
    DDTextHighlight* other = object;
    return other.content == _content && [NSValue valueWithRange:other.range] == [NSValue valueWithRange:self.range];
}

@end


