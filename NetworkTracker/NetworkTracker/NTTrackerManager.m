//
//  TrackerManager.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTTrackerManager.h"
#import "NTProxyDelegate.h"
#import "NTWebViewProtocol.h"
#import "NTHTTPModel.h"
#import "NTHTTPViewController.h"
#import "NTHTTPWindow.h"
#import "NTHTTPFloatingButtonController.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface NSURLConnection (xzj_networkTracker)

@property (nonatomic, strong) NTProxyDelegate *proxyDelegate;

@end

@implementation NSURLConnection(xzj_networkTracker)

- (void)setProxyDelegate:(NTProxyDelegate *)proxyDelegate {
    objc_setAssociatedObject(self, @selector(proxyDelegate), proxyDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NTProxyDelegate *)proxyDelegate {
    NTProxyDelegate *proxyDelegate = objc_getAssociatedObject(self, _cmd);
    return proxyDelegate;
}

- (void)xzj_start {
    self.proxyDelegate.httpModel.startTime = [NSDate date];
    [self xzj_start];
}

- (nullable instancetype)xzj_initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    self.proxyDelegate = [NTProxyDelegate new];
    self.proxyDelegate.hookDelegate = delegate;
    [self.proxyDelegate.httpModel setRequset:request];
    return [self xzj_initWithRequest:request delegate:self.proxyDelegate];
}

- (nullable instancetype)xzj_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
    self.proxyDelegate = [NTProxyDelegate new];
    self.proxyDelegate.hookDelegate = delegate;
    [self.proxyDelegate.httpModel setRequset:request];
    return [self xzj_initWithRequest:request delegate:self.proxyDelegate startImmediately:startImmediately];
}

+ (nullable NSData*)xzj_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error {
    
    NTProxyDelegate *proxyDelegate = [NTProxyDelegate new];
    proxyDelegate.httpModel.startTime = [NSDate date];
    [proxyDelegate.httpModel setRequset:request];
    
    __autoreleasing NSURLResponse *xzj_response;
    NSData *resultData;

    resultData = [self xzj_sendSynchronousRequest:request returningResponse:&xzj_response error:error];
    [proxyDelegate.httpModel setResponse:(NSHTTPURLResponse *)xzj_response];
    proxyDelegate.httpModel.endTime = [NSDate date];
    [proxyDelegate.httpModel setData:resultData];
    [[NTTrackerManager manager] addHTTPModel:proxyDelegate.httpModel];
    
    if (response) {
        *response = xzj_response;
    }
    
    return resultData;
}

+ (void)xzj_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse * _Nullable, NSData * _Nullable, NSError * _Nullable))handler {
    
    NTProxyDelegate *proxyDelegate = [NTProxyDelegate new];
    proxyDelegate.httpModel.startTime = [NSDate date];
    [proxyDelegate.httpModel setRequset:request];
    
    void (^xzj_completionHandler)(NSURLResponse * _Nullable, NSData * _Nullable, NSError * _Nullable) = ^void(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            proxyDelegate.httpModel.endTime = [NSDate date];
            [proxyDelegate.httpModel setResponse:(NSHTTPURLResponse *)response];
            [proxyDelegate.httpModel setData:data];
            [[NTTrackerManager manager] addHTTPModel:proxyDelegate.httpModel];
        }
        
        handler(response, data, error);
    };
    
    return [self xzj_sendAsynchronousRequest:request queue:queue completionHandler:xzj_completionHandler];
}

@end

#pragma mark -

@implementation NSURLSession (xzj_networkTracker)

- (void)setProxyDelegate:(NTProxyDelegate *)proxyDelegate {
    objc_setAssociatedObject(self, @selector(proxyDelegate), proxyDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NTProxyDelegate *)proxyDelegate {
    NTProxyDelegate *proxyDelegate = objc_getAssociatedObject(self, _cmd);
    return proxyDelegate;
}

+ (NSURLSession *)xzj_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    if (delegate) {
        NTProxyDelegate *proxyDelegate = [NTProxyDelegate new];
        proxyDelegate.hookDelegate = delegate;
        NSURLSession *session = [self xzj_sessionWithConfiguration:configuration delegate:proxyDelegate delegateQueue:queue];
        session.proxyDelegate = proxyDelegate;
        
        return session;
    }
    
    return [self xzj_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

- (NSURLSessionDataTask *)xzj_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    if (completionHandler) {
        NTHTTPModel *model = [NTHTTPModel new];
        model.startTime = [NSDate date];
        [model setRequset:request];
        void (^xzj_completionHandler)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                model.endTime = [NSDate date];
                [model setResponse:(NSHTTPURLResponse *)response];
                [model setData:data];
                [[NTTrackerManager manager] addHTTPModel:model];
            }
            completionHandler(data, response, error);
        };
        
        return [self xzj_dataTaskWithRequest:request completionHandler:xzj_completionHandler];
    }
    return [self xzj_dataTaskWithRequest:request completionHandler:completionHandler];

}

