//
//  ProxyDelegate.h
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTHTTPModel.h"

@interface NTProxyDelegate : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) id hookDelegate;
@property (nonatomic, strong) NTHTTPModel *httpModel;
@property (nonatomic, strong) NSURLRequest *requset;
@property (nonatomic, strong) NSHTTPURLResponse *response;

@end
