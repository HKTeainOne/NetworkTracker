//
//  HTTPModel.m
//  NetworkTracker
//
//  Created by LiQiu Yu on 16/2/17.
//  Copyright © 2016年 LiQiu Yu. All rights reserved.
//

#import "NTHTTPModel.h"
#import "NTTrackerManager.h"

@implementation NTHTTPModel

- (void)setRequset:(NSURLRequest *)request {
    self.requestURL = request.URL;
    self.requestURLString = request.URL.absoluteString;
    self.requestHTTPMethod = request.HTTPMethod;
    self.requestHTTPBody = [[NSString alloc]initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    self.requestTimeoutInterval = request.timeoutInterval;
    
    switch (request.cachePolicy) {
        case 0:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 1:
            self.requestCachePolicy=@"NSURLRequestReloadIgnoringLocalCacheData";
            break;
        case 2:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataElseLoad";
            break;
        case 3:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataDontLoad";
            break;
        case 4:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 5:
            self.requestCachePolicy=@"NSURLRequestReloadRevalidatingCacheData";
            break;
        default:
            self.requestCachePolicy=@"";
            break;
    }
    
    for (NSString *key in [request.allHTTPHeaderFields allKeys]) {
        self.requestAllHTTPHeaderFields=[NSString stringWithFormat:@"%@%@:%@\n",self.requestAllHTTPHeaderFields,key,[request.allHTTPHeaderFields objectForKey:key]];
    }
    if (self.requestAllHTTPHeaderFields.length>1) {
        if ([[self.requestAllHTTPHeaderFields substringFromIndex:self.requestAllHTTPHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringToIndex:self.requestAllHTTPHeaderFields.length-1];
        }
    }
    if (self.requestAllHTTPHeaderFields.length>6) {
        if ([[self.requestAllHTTPHeaderFields substringToIndex:6] isEqualToString:@"(null)"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringFromIndex:6];
        }
    }

}

- (void)setResponse:(NSHTTPURLResponse *)response {
    self.responseStatusCode = [NSString stringWithFormat:@"%ld",(long)response.statusCode];
    self.responseMIMEType = response.MIMEType;
    self.responseTextEncodingName = response.textEncodingName;
    self.responseSuggestedFilename = response.suggestedFilename;
    
    long long contentLength = response.expectedContentLength >= 0 ? response.expectedContentLength : 0;
    self.responseExpectedContentLength = contentLength;
    
    if (contentLength >= 1024*1024) {
        self.responseContentLengthString = [NSString stringWithFormat:@"%0.1fM",contentLength/1024/1024.0];
    } else if (contentLength >= 1024 && contentLength < 1024*1024 ) {
        self.responseContentLengthString = [NSString stringWithFormat:@"%0.1fKB",contentLength/1024.0];
    } else {
        self.responseContentLengthString = [NSString stringWithFormat:@"%lldbyte",contentLength];
    }
}

- (void)setData:(NSData *)data {
    NSString *mimeType = self.responseMIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        self.responseHTTPBody = [self responseJSONFromData:data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        // try to parse json if it is jsonp request
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        // formalize string
        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2; // removes parens and trailing semicolon
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                self.responseHTTPBody = [self responseJSONFromData:jsonData];
            }
        }
        
    }else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            self.responseHTTPBody = xmlString;
        }
    }else if ([mimeType isEqualToString:@"text/html"]) {
        NSString *htmlString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (htmlString && htmlString.length>0) {
            self.responseHTTPBody = htmlString;
        }
    }else if ([mimeType rangeOfString:@"image"].location != NSNotFound)  {
        
    }
    self.duration = (_endTime.timeIntervalSince1970 - _startTime.timeIntervalSince1970);
    self.startDateString = [[NTTrackerManager defaultDateFormatter] stringFromDate:_startTime];
}

#pragma mark - Utils

-(id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        return nil;
    }
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end
