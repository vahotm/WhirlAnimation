//
//  WhirlAnimationLayer.h
//  WhirlAnimation
//
//  Created by ivanSamalazau on 11.8.16.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface WhirlAnimationLayer : CATransformLayer

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign, readonly) BOOL isAnimating;

- (instancetype)initWithNumberOfItems:(NSInteger)items;
- (void)startAnimating;
- (void)stopAnimating;

@end
