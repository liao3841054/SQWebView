//
//  SQWebViewConfig.h
//  pro
//
//  Created by liaoyp on 2018/1/19.
//  Copyright © 2018年 Roylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebViewConfiguration.h>

@interface SQWebViewConfig : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (SQWebViewConfig *)sharedConfig;

/**
  Specified host cookie synchronization to WkWebView；Default is nil ，Otherwise it will not working; eg： @[@".sqkb.com",@".ibatang.com"];
 */
@property (nonatomic ,strong) NSArray *wkCookiesHostArray;

/**
 WKWebView init configuration ；Default nil
 */
@property (nonatomic ,strong) WKWebViewConfiguration *configuration;

/**
 use JavascriptBridge lib with alibity;  Default NO
 */
@property (nonatomic ,assign) BOOL enableUseJavascriptBridge;

/**
 Default Cookie same as WebView cookie
 */
@property (nonatomic ,strong) NSString *wkDefaultConfigurationCookie;

/**
 WKWebView alert title; Default: 省钱快报
 */
@property (nonatomic ,strong) NSString *wkDefaultAlertTitle;


@end
