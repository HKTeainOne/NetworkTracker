//
//  NTHTTPFloatingButtonController.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTHTTPFloatingButtonController.h"
#import "NTTrackerManager.h"

@interface NTHTTPFloatingButtonController ()
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation NTHTTPFloatingButtonController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2, 44, 44);
    _button.backgroundColor = [UIColor grayColor];
    [_button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan)];
    _panGestureRecognizer.minimumNumberOfTouches = 1;
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

- (void)tap {
    [[NTTrackerManager manager] presentHTTPRequestsViewController];
}

- (void)pan {
    CGPoint translation = [_panGestureRecognizer translationInView:self.view];
    
    CGPoint center = _button.center;
    center.x += translation.x;
    center.y += translation.y;
    
    CGFloat centerHeightOffset = NTRoundPixelValue(CGRectGetHeight(_button.frame) / 2.0);
    CGFloat centerWidthOffset = NTRoundPixelValue(CGRectGetWidth(_button.frame) / 2.0);
    
    if (center.y - centerHeightOffset < 0) {
        center.y = centerHeightOffset;
    }
    if (center.x - centerWidthOffset < 0) {
        center.x = centerWidthOffset;
    }
    
    CGFloat maximumY = CGRectGetHeight(self.view.bounds) -  CGRectGetHeight(_button.frame);
    if (center.y - centerHeightOffset > maximumY) {
        center.y = maximumY + centerHeightOffset;
    }
    
    CGFloat maximumX = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(_button.frame);
    if (center.x - centerWidthOffset > maximumX) {
        center.x = maximumX + centerWidthOffset;
    }
    _button.center = center;
    
    [_panGestureRecognizer setTranslation:CGPointZero inView:self.view];
}

CGFloat NTRoundPixelValue(CGFloat value) {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return roundf(value * scale) / scale;
}
@end
