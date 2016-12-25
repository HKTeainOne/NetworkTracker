//
//  HTTPModel.h
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTHTTPModel : NSObject

@property (nonatomic, copy, nullable) NSString *startDateString;
@property (nonatomic, strong, nullable) NSDate *startTime;
@property (nonatomic, strong, nullable) NSDate *endTime;
@property (nonatomic, assign) NSTimeInterval duration; //单位秒

//request
@property (nonatomic, strong, nullable) NSURL *requestURL;
@property (nonatomic, copy, nullable) NSString *requestURLString;
@property (nonatomic, copy, nullable) NSString *requestCachePolicy;
@property (nonatomic, assign) double requestTimeoutInterval;
@property (nonatomic, copy, nullable) NSString *requestHTTPMethod;
@property (nonatomic, copy, nullable) NSString *requestAllHTTPHeaderFields;
@property (nonatomic, copy, nullable) NSString *requestHTTPBody;

//response
@property (nonatomic, copy, nullable) NSString *responseMIMEType;
@property (nonatomic, assign) long long responseExpectedContentLength;
@property (nonatomic, copy, nullable) NSString *responseContentLengthString;
@property (nonatomic, copy, nullable) NSString *responseTextEncodingName;
@property (nonatomic, copy, nullable) NSString *responseSuggestedFilename;
@property (nonatomic, copy, nullable) NSString *responseStatusCode;
@property (nonatomic, copy, nullable) NSString *responseAllHeaderFields;

//responseData
@property (nonatomic, copy, nullable) NSString *responseHTTPBody;


- (void)setRequset:(nonnull NSURLRequest *)request;
- (void)setResponse:(nonnull NSHTTPURLResponse *)response;
- (void)setData:(nonnull NSData *)data;

@end
