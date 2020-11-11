//
//  DDCoreTextLabel.m
//  DDCoreText
//
//  Created by 刘和东 on 2018/7/18.
//  Copyright © 2018年 DDCoreText. All rights reserved.
//

#import "DDCoreTextLabel.h"
#import "DDAsyncLayer.h"
#import "DDWeakProxy.h"

@interface DDCoreTextLabel () <DDAsyncLayerDelegate>
{
    struct {
        
        unsigned int trackingTouch : 1; //是否是移动
        
        unsigned int allowTouch : 1;//是否需要 touch
        
        unsigned int hasTapAction : 1;  //是否含有单点
        
        unsigned int hasLongPressAction : 1;//是否含有长按事件
        
    } _state;
    
}

/** 当前的高亮显示 */
@property (nonatomic, strong) DDTextHighlight * currentHighlight;

@property (nonatomic, strong) NSTimer * longPressTimer;

@property (nonatomic, strong) NSMutableArray <DDTextLayout *> * textLayoutMuArray;

@end

@implementation DDCoreTextLabel

+ (Class)layerClass
{
    return [DDAsyncLayer class];
}

- (id)init {
    self = [super init];
    if (self) {
        [self __setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __setup];
    }
    return self;
}

- (void)__setup {
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    self.layer.opaque = YES;
    self.exclusiveTouch = YES;
    self.displaysAsynchronously = YES;
    
}


- (void)setTextLayout:(DDTextLayout *)textLayout
{
    if (_textLayout && [_textLayout isEqual:textLayout]) {
        _currentHighlight = nil;
        [(DDAsyncLayer *)self.layer displayImmediately];
        return;
    }
    if (!textLayout) {
        [self _clearContents];
        return;
    }
    
    _textLayout = textLayout;
    
    [self _endTouch];
    
    [self.textLayoutMuArray removeAllObjects];
    [self.textLayoutMuArray addObjectsFromArray:@[textLayout]];
    
    [self _setLayoutNeedRedraw];
    [self invalidateIntrinsicContentSize];
    
}

#pragma mark - 重新绘制
- (void)_setLayoutNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (DDAsyncLayerDisplayTask *)newAsyncDisplayTask
{
    DDAsyncLayerDisplayTask * task = [[DDAsyncLayerDisplayTask alloc] init];
    
    __weak typeof(self) weakSelf = self;
    //开始绘制
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [layer removeAnimationForKey:@"contents"];
        [strongSelf.textLayoutMuArray enumerateObjectsUsingBlock:^(DDTextLayout * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeAttachmentFromSuperViewOrLayer];
        }];
    };
    
    //绘制中
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void)) {
        if (isCancelled && isCancelled()) return;
        [weakSelf __drawIncontext:context containerView:nil containerLayer:nil cancel:isCancelled];
    };
    
    //绘制完成
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        if (!finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.textLayoutMuArray enumerateObjectsUsingBlock:^(DDTextLayout * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeAttachmentFromSuperViewOrLayer];
            }];
            return;
        }
        [weakSelf __drawIncontext:nil containerView:weakSelf containerLayer:weakSelf.layer cancel:NULL];
    };
    
    return task;
}

#pragma mark - 绘制 数据
- (void)__drawIncontext:(CGContextRef)context
          containerView:(UIView *)containerView
         containerLayer:(CALayer *)containerLayer
                 cancel:(nullable BOOL (^)(void))cancel
{
    @autoreleasepool {
        
        /**  绘制高亮状态 */
        if (_currentHighlight && context) {
            CGMutablePathRef pathRef = CGPathCreateMutable();
            if (_currentHighlight.selectedRangeType == DDTextHighLightTextSelectedRangeWholeView) {
                //整个view选中
                CGPathAddRect(pathRef, NULL, self.bounds);
            } else {
                for (NSValue* rectValue in _currentHighlight.positions) {
                    if (cancel && cancel()) return;
                    CGRect rect = [rectValue CGRectValue];
                    CGRect adjustRect = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
                    CGPathAddRect(pathRef, NULL, adjustRect);
                }
            }
            if (cancel && cancel()) return;
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithCGPath:pathRef];
            [_currentHighlight.highlightBackgroundColor setFill];
            [beizerPath fill];
        }
        
        [self.textLayoutMuArray enumerateObjectsUsingBlock:^(DDTextLayout * _Nonnull textLayout, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cancel && cancel()) {
                *stop = YES;
                NSLog(@"异步绘制取消");
                return;
            }
            if (textLayout) {
                [textLayout drawIncontext:context size:CGSizeZero point:textLayout.origin containerView:containerView containerLayer:containerLayer cancel:cancel];
            }
            //        NSLog(@"异步绘制完成%ld",idx);
        }];
    }
}

