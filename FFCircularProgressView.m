//
//  FFCircularProgressBar.m
//  FFCircularProgressBar
//
//  Created by Fabiano Francesconi on 16/07/13.
//  Copyright (c) 2013 Fabiano Francesconi. All rights reserved.
//

#import "FFCircularProgressView.h"
#import "UIColor+i7HexColor.h"

@interface FFCircularProgressView() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) CAShapeLayer *progressBackgroundLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *iconLayer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL isSpinning;
@end

@implementation FFCircularProgressView

#define kArrowSizeRatio .12
#define kStopSizeRatio  .3
#define kTickWidthRatio .3

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setIconView:(UIView *)iconView
{
    if (_iconView)
    {
        [_iconView removeFromSuperview];
    }
    
    _iconView = iconView;
    [self addSubview:_iconView];
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    
    _lineWidth = fmaxf(self.frame.size.width * 0.04, 1.f);
    _tintColor = [UIColor colorWithHexString:@"f99200"];
    _tickColor = [UIColor whiteColor];
    
    self.progressBackgroundLayer = [CAShapeLayer layer];
    _progressBackgroundLayer.strokeColor = _tintColor.CGColor;
    _progressBackgroundLayer.fillColor = self.backgroundColor.CGColor;
    _progressBackgroundLayer.lineCap = kCALineCapRound;
    _progressBackgroundLayer.lineWidth = _lineWidth;
    [self.layer addSublayer:_progressBackgroundLayer];
    
    self.progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = _tintColor.CGColor;
    _progressLayer.fillColor = nil;
    _progressLayer.lineCap = kCALineCapSquare;
    _progressLayer.lineWidth = _lineWidth * 2.0;
    [self.layer addSublayer:_progressLayer];
    
    self.iconLayer = [CAShapeLayer layer];
    _iconLayer.strokeColor = _tintColor.CGColor;
    _iconLayer.fillColor = nil;
    _iconLayer.lineCap = kCALineCapButt;
    _iconLayer.lineWidth = _lineWidth;
    _iconLayer.fillRule = kCAFillRuleNonZero;
    [self.layer addSublayer:_iconLayer];

    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ffCircularProgressViewDidReciveTap:)];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)ffCircularProgressViewDidReciveTap:(UITapGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(ffCircularProgressViewStopButtonTouchUpInside)])
    {
        [self.delegate ffCircularProgressViewStopButtonTouchUpInside];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    _progressBackgroundLayer.strokeColor = tintColor.CGColor;
    _progressLayer.strokeColor = tintColor.CGColor;
    _iconLayer.strokeColor = tintColor.CGColor;
}

- (void)setTickColor:(UIColor *)tickColor
{
    _tickColor = tickColor;
}

- (void)ffCircularProgressViewStopButtonTouchUpInside
{

}

- (void)drawRect:(CGRect)rect
{
    // Make sure the layers cover the whole view
    _progressBackgroundLayer.frame = self.bounds;
    _progressLayer.frame = self.bounds;
    _iconLayer.frame = self.bounds;

    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;

    // Draw background
    [self drawBackgroundCircle:_isSpinning];

    // Draw progress
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    // CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    processPath.lineCapStyle = kCGLineCapButt;
    processPath.lineWidth = _lineWidth;

    radius = (self.bounds.size.width - _lineWidth*3) / 2.0;
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    [_progressLayer setPath:processPath.CGPath];
    
    if ([self progress] == 1.0)
    {

    }
    else if (([self progress] > 0) && [self progress] < 1.0)
    {
        [self drawStop];
    }
    else
    {
        if (!self.iconView && !self.iconPath)
        {
//            [self drawArrow];
        }
        else if (self.iconPath)
        {
            _iconLayer.path = self.iconPath.CGPath;
            _iconLayer.fillColor = nil;
        }
    }
}

#pragma mark -
#pragma mark Setters

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = fmaxf(lineWidth, 1.f);
    
    _progressBackgroundLayer.lineWidth = _lineWidth;
    _progressLayer.lineWidth = _lineWidth * 2.0;
    _iconLayer.lineWidth = _lineWidth;
}

#pragma mark -
#pragma mark Drawing

- (void) drawBackgroundCircle:(BOOL) partial {
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;
    
    // Draw background
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = _lineWidth;
    processBackgroundPath.lineCapStyle = kCGLineCapRound;
    
    // Recompute the end angle to make it at 90% of the progress
    if (partial) {
        endAngle = (1.8F * (float)M_PI) + startAngle;
    }

    [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];

    _progressBackgroundLayer.path = processBackgroundPath.CGPath;
}

- (void) drawStop {
    CGFloat radius = (self.bounds.size.width)/2;
    CGFloat ratio = kStopSizeRatio;
    CGFloat sideSize = self.bounds.size.width * ratio;
    
    UIBezierPath *stopPath = [UIBezierPath bezierPath];
    [stopPath moveToPoint:CGPointMake(0, 0)];
    [stopPath addLineToPoint:CGPointMake(sideSize, 0.0)];
    [stopPath addLineToPoint:CGPointMake(sideSize, sideSize)];
    [stopPath addLineToPoint:CGPointMake(0.0, sideSize)];
    [stopPath closePath];
    
    // ...and move it into the right place.
    [stopPath applyTransform:CGAffineTransformMakeTranslation(radius * (1-ratio), radius* (1-ratio))];
    
    [_iconLayer setPath:stopPath.CGPath];
    [_iconLayer setStrokeColor:_progressLayer.strokeColor];
    [_iconLayer setFillColor:self.tintColor.CGColor];
}

#pragma mark Setters

- (void)setProgress:(CGFloat)progress {
    if (progress > 1.0) progress = 1.0;
    
    if (_progress != progress) {
        _progress = progress;
        
        if (_progress == 1.0)
        {
        }
        
        if (_progress == 0.0) {
            _progressBackgroundLayer.fillColor = self.backgroundColor.CGColor;
        }
        
        [self setNeedsDisplay];
    }
}

#pragma mark Animations

- (void) startSpinProgressBackgroundLayer {
    self.isSpinning = YES;
    [self drawBackgroundCircle:YES];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_progressBackgroundLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void) stopSpinProgressBackgroundLayer
{
    [self drawBackgroundCircle:NO];
    
    [_progressBackgroundLayer removeAllAnimations];
    self.isSpinning = NO;
}

@end
