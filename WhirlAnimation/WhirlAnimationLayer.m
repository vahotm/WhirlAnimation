//
//  WhirlAnimationLayer.m
//  WhirlAnimation
//
//  Created by ivanSamalazau on 11.8.16.
//

#import "WhirlAnimationLayer.h"
#import "UIColor+Utilities.h"


#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)

/*
 * The corner radius is calculated to be the result of the width / 4. Assuming the width === height.
 * Default size is 100x100.
 */
const CGFloat kDefaultLayerSize = 100.0;
const CGFloat kDefaultRotationDegree = 60.0;
const CGFloat m34 = 1.0 / -500.0;

const double kWhirlAnimationTimeOffset = 0.1;
const double kWhirlAnimationDuration = 1.0;
const double kFallbackAnimationDuration = 0.6;

NSString * const kWhirlAnimationKey = @"WhirlAnimationKey";
NSString * const kFallbackAnimationKey = @"FallbackAnimationKey";


@implementation WhirlAnimationLayer

@synthesize color = _color;

#pragma mark - Init

- (instancetype)initWithNumberOfItems:(NSInteger)items {
    self = [super init];
    if (self != nil) {
        self.masksToBounds = NO;
        self.size = CGSizeMake(kDefaultLayerSize, kDefaultLayerSize);
        
        for (int i = 0; i < items; i++) {
            CAShapeLayer *layer = [self generateLayerWithSize:self.size index:i];
            [self insertSublayer:layer atIndex:0];
            [self setZPositionOfShape:layer z:i];
        }
        
        self.sublayers = [[self.sublayers reverseObjectEnumerator] allObjects];
        [self centerInSuperLayer];
        [self rotateToDegree:kDefaultRotationDegree];
    }
    return self;
}

#pragma mark - Animation

- (void)startAnimating {
    double offsetTime = 0;
    CATransform3D transform = CATransform3DIdentity;
    
    transform.m34 = m34;
    transform = CATransform3DRotate(transform, M_PI, 0, 0, 1);
    
    [CATransaction begin];
    for (CALayer *sublayer in self.sublayers) {
        CABasicAnimation *animation = [self spinAnimationForTransform:transform];
        animation.beginTime = [sublayer convertTime:CACurrentMediaTime() toLayer:nil] + offsetTime;
        [sublayer addAnimation:animation forKey:kWhirlAnimationKey];
        offsetTime += kWhirlAnimationTimeOffset;
    }
    [CATransaction commit];
}

- (void)stopAnimating {
    [CATransaction begin];
    for (CALayer *sublayer in self.sublayers) {
        CALayer *currentLayer = (CALayer *)[sublayer presentationLayer];
        CATransform3D currentTransform = currentLayer.transform;
        CAAnimation *fallbackAnimation = [self fallbackAnimationForTransform:currentTransform];
        [sublayer removeAnimationForKey:kWhirlAnimationKey];
        [sublayer addAnimation:fallbackAnimation forKey:kFallbackAnimationKey];
    }
    [CATransaction commit];
}

- (CABasicAnimation *)spinAnimationForTransform:(CATransform3D)transform {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(transform))];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.duration = kWhirlAnimationDuration;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = HUGE;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    return animation;
}

- (CABasicAnimation *)fallbackAnimationForTransform:(CATransform3D)transform {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(transform))];
    animation.fromValue = [NSValue valueWithCATransform3D:transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.duration = kFallbackAnimationDuration;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return animation;
}

#pragma mark - Accessors

- (UIColor *)color {
    if (_color == nil) {
        _color = [UIColor whiteColor];
    }
    return _color;
}

- (void)setColor:(UIColor *)color {
    NSInteger index = 0;
    for (CALayer *sublayer in self.sublayers) {
        if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
            ((CAShapeLayer *)sublayer).fillColor = [[color waSetHueSaturationOrBrightness:HSBAComponentAlpha
                                                                               percentage:1.0 - (0.1 * (CGFloat)index)] CGColor];
        }
        index++;
    }
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    
    [self setSublayersSize:size];
}

- (void)setSublayersSize:(CGSize)size {
    for (CALayer *sublayer in self.sublayers) {
        if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
            CAShapeLayer *shapeSublayer = (CAShapeLayer *)sublayer;
            shapeSublayer.path = [self bezierPathWithSize:size].CGPath;
            shapeSublayer.frame = CGPathGetBoundingBox(shapeSublayer.path);
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forLayer:shapeSublayer];
        }
    }
}

- (BOOL)isAnimating {
    BOOL isAnimating = NO;
    for (CALayer *sublayer in self.sublayers) {
        if ([sublayer animationForKey:kWhirlAnimationKey] != nil) {
            isAnimating = YES;
        }
        break;
    }
    return isAnimating;
}

#pragma mark - Helper methods

- (CAShapeLayer *)generateLayerWithSize:(CGSize)size index:(NSInteger)index {
    CAShapeLayer *square = [CAShapeLayer layer];
    square.path = [self bezierPathWithSize:size].CGPath;
    square.frame = CGPathGetBoundingBox(square.path);
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forLayer:square];
    return square;
}

- (UIBezierPath *)bezierPathWithSize:(CGSize)size {
    return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                      cornerRadius:[self cornerRadiusForSize:size]];
}

- (CGFloat)cornerRadiusForSize:(CGSize)size {
    return size.width / 4;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forLayer:(CALayer *)layer {
    CGPoint newPoint = CGPointMake(layer.bounds.size.width * anchorPoint.x,
                                   layer.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(layer.bounds.size.width * layer.anchorPoint.x,
                                   layer.bounds.size.height * layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, layer.affineTransform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, layer.affineTransform);
    
    CGPoint position = layer.position;
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    layer.position = position;
    layer.anchorPoint = anchorPoint;
}

- (void)setZPositionOfShape:(CAShapeLayer *)shape z:(CGFloat)z {
    shape.zPosition = z * (-20);
}

- (void)centerInSuperLayer {
    self.frame = CGRectMake([self getX],
                            [self getY],
                            self.size.width,
                            self.size.height);
}

- (void)rotateToDegree:(CGFloat)degree {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34;
    transform = CATransform3DRotate(transform, DEGREES_TO_RADIANS(degree), 1, 0, 0);
    self.transform = transform;
}

- (CGFloat)getX {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    return (screenWidth / 2) - (self.size.width / 2);
}

- (CGFloat)getY {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    return (screenHeight / 2) - (2 * (self.size.height / 2));
}

@end
