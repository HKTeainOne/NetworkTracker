//
//  ViewController.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "ViewController.h"

#import <objc/runtime.h>
#import <AFNetworking.h>

#import "NTTrackerManager.h"

@interface ViewController ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

#pragma clang diagnostic ignored "-Wunused-variable"  

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _url = [NSURL URLWithString:@"http://www.oschina.net/action/api/news_list?catalog=1&pageIndex=0&pageSize=20"];
    _request = [NSURLRequest requestWithURL:_url];
    
//    NSURLRequest *webViewRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.github.com"]];
//    [_webView loadRequest:webViewRequest];
//    NSURLSession *session = [NSURLSession sharedSession];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (IBAction)URLconnection_sendAsy:(id)sender {

    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data) {
//            NSLog(@"%@",data);
        }
    }];
}

- (IBAction)URLconnection_sendSyn:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response = nil;
        NSError *error;
        [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
        if (error) {
//            NSLog(@"%@",error);
        }
    });
}
- (IBAction)URLconnection_initConnection:(id)sender {
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:_request delegate:self];
//    [NSURLConnection connectionWithRequest:_request delegate:self];
}
#pragma clang diagnostic pop

- (IBAction)URLsession:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org/get?test=helloWorld"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *urlsession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *datatask =[urlsession dataTaskWithURL:url];
    
    [datatask resume];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [urlsession invalidateAndCancel];
    });
}
- (IBAction)URLSessionWithHandler:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.oschina.net/action/api/news_list?catalog=1&pageIndex=0&pageSize=20"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *urlsession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    //    NSURLSession *urlsession = [NSURLSession sessionWithConfiguration:config];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *datatask = [urlsession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            NSLog(@"error: %@", error);
        }
        else {
            NSLog(@"Success");
        }
        [urlsession invalidateAndCancel];
    }];
    [datatask resume];
}

- (IBAction)URLSessionDownload:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://xmind-dl.oss-cn-qingdao.aliyuncs.com/xmind-7-update1-macosx.dmg"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlsession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    
    NSURLSessionDownloadTask *downloadTask = [urlsession downloadTaskWithURL:url];
    [downloadTask resume];
    
}
- (IBAction)AFNetworking:(id)sender {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://www.oschina.net/action/api/news_list"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
//            NSLog(@"Error: %@", error);
        } else {
//            NSLog(@"%@ %@", response, responseObject);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }];
    [dataTask resume];
}
- (IBAction)showVC:(id)sender {
    [[NTTrackerManager manager] presentHTTPRequestsViewController];
}

#pragma mark - NSURLConnectionDelegate

- (nullable NSURLRequest*)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    return request;
}

- (nullable NSCachedURLResponse*)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [session invalidateAndCancel];
}

@end
