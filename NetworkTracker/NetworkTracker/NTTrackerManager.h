//
//  TrackerManager.h
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTHTTPModel;
@class NTProxyDelegate;

@interface NSURLSession (xzj_networkTracker)

@property (nonatomic, strong) NTProxyDelegate *proxyDelegate;

- (void)setProxyDelegate:(NTProxyDelegate *)proxyDelegate;
- (NTProxyDelegate *)proxyDelegate;

@end

@interface NTTrackerManager : NSObject

@property (nonatomic, assign) BOOL trackingWebView;

+ (instancetype)manager;
- (void)enable;

- (void)addHTTPModel:(NTHTTPModel *)model;
- (NSArray *)getHTTPModels;

+ (NSDateFormatter *)defaultDateFormatter;

- (void)presentHTTPRequestsViewController;
- (void)presentHTTPFloatingButtonViewController;

@end
