//
//  UIColor+Utilities.h
//  WhirlAnimation
//
//  Created by ivanSamalazau on 11.8.16.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HSBAComponent) {
    HSBAComponentHue,
    HSBAComponentSaturation,
    HSBAComponentBrightness,
    HSBAComponentAlpha,
};


@interface UIColor (Utilities)

@property (nonatomic, assign, readonly) CGFloat red;
@property (nonatomic, assign, readonly) CGFloat green;
@property (nonatomic, assign, readonly) CGFloat blue;
@property (nonatomic, assign, readonly) CGFloat alpha;

- (UIColor *)waSetHueSaturationOrBrightness:(HSBAComponent)hsb percentage:(CGFloat)percentage;

+ (instancetype)waColorWithRGBHex:(long)code;
+ (instancetype)waColorWithRGBHex:(long)code alpha:(float)alpha;

@end