#pragma mark - 结束 touch
- (void)_endTouch {
    [self _endLongPressTimer];
    [self _hideHighlightAnimated:NO];
    _state.trackingTouch = NO;
}

/** 清除 */
- (void)clearHighlight
{
    if (_currentHighlight) {
        [self _endTouch];
    }
}

#pragma mark - 显示高亮状态
- (void)_showHighligt {
    [(DDAsyncLayer *)self.layer displayImmediately];
}

#pragma mark - 隐藏高亮状态
- (void)_hideHighlightAnimated:(BOOL)animated {
    //隐藏 0.15秒后隐藏
    if (animated) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(0.15f * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.currentHighlight) {
                strongSelf.currentHighlight = nil;
            }
            [(DDAsyncLayer *)strongSelf.layer displayImmediately];
        });
    } else {
        if (self.currentHighlight) {
            self.currentHighlight = nil;
        }
        [(DDAsyncLayer *)self.layer displayImmediately];
    }
}

#pragma mark - Touch 手势滑动
//开始触摸
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (_currentHighlight) {
        [self _hideHighlightAnimated:NO];
    }
    
    _currentHighlight = [self _searchTextHighlightWithTouchPoint:touchPoint];
    if ( _currentHighlight || _tapAndLongPressAction) {
        
        if (_currentHighlight.gestureType == DDTextHighLightGestureTypeSingleClick) {
            _state.hasTapAction = YES;
        } else if (_currentHighlight.gestureType == DDTextHighLightGestureTypeLongPressClick) {
            _state.hasLongPressAction = YES;
        } else if (_currentHighlight.gestureType == DDTextHighLightGestureTypeSingleAndLongPressClick) {
            _state.hasTapAction = YES;
            _state.hasLongPressAction = YES;
        }
        _state.allowTouch = YES;
        _state.trackingTouch = YES;
        [self _startLongPressTimer];
        if(_currentHighlight && _currentHighlight.gestureType != DDTextHighLightGestureTypeLongPressClick)[self _showHighligt];
    } else {
        _state.allowTouch = NO;
        _state.trackingTouch = NO;
    }
    
    if (!_state.allowTouch) {
        [super touchesBegan:touches withEvent:event];
    }
    
}
//手势移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    if (_state.trackingTouch) {
        if (_currentHighlight) {
            DDTextHighlight * searchHighlight = [self _searchTextHighlightWithTouchPoint:touchPoint];
            if (searchHighlight == _currentHighlight) {
                [self _showHighligt];
            } else {
                [self _hideHighlightAnimated:NO];
            }
        }
    }
    if (!_state.allowTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}
//移动结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    if (_state.trackingTouch) {
        [self _endLongPressTimer];
        if (_tapAndLongPressAction) {
            _tapAndLongPressAction(self,NO);
        }
        if (_currentHighlight) {
            DDTextHighlight * searchHighlight = [self _searchTextHighlightWithTouchPoint:touchPoint];
            //是否相等，是否有高亮回调，是否含有单点事件
            if (searchHighlight == _currentHighlight && _highlightTapAndLongPressAction && _state.hasTapAction) {
                _highlightTapAndLongPressAction(self,_currentHighlight,NO);
            }else {
            }
            [self _hideHighlightAnimated:YES];
        }
    }
    
    if (!_state.allowTouch) {
        [super touchesBegan:touches withEvent:event];
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _endTouch];
    if (!_state.allowTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}

#pragma mark - 长按 与 暂停 定时器
- (void)_startLongPressTimer {
    [self _endLongPressTimer];
    _longPressTimer = [NSTimer timerWithTimeInterval:ddText_kLongPressMinimumDuration
                                              target:[DDWeakProxy proxyWithTarget:self]
                                            selector:@selector(_trackDidLongPress)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}
- (void)_endLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = nil;
}


#pragma mark - 目前为长按事件了
- (void)_trackDidLongPress
{
    [self _endLongPressTimer];
    
    if (_tapAndLongPressAction) {
        _tapAndLongPressAction(self,YES);
    }
    if (_currentHighlight) {
        [self _showHighligt];
        if (_state.hasLongPressAction && _highlightTapAndLongPressAction) {
            _highlightTapAndLongPressAction(self,_currentHighlight,YES);
            _state.trackingTouch = NO;
        } else {
            [self _hideHighlightAnimated:YES];
        }
    }
}

