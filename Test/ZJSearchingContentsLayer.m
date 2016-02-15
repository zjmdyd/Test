//
//  ZJSearchingContentsLayer.m
//  Test
//
//  Created by ZJ on 1/22/16.
//  Copyright © 2016 ZJ. All rights reserved.
//

#import "ZJSearchingContentsLayer.h"

@interface ZJSearchingContentsLayer ()

@property (nonatomic, strong) CALayer *imagelayer;
@property (nonatomic, strong) CATextLayer *textLayer;

@end

@implementation ZJSearchingContentsLayer

@synthesize frame = _frame;
@synthesize contents = _contents;
@synthesize font = _font;
@synthesize fontSize = _fontSize;
@synthesize backgroundColor = _backgroundColor;
@synthesize contentsGravity = _contentsGravity;

+ (instancetype)layerWithSuperLayer:(CALayer *)layer {
    ZJSearchingContentsLayer *zjLayer = [ZJSearchingContentsLayer new];
    zjLayer.imagelayer = [CALayer layer];
    zjLayer.textLayer = [CATextLayer layer];
    zjLayer.textLayer.alignmentMode = kCAAlignmentCenter;
    
    [layer addSublayer:zjLayer.imagelayer];
    [layer addSublayer:zjLayer.textLayer];
    
    return zjLayer;
}

#pragma mark - setter

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    
    self.imagelayer.frame = frame;
    self.textLayer.frame = frame;
}

- (void)setContents:(id)contents {
    _contents = contents;
    
    BOOL isTextLayer = [_contents isKindOfClass:[NSString class]];
    self.imagelayer.hidden = isTextLayer;
    self.textLayer.hidden = !isTextLayer;
    
    if (isTextLayer) {
        [self reDrawText];
    }else {
        self.imagelayer.contents = _contents;
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self reDrawText];
}

/**
 *  改变CATextLayer的文本方法1
 */
- (void)reDrawText {
    CGRect rect = [_contents boundingRectWithSize:self.textLayer.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil];
    self.textLayer.frame = rect;
    self.textLayer.string = _contents;
    self.textLayer.font = (__bridge CFTypeRef _Nullable)(self.font);
    self.textLayer.fontSize = self.fontSize;
    self.textLayer.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
}

/**
 *  改变CATextLayer的文本方法2
 */
/*
- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextSetFillColorWithColor(ctx, [[UIColor darkTextColor] CGColor]);
    
    UIGraphicsPushContext(ctx);
    [word drawInRect:layer.bounds
     withFont:[UIFont systemFontOfSize:32]
     lineBreakMode:UILineBreakModeWordWrap
     alignment:UITextAlignmentCenter];
    
    [word drawAtPoint:CGPointMake(30.0f, 30.0f)
             forWidth:200.0f
             withFont:[UIFont boldSystemFontOfSize:32]
        lineBreakMode:UILineBreakModeClip];
    
    UIGraphicsPopContext();
}
*/
- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    _font = [UIFont fontWithName:_font.fontName size:_fontSize];

    [self reDrawText];
}

- (void)setBackgroundColor:(CGColorRef)backgroundColor {
    _backgroundColor = backgroundColor;
    
    self.imagelayer.backgroundColor = _backgroundColor;
    self.textLayer.backgroundColor = _backgroundColor;
}

- (void)setContentsGravity:(NSString *)contentsGravity {
    _contentsGravity = contentsGravity;
    
    self.imagelayer.contentsGravity = _contentsGravity;
    self.textLayer.contentsGravity = _contentsGravity;
}

#pragma mark - getter

- (CGRect)frame {
    return _frame;
}

- (id)contents {
    return _contents;
}

- (UIFont *)font {
    if (!_font) {
        _font = [UIFont fontWithName:@"HelveticaNeue" size:self.fontSize];
    }
    return _font;
}

- (CGFloat)fontSize {
    if (_fontSize <= FLT_EPSILON) {
        _fontSize = 36;
    }
    return _fontSize;
}

- (CGColorRef)backgroundColor {
    return _backgroundColor;
}

- (NSString *)contentsGravity {
    return _contentsGravity;
}

- (CALayer *)layer {
    if ([self.contents isKindOfClass:[NSString class]]) {
        return self.textLayer;
    }else {
        return self.imagelayer;
    }
}

@end
