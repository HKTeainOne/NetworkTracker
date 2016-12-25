//
//  NTHTTPWindow.h
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTHTTPWindowTouchesHandling <NSObject>

- (BOOL)window:(nullable UIWindow *)window shouldReceiveTouchAtPoint:(CGPoint)point;

@end

@interface NTHTTPWindow : UIWindow

@property (nonatomic, weak, nullable) id<NTHTTPWindowTouchesHandling> touchesDelegate;

@end

