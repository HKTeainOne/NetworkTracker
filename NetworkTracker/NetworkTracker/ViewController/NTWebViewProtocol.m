//
//  NTWebViewProtocol.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTWebViewProtocol.h"

static NSPredicate *webViewUserAgentTest;

@interface NTWebViewProtocol ()
@property (nonatomic, strong) NSURLConnection *connection;
@end

@implementation NTWebViewProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString* userAgent = request.allHTTPHeaderFields[@"User-Agent"];
    if (!userAgent) {
        return NO;
    }
    if (!webViewUserAgentTest) {
        webViewUserAgentTest = [NSPredicate predicateWithFormat:@"self MATCHES '^Mozilla.*Mac OS X.*'"];
        NSLog(@"webViewUserAgentTest");
    }
    if (userAgent && ![webViewUserAgentTest evaluateWithObject:userAgent]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:@"NTWebViewProtocol" inRequest:request] ) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:@"NTWebViewProtocol"
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil){
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

@end
