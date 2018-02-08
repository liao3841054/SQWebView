//
//  SQWKCookieUtils.m
//  pro
//
//  Created by liaoyp on 2018/1/19.
//  Copyright © 2018年 Roylee. All rights reserved.
//

#import "SQWKCookieUtils.h"
#import <WebKit/WKUserScript.h>
#import "SQWebViewConfig.h"

@implementation SQWKCookieUtils

+ (NSString *)sq_cookieWithRequest:(NSURLRequest *)originalRequest
{
    NSMutableURLRequest *request = [originalRequest mutableCopy];
    NSString *validDomain = request.URL.host;
    const BOOL requestIsSecure = [request.URL.scheme isEqualToString:@"https"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Don't even bother with values containing a `'`
        if ([cookie.name rangeOfString:@"'"].location != NSNotFound) {
            NSLog(@"Skipping %@ because it contains a '", cookie.properties);
            continue;
        }
        
        // Is the cookie for current domain?
        if (![validDomain hasSuffix:cookie.domain]) {
            NSLog(@"Skipping %@ (because not %@)", cookie.properties, validDomain);
            continue;
        }
        
        // Are we secure only?
        if (cookie.secure && !requestIsSecure) {
            NSLog(@"Skipping %@ (because %@ not secure)", cookie.properties, request.URL.absoluteString);
            continue;
        }
        NSString *value = [NSString stringWithFormat:@"document.cookie='%@=%@;path=%@'", cookie.name, cookie.value,cookie.path];
        [array addObject:value];
    }
    
    NSString *header = [array componentsJoinedByString:@";"];
    return header;
}


+ (NSString *)sq_detaultDocumentCookie
{
    NSMutableString *cookieValue   = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        BOOL isContainsHost = [self containsDefaultHost:cookie.domain];
        if (isContainsHost) {
            NSString *appendString = [NSString stringWithFormat:@"document.cookie='%@=%@;path=/';", cookie.name,cookie.value];
            [cookieValue appendString:appendString];
        }
    }
    return cookieValue;
}


+ (BOOL)containsDefaultHost:(NSString *)validDomain
{
    if(!validDomain)return NO;
    
    __block NSArray *hostArray = [SQWebViewConfig sharedConfig].wkCookiesHostArray;
    __block BOOL isFind = NO;
    [hostArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![validDomain hasSuffix:obj]) {
            isFind = YES;
            *stop = YES;
        }
    }];
    return isFind;
}

@end
