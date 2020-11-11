//
//  DDTextGlyph.h
//  BSHProject
//
//  Created by 刘和东 on 2018/12/12.
//  Copyright © 2018 深圳伴生活科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDTextGlyph : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) CGGlyph glyph;
@property (nonatomic,assign) CGPoint position;
@property (nonatomic,assign) CGFloat ascent;
@property (nonatomic,assign) CGFloat descent;
@property (nonatomic,assign) CGFloat leading;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;

@end

NS_ASSUME_NONNULL_END
