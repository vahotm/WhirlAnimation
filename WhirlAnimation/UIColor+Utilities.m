//
//  UIColor+Utilities.m
//  WhirlAnimation
//
//  Created by ivanSamalazau on 11.8.16.
//

#import "UIColor+Utilities.h"

@implementation UIColor (Utilities)

- (UIColor *)waSetHueSaturationOrBrightness:(HSBAComponent)hsb percentage:(CGFloat)percentage {
    UIColor *newColor = nil;
    
    CGFloat hueValue = 0.0;
    CGFloat saturationValue = 0.0;
    CGFloat brightnessValue = 0.0;
    CGFloat alphaValue = 0.0;
    
    [self getHue:&hueValue
      saturation:&saturationValue
      brightness:&brightnessValue
           alpha:&alphaValue];
    
    switch (hsb) {
        case HSBAComponentHue: {
            newColor = [UIColor colorWithHue:hueValue * percentage
                                  saturation:saturationValue
                                  brightness:brightnessValue
                                       alpha:alphaValue];
            break;
        }
        case HSBAComponentSaturation: {
            newColor = [UIColor colorWithHue:hueValue
                                  saturation:saturationValue * percentage
                                  brightness:brightnessValue
                                       alpha:alphaValue];
            break;
        }
        case HSBAComponentBrightness: {
            newColor = [UIColor colorWithHue:hueValue
                                  saturation:saturationValue
                                  brightness:brightnessValue * percentage
                                       alpha:alphaValue];
            break;
        }
        case HSBAComponentAlpha: {
            newColor = [UIColor colorWithHue:hueValue
                                  saturation:saturationValue
                                  brightness:brightnessValue
                                       alpha:alphaValue * percentage];
            break;
        }
    }
    
    return newColor;
}

+ (instancetype)waColorWithRGBHex:(long)code
{
    return [[self class] waColorWithRGBHex:code alpha:1.0];
}

+ (instancetype)waColorWithRGBHex:(long)code alpha:(float)alpha
{
    return [UIColor colorWithRed:((float)((code & 0xFF0000) >> 16))/255.0
                           green:((float)((code & 0xFF00) >> 8))/255.0
                            blue:((float)(code & 0xFF))/255.0
                           alpha:alpha];
}

#pragma mark - Getters

- (CGFloat)red {
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    return components[0];
}

- (CGFloat)green {
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    return components[1];
}

- (CGFloat)blue {
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    return components[2];
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}


@end
