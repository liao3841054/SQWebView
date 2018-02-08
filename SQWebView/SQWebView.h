//
//  SQWebView.h
//  coupon
//
//  Created by liaoyp on 2017/11/22.
//  Copyright © 2017年 Roylee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

typedef NS_ENUM(NSInteger, SQWebViewType) {
    SQWebViewTypeWebView,
    SQWebViewTypeWKWebView,
};

@class SQWebView;

@protocol SQWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(SQWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(SQWebView *)webView;
- (void)webViewDidFinishLoad:(SQWebView *)webView;
- (void)webView:(SQWebView *)webView didFailLoadWithError:(NSError *)error;

@end

typedef void(^JavaScriptCompletionBlock)(NSString *result, NSError *error);


@interface SQWebView : UIView

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)initXWebViewWithWebType:(SQWebViewType)type;
+ (instancetype)initXWebViewWithWebType:(SQWebViewType)type withFrame:(CGRect)frame;

@property (nonatomic, assign) id <SQWebViewDelegate> delegate;
@property (nonatomic, readonly, strong) UIScrollView *scrollView;
@property (nonatomic, readonly, assign) SQWebViewType webType;

- (void)loadRequest:(NSURLRequest *)request;

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

@property (nonatomic, readonly, strong) NSURLRequest *request;

- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;


/**
 WKWebView Reload register cookie
 */
- (void)wkReloadUserCookie;

/*
 */
- (NSString *)title;


/**
 evaluate JavaScript code

 @param script js code
 @param block completion call back
 */
- (void)evaluateJavaScriptFromString:(NSString *)script completionBlock:(JavaScriptCompletionBlock)block;

#pragma mark - JavascriptBridgeAction

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)removeHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)disableJavscriptAlertBoxSafetyTimeout;

@end
