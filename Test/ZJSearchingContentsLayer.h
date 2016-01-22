//
//  ZJSearchingContentsLayer.h
//  Test
//
//  Created by ZJ on 1/22/16.
//  Copyright © 2016 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZJSearchingContentsLayer : NSObject

@property CGRect frame;

/**
 *  typically a CGImageRef ro a string/mutableString
 */
@property (nullable, strong) id contents;

@property(nullable) CGColorRef backgroundColor;

@property (nullable, copy) NSString *contentsGravity;

@property (nullable, readonly, strong) CALayer *layer;

/**
 *  如果内容是文本的话, 可以设置文本的字体
 */
@property (nullable, strong) UIFont *font;

/**
 *  默认的字体大小为36
 */
@property CGFloat fontSize;

+ (nullable instancetype)layerWithSuperLayer:(nullable CALayer *)layer;

@end
