//
//  DDTextGlyph.m
//  BSHProject
//
//  Created by 刘和东 on 2018/12/12.
//  Copyright © 2018 深圳伴生活科技有限公司. All rights reserved.
//

#import "DDTextGlyph.h"

@implementation DDTextGlyph

- (id)init {
    self = [super init];
    if (self) {
        self.position = CGPointZero;
        self.ascent = 0.0f;
        self.descent = 0.0f;
        self.leading = 0.0f;
        self.width = 0.0f;
        self.height = 0.0f;
    }
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.glyph forKey:@"glyph"];
    [aCoder encodeFloat:self.ascent forKey:@"ascent"];
    [aCoder encodeFloat:self.descent forKey:@"descent"];
    [aCoder encodeFloat:self.leading forKey:@"leading"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeCGPoint:self.position forKey:@"position"];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.glyph = [aDecoder decodeIntegerForKey:@"glyph"];
        self.ascent = [aDecoder decodeFloatForKey:@"ascent"];
        self.descent = [aDecoder decodeFloatForKey:@"descent"];
        self.leading = [aDecoder decodeFloatForKey:@"leading"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.position = [aDecoder decodeCGPointForKey:@"position"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DDTextGlyph* one = [[DDTextGlyph alloc] init];
    one.glyph = self.glyph;
    one.position = self.position;
    one.ascent = self.ascent;
    one.descent = self.descent;
    one.leading = self.leading;
    one.width = self.width;
    one.height = self.height;
    return one;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}


@end
