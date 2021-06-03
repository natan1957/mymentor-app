//
//  AlertBackgroundWindow.m
//  ownerlistens DEBUG
//
//  Created by Walter Yaron on 12/5/13.
//  Copyright (c) 2013 OwnerListens. All rights reserved.
//

#import "AlertBackgroundWindow.h"

@interface AlertBackgroundWindow ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation AlertBackgroundWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchViewDidPressed:)];
        self.tapGesture.numberOfTapsRequired = 1;
        self.tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

- (void)touchViewDidPressed:(UIGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(alertBackgroundDidReciveTap)])
    {
        [self.delegate alertBackgroundDidReciveTap];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);

    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);





//    CGContextRef context = UIGraphicsGetCurrentContext();
//    size_t locationsCount = 2;
//    CGFloat locations[2] = {0.0f,1.0f};
//    CGFloat white;
//
//    if (self.light == 1)
//    {
//        white = 0.5f;
//    }
//    else if (self.light == 2)
//    {
//        white = 0.0f;
//    }
//    else
//    {
//        white = 1.f;
//    }
//
//    CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, white};
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
//    CGColorSpaceRelease(colorSpace);
//    if (self.light == 2)
//    {
//        [[[UIColor blackColor] colorWithAlphaComponent:0.5f] set];
//        CGContextFillRect(context, self.bounds);
//    }
//    else
//    {
//        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
//        CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
//        CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
//    }
//    CGGradientRelease(gradient);
}

@end
