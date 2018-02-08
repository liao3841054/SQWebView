//
//  SQWKCookieUtils.h
//  pro
//
//  Created by liaoyp on 2018/1/19.
//  Copyright © 2018年 Roylee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQWKCookieUtils : NSObject

+ (NSString *)sq_cookieWithRequest:(NSURLRequest *)originalRequest;

+ (NSString *)sq_detaultDocumentCookie;

@end