#pragma mark - 根据 点击的 point 搜索DDTextHighlight
- (DDTextHighlight *)_searchTextHighlightWithTouchPoint:(CGPoint)touchPoint {
    for (DDTextLayout * textLayout in self.textLayoutMuArray) {
        DDTextHighlight * highlight  = [self _searchTextHighlightWithTouchPoint:touchPoint textLayout:textLayout];
        if (highlight) {
            return highlight;
        }
    }
    return nil;
}

- (DDTextHighlight *)_searchTextHighlightWithTouchPoint:(CGPoint)touchPoint textLayout:(DDTextLayout *)textLayout
{
    DDTextHighlight * wholeView = nil;
    DDTextHighlight * wholeText = nil;
    DDTextHighlight * viewXAndWidth = nil;
    DDTextHighlight * searchHighlight = nil;
    
    if (CGRectContainsPoint(CGRectMake(textLayout.textBoundingRect.origin.x, textLayout.textBoundingRect.origin.y, textLayout.textBoundingRect.size.width, textLayout.textBoundingRect.size.height), touchPoint)) {
        NSInteger startIndex = [self __getIndexFromLocation:touchPoint textLayout:textLayout];
        if (startIndex >= 0 && startIndex <= textLayout.text.length) {
            searchHighlight = [textLayout.text attribute:DDTextHighlightAttributeName atIndex:startIndex effectiveRange:nil];
        }
    }
    for (DDTextHighlight * one in textLayout.textHighlights) {
        if (one.selectedRangeType == DDTextHighLightTextSelectedRangeWholeView) {
            wholeView = one;
        }
        for (NSValue* value in one.positions) {
            CGRect rect = [value CGRectValue];
            CGRect adjustRect = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
            if (CGRectContainsPoint(adjustRect, touchPoint)) {
                if (one.selectedRangeType == DDTextHighLightTextSelectedRangeNormal) {
                    return one;
                } else if (one.selectedRangeType == DDTextHighLightTextSelectedRangeWholeText) {
                    wholeText = one;
                } else if (one.selectedRangeType == DDTextHighLightTextSelectedRangeViewXAndWidth) {
                    viewXAndWidth = one;
                }
            }
        }
    }
    if (searchHighlight && wholeText == searchHighlight) {
        return wholeText;
    }
    if (searchHighlight && viewXAndWidth == searchHighlight) {
        return viewXAndWidth;
    }
    if (wholeText) {
        return wholeText;
    }
    if (viewXAndWidth) {
        return viewXAndWidth;
    }
    return wholeView;
}
- (CFIndex)__getIndexFromLocation:(CGPoint)location  textLayout:(DDTextLayout *)textLayout {
    
    @autoreleasepool {
        
        CGPoint position = textLayout.origin;
        
        //获取触摸点击当前view的坐标位置
        location.y = location.y - textLayout.textBoundingRect.origin.y - position.y;
        //获取每一行
        
        NSArray<DDTextLine *>* lines = textLayout.linesArray;
        
        CTLineRef line = NULL;
        CGPoint lineOrigin = CGPointZero;
        
        CGPathRef path = textLayout.path;
        
        //获取整个CTFrame的大小
        CGRect rect = CGPathGetBoundingBox(path);
        for (int i = 0; i < lines.count; i++) {
            CGPoint origin = lines[i].lineOrigin;
            //判断点击的位置处于那一行范围内
            if ((location.y <= rect.size.height - origin.y + 5) && (location.x >= origin.x)) {
                line = lines[i].CTLine;
                lineOrigin = origin;
                break;
            }
        }
        location.x -= lineOrigin.x;
        //获取点击位置所处的字符位置，就是相当于点击了第几个字符
        CFIndex index = CTLineGetStringIndexForPosition(line, location);
        return index - 1;
    }
}



#pragma mark - 设置是否异步绘制
- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously
{
    if (_displaysAsynchronously != displaysAsynchronously) {
        _displaysAsynchronously = displaysAsynchronously;
        [(DDAsyncLayer *)self.layer setDisplaysAsynchronously:_displaysAsynchronously];
    }
}

- (NSMutableArray<DDTextLayout *> *)textLayoutMuArray
{
    if (!_textLayoutMuArray) {
        _textLayoutMuArray = [NSMutableArray array];
    }
    return _textLayoutMuArray;
}

#pragma mark - 清楚当前的  layer.contents
- (void)_clearContents {
    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            CFRelease(image);
        });
    }
}

- (void)setAsyncDisplayQueue:(dispatch_queue_t)asyncDisplayQueue
{
    //    _asyncDisplayQueue = asyncDisplayQueue;
    //    DDAsyncLayer * asLayer = (DDAsyncLayer *)self.layer;
    //    asLayer.asyncDisplayQueue = asyncDisplayQueue;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
