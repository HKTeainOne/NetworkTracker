//
//  NTHTTPWindow.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTHTTPWindow.h"

@implementation NTHTTPWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];

        self.windowLevel = UIWindowLevelStatusBar + 100;
    }
    
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([_touchesDelegate window:self shouldReceiveTouchAtPoint:point]) {
        return [super pointInside:point withEvent:event];
    }
    
    return NO;
}


- (BOOL)_canAffectStatusBarAppearance
{
    return NO;
}

- (BOOL)_canBecomeKeyWindow
{
    return NO;
}


@end
