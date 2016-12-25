//
//  ProxyDelegate.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTProxyDelegate.h"
#import "NTTrackerManager.h"
#import <objc/runtime.h>

@interface NSURLRequest (NTData)
@property (nonatomic, strong) NSDate *startTime;
@end

@implementation NSURLRequest (NTData)
- (void)setStartTime:(NSDate *)startTime {
    objc_setAssociatedObject(self, @selector(startTime), startTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)startTime {
    return objc_getAssociatedObject(self, _cmd);
}
@end

@interface NSURLSessionTask (NTData)
@property (nonatomic, strong) NSMutableData *responseData;
@end

@implementation NSURLSessionTask (NTData)
- (void)setResponseData:(NSMutableData*)data {
    objc_setAssociatedObject(self, @selector(responseData), data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableData *)responseData {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)xzj_resume {
    self.originalRequest.startTime = [NSDate date];
    
    [self xzj_resume];
}
@end



@interface NTProxyDelegate ()

@property (nonatomic, strong) NSMutableData *data;

@end

@implementation NTProxyDelegate

- (instancetype)init {
    if (self = [super init]) {
        _httpModel = [NTHTTPModel new];
        _data = [NSMutableData data];
        NSLog(@"ProxyDelegate init");
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(connection:didReceiveResponse:)) {
        return YES;
    }
    if (aSelector == @selector(connection:didReceiveResponse:)) {
        return YES;
    }
    if (aSelector == @selector(connectionDidFinishLoading:)) {
        return YES;
    }
    if (aSelector == @selector(URLSession:dataTask:didReceiveData:)) {
        return YES;
    }
//    if (aSelector == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
//        return YES;
//    }
    if (aSelector == @selector(URLSession:task:didCompleteWithError:)) {
        return YES;
    }
    return [self.hookDelegate respondsToSelector:aSelector] ;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.hookDelegate methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.hookDelegate];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)saveModel {
    [_httpModel setEndTime:[NSDate date]];
    [_httpModel setResponse:self.response];
    [_httpModel setData:self.data];
    
    [[NTTrackerManager manager] addHTTPModel:_httpModel];
}



#pragma mark - NSURLConnectionDataDelgate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = (NSHTTPURLResponse *)response;
    if ([self.hookDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.hookDelegate connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
    if ([self.hookDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.hookDelegate connection:connection didReceiveData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self saveModel];
    
    if ([self.hookDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.hookDelegate connectionDidFinishLoading:connection];
    }
}

#pragma mark - NSURLSessionDataDelegate
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
//    self.response = (NSHTTPURLResponse *)response;
//    completionHandler(NSURLSessionResponseAllow);
//    
//    if ([self.hookDelegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
//        [self.hookDelegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
//    }
//}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!dataTask.responseData) {
        dataTask.responseData = [NSMutableData data];
    }
    [dataTask.responseData appendData:data];
    if ([self.hookDelegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [self.hookDelegate URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        NTHTTPModel *model = [NTHTTPModel new];
        model.endTime = [NSDate date];
        
        model.startTime = task.originalRequest.startTime;
        [model setRequset:task.originalRequest];
        [model setResponse:(NSHTTPURLResponse *)task.response];
        [model setData:task.responseData];
        
        [[NTTrackerManager manager] addHTTPModel:model];
    }
    
    if ([self.hookDelegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [self.hookDelegate URLSession:session task:task didCompleteWithError:error];
    }
    [session setProxyDelegate:nil];
}
@end
