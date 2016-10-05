//
//  ViewController.m
//  WhirlAnimation
//
//  Created by ivanSamalazau on 11.8.16.
//

#import "ViewController.h"
#import "WhirlAnimationLayer.h"
#import "UIColor+Utilities.h"


@interface ViewController ()
@property (nonatomic, strong) WhirlAnimationLayer *animationLayer;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor waColorWithRGBHex:0xc59aff];
    self.animationLayer = [[WhirlAnimationLayer alloc] initWithNumberOfItems:10];
    [self.view.layer addSublayer:self.animationLayer];
    self.animationLayer.color = [UIColor waColorWithRGBHex:0x554072];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    if (self.animationLayer.isAnimating) {
        [self.animationLayer stopAnimating];
    }
    else {
        [self.animationLayer startAnimating];
    }
}

@end
