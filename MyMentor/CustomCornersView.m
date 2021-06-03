//
//  UIImageView+customCorners.m
//  MyMentor
//
//  Created by Walter Yaron on 5/27/13.
//  Copyright (c) 2013 walterapps. All rights reserved.
//

#import "CustomCornersView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomCornersView

-(void) createRadiusUpperCorner
{
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                           byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                 cornerRadii:(CGSize){10.0, 10.0}].CGPath;

    maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    maskLayer.fillColor = [UIColor grayColor].CGColor;
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

-(void) createRadiusLeftBottomCorner
{
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                           byRoundingCorners:UIRectCornerBottomLeft
                                                 cornerRadii:(CGSize){5.0, 5.0}].CGPath;

    maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    maskLayer.fillColor = [UIColor grayColor].CGColor;
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

@end