@end

#pragma mark -

@interface NTTrackerManager ()<NTHTTPWindowTouchesHandling>

@property (nonatomic, strong) NSMutableArray *HTTPModels;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NTHTTPWindow *httpWindow;
@property (nonatomic, strong) NTHTTPFloatingButtonController *floatingButtonController;

@end

@implementation NTTrackerManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static NTTrackerManager *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        sharedObject = [[NTTrackerManager alloc] init];
    });
    return sharedObject;
}

- (instancetype)init {
    if (self = [super init]) {
        _HTTPModels = [NSMutableArray array];
        _lock = [[NSLock alloc]init];
        
        _trackingWebView = YES;
    }
    return self;
}

- (void)enable {
    
    [self swizzle];
    [self setupFloatingButton];
    
    if (_trackingWebView) {
        [NSURLProtocol registerClass:[NTWebViewProtocol class]];
    }
}

- (void)swizzle {
    //NSURLConection
    [self swizzleSEL:@selector(start)
             withSEL:@selector(xzj_start)
           withClass:[NSURLConnection class]];
    
    [self swizzleSEL:@selector(initWithRequest:delegate:)
             withSEL:@selector(xzj_initWithRequest:delegate:)
           withClass:[NSURLConnection class]];
    
    [self swizzleSEL:@selector(initWithRequest:delegate:startImmediately:)
             withSEL:@selector(xzj_initWithRequest:delegate:startImmediately:)
           withClass:[NSURLConnection class]];
    
    [self swizzleSEL:@selector(sendSynchronousRequest:returningResponse:error:)
             withSEL:@selector(xzj_sendSynchronousRequest:returningResponse:error:)
           withClass:objc_getMetaClass("NSURLConnection")];
    
    [self swizzleSEL:@selector(sendAsynchronousRequest:queue:completionHandler:)
             withSEL:@selector(xzj_sendAsynchronousRequest:queue:completionHandler:)
           withClass:objc_getMetaClass("NSURLConnection")];
    
//    [self swizzleSEL:sel_registerName("dealloc")
//             withSEL:@selector(xzjcoonection_dealloc)
//           withClass:[NSURLConnection class]];
    
    //NSURLSession
    [self swizzleSEL:@selector(sessionWithConfiguration:delegate:delegateQueue:)
             withSEL:@selector(xzj_sessionWithConfiguration:delegate:delegateQueue:)
           withClass:objc_getMetaClass("NSURLSession")];
    
    [self swizzleSEL:@selector(dataTaskWithRequest:completionHandler:)
             withSEL:@selector(xzj_dataTaskWithRequest:completionHandler:)
           withClass:[NSURLSession class]];
    
//    [self swizzleSEL:sel_registerName("dealloc")
//             withSEL:@selector(xzj_dealloc)
//           withClass:[NSURLSession class]];

    //NSURLSessionTask
    [self swizzleSEL:@selector(resume)
             withSEL:@selector(xzj_resume)
           withClass:objc_getClass("__NSCFLocalDataTask")];
}

- (void)unswizzle {
    
}

- (void)setupFloatingButton {
    _floatingButtonController = [[NTHTTPFloatingButtonController alloc] init];
    
    _httpWindow = [[NTHTTPWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _httpWindow.touchesDelegate = self;
    _httpWindow.rootViewController = _floatingButtonController;
    _httpWindow.hidden = NO;
}

#pragma mark -

- (void)addHTTPModel:(NTHTTPModel *)model {
    [_lock lock];
    [_HTTPModels insertObject:model atIndex:0];
    [_lock unlock];
}

- (NSArray *)getHTTPModels {
    [_lock lock];
    NSArray *array = [_HTTPModels copy];
    [_lock unlock];
    return array;
}

- (void)presentHTTPRequestsViewController {
    NTHTTPViewController *viewController = [[NTHTTPViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    _httpWindow.hidden = YES;
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:nav animated:YES completion:nil];
}

- (void)presentHTTPFloatingButtonViewController {
    _httpWindow.hidden = NO;
}

#pragma mark - Utils

- (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL withClass:(Class)class {
    Method originalMethod = class_getInstanceMethod(class, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return staticDateFormatter;
}

#pragma mark - NTHTTPWindowTouchesHandling
- (BOOL)window:(UIWindow *)window shouldReceiveTouchAtPoint:(CGPoint)point {
    return CGRectContainsPoint(_floatingButtonController.button.bounds,
                               [_floatingButtonController.button convertPoint:point
                                                                 fromView:window]);
}

@end


