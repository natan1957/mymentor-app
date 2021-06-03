//
//  YHRoundBorderedButton.m
//  YHRoundBorderedButton
//
//  Created by Yeonghoon Park on 4/10/14.
//  Copyright (c) 2014 yhpark.co. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "YHRoundBorderedButton.h"

@interface YHRoundBorderedButton()

@property(nonatomic, assign) BOOL plusIconVisible;

@end

@implementation YHRoundBorderedButton

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:13.f]];
    self.layer.cornerRadius = 3.5f;
    self.layer.borderWidth = 1.0f;
    [self refreshBorderColor];
}

- (void)setPlusIconVisibility:(BOOL)show
{
    self.plusIconVisible = show;
    
    // TODO
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setTitleColor:tintColor forState:UIControlStateNormal];
    [self refreshBorderColor];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self refreshBorderColor];
}

- (void)refreshBorderColor
{
    self.layer.borderColor = [self isEnabled] ? [[self tintColor] CGColor] : [[UIColor grayColor] CGColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:0.25f
                     animations:^
    {
        self.layer.backgroundColor = highlighted ? [[UIColor colorWithRed:25.f/255.f green:148.f/255.f blue:250.f/255.f alpha:1.f] CGColor] : self.layer.backgroundColor;
//        highlighted ? [[self tintColor] CGColor] : [[UIColor clearColor] CGColor];
    }];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize org = [super sizeThatFits:self.bounds.size];
    return CGSizeMake(org.width + 20, org.height - 2);
}

@end
