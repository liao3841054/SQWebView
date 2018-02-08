//
//  SQWebView.m
//  coupon
//
//  Created by liaoyp on 2017/11/22.
//  Copyright © 2017年 Roylee. All rights reserved.
//

#import "SQWebView.h"
#import "SQWebViewConfig.h"
#import "SQWKCookieUtils.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

@protocol BTWebViewJavascriptBridgeDelegate <NSObject>

@optional
+ (instancetype)bridgeForWebView:(id)webView;
+ (instancetype)bridge:(id)webView;

+ (void)enableLogging;
+ (void)setLogMaxLength:(int)length;

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)removeHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)setWebViewDelegate:(id)webViewDelegate;
- (void)disableJavscriptAlertBoxSafetyTimeout;

@end

@interface BTWebViewJavascriptBridge : NSObject<BTWebViewJavascriptBridgeDelegate>
@end

@implementation BTWebViewJavascriptBridge
@end

@interface SQWebView() <UIWebViewDelegate, WKNavigationDelegate,WKUIDelegate>
{
    
}
@property (nonatomic, assign) SQWebViewType webType;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) WKWebViewConfiguration *wkWebViewConfig;
@property (nonatomic, strong) BTWebViewJavascriptBridge *btJavascriptBridge;
@property (nonatomic, strong) NSString *title;

@end

@implementation SQWebView

+ (instancetype)initXWebViewWithWebType:(SQWebViewType)type
{
    
    CGRect mianFrame = [UIScreen mainScreen].bounds;
    CGFloat kNavigationHeight = 64;
    
    SQWebView *webView = [[SQWebView alloc] initWithFrame:CGRectMake(0, kNavigationHeight, CGRectGetWidth(mianFrame), CGRectGetHeight(mianFrame) - kNavigationHeight) webType:type];
    return webView;
}

+ (instancetype)initXWebViewWithWebType:(SQWebViewType)type withFrame:(CGRect)frame
{
    SQWebView *webView = [[SQWebView alloc] initWithFrame:frame webType:type];
    return webView;
}

- (instancetype)initWithFrame:(CGRect)frame webType:(SQWebViewType)webtype
{
    self = [super initWithFrame:frame];
    if (self) {
        _webType = webtype;
        [self setUpInit];
    }
    return self;
}

- (void)setUpInit
{    
    if (_webType == SQWebViewTypeWKWebView) {
        // WKWebView
        [self configureWKWebView];
    }
    else {
        [self configureWebView];
    }
}

- (SQWebViewType)webType
{
    return _webType;
}

- (void)configureWebView {
    
    _webView = [[UIWebView alloc] initWithFrame:self.frame];
    _webView.delegate = self;
    _webView.suppressesIncrementalRendering = YES;
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_webView];
    
    [self SQ_initWebViewJavascriptBridge];
}

- (void)configureWKWebView {
    
    self.wkWebViewConfig = [SQWebViewConfig sharedConfig].configuration;
    if (!self.wkWebViewConfig) {
        WKUserContentController* userContentController = [WKUserContentController new];
        NSString *cookies = [SQWKCookieUtils sq_detaultDocumentCookie];
        WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:[cookies copy]
                                                             injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                          forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
        
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.allowsInlineMediaPlayback = YES;
        configuration.mediaPlaybackRequiresUserAction = NO;
        configuration.processPool = [[WKProcessPool alloc] init];
        configuration.userContentController = userContentController;
        self.wkWebViewConfig = configuration;
    }
    
    _wkWebView = [[WKWebView alloc] initWithFrame:self.frame configuration:self.wkWebViewConfig];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    _wkWebView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_wkWebView];
   
    
    [self SQ_initWebViewJavascriptBridge];
}

- (void)SQ_initWebViewJavascriptBridge
{
    if (![SQWebViewConfig sharedConfig].enableUseJavascriptBridge) {
        return;
    }
    
    switch (_webType) {
        case SQWebViewTypeWebView:
        {
            WebViewJavascriptBridge *javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
            [javascriptBridge setWebViewDelegate:self];
            _btJavascriptBridge = (id)javascriptBridge;
        }
           break;
        case SQWebViewTypeWKWebView:
        {
            WKWebViewJavascriptBridge *javascriptBridge = [WKWebViewJavascriptBridge bridgeForWebView:_wkWebView];
            [javascriptBridge setWebViewDelegate:self];
            _btJavascriptBridge = (id)javascriptBridge;
        }
            break;
        default:
            break;
    }
}

- (NSMutableURLRequest *)addCookieWithRequest:(NSURLRequest *)originalRequest
{
    NSMutableURLRequest *request = [originalRequest mutableCopy];
    NSString *cookies = [SQWKCookieUtils sq_cookieWithRequest:request];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:[cookies copy]
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                      forMainFrameOnly:NO];
    [_wkWebView.configuration.userContentController addUserScript:cookieScript];
    
    return request;
}


- (void)wkReloadUserCookie
{
    NSString *cookies = [SQWKCookieUtils sq_detaultDocumentCookie];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:[cookies copy]
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                      forMainFrameOnly:NO];
    [_wkWebView.configuration.userContentController addUserScript:cookieScript];
    
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _webView.frame = self.bounds;
    _wkWebView.frame = self.bounds;
}


#pragma mark - private

- (UIScrollView *)scrollView
{
    if (self.webView) {
       return  self.webView.scrollView;
    }
    
    if (self.wkWebView) {
       return  self.wkWebView.scrollView;
    }
    return nil;
}

- (void)loadRequest:(NSURLRequest *)request
{
    if (self.webView) {
        [self.webView loadRequest:request];
    }
    if (self.wkWebView) {
        
        request = [self addCookieWithRequest:request];
        
        [self.wkWebView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if (self.webView) {
        [self.webView loadHTMLString:string baseURL:baseURL];
    }
    if (self.wkWebView) {
        [self.wkWebView loadHTMLString:string baseURL:baseURL];
    }
}

- (NSURLRequest *)request
{
    if (self.webView) {
        return [self.webView request];
    }
    if (self.wkWebView) {
        return [[NSURLRequest alloc] initWithURL:self.wkWebView.URL];
    }
    return nil;
}

- (void)reload
{
    if (self.webView) {
        [self.webView reload];
    }
    if (self.wkWebView) {
        [self.wkWebView reload];
    }
}
- (void)stopLoading
{
    if (self.webView) {
        [self.webView stopLoading];
    }
    if (self.wkWebView) {
        [self.wkWebView stopLoading];
    }
}

- (void)goBack{
    if (self.webView) {
        [self.webView goBack];
    }
    if (self.wkWebView) {
        [self.wkWebView goBack];
    }
}

- (void)goForward
{
    if (self.webView) {
        [self.webView goForward];
    }
    if (self.wkWebView) {
        [self.wkWebView goForward];
    }
}

- (BOOL)canGoBack
{
    if (self.webView) {
        return [self.webView canGoBack];
    }
    if (self.wkWebView) {
       return [self.wkWebView canGoBack];
    }
    return NO;
}

- (BOOL)canGoForward
{
    if (self.webView) {
        return [self.webView canGoForward];
    }
    if (self.wkWebView) {
        return [self.wkWebView canGoForward];
    }
    return NO;
}


- (BOOL)isLoading
{
    if (self.webView) {
        return [self.webView isLoading];
    }
    if (self.wkWebView) {
        return [self.wkWebView isLoading];
    }
    return NO;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return  [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}



#pragma mark - WKNavigationDelegate

/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        UIWebViewNavigationType navigationType = [self covrtNavigationType:navigationAction.navigationType];
        BOOL result =  [self.delegate webView:self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationType];
        if (result) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        else
        {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

/*! @abstract Decides whether to allow or cancel a navigation after its
 response is known.
 @param webView The web view invoking the delegate method.
 @param navigationResponse Descriptive information about the navigation
 response.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
 @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
 */
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{
//
//}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (UIWebViewNavigationType)covrtNavigationType:(WKNavigationType)navType
{
    switch (navType) {
        case WKNavigationTypeLinkActivated:
            return UIWebViewNavigationTypeLinkClicked;
            break;
        case WKNavigationTypeFormSubmitted:
            return UIWebViewNavigationTypeFormSubmitted;
            break;
        case WKNavigationTypeBackForward:
            return UIWebViewNavigationTypeBackForward;
            break;
        case WKNavigationTypeFormResubmitted:
            return UIWebViewNavigationTypeFormResubmitted;
            break;
        case WKNavigationTypeReload:
            return UIWebViewNavigationTypeReload;
            break;
        case UIWebViewNavigationTypeOther:
            return UIWebViewNavigationTypeOther;
            break;
        default:
            break;
    }
    return UIWebViewNavigationTypeOther;
}

/**
 修复打开链接Cookie丢失问题
 */
- (NSURLRequest *)fixRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *fixedRequest;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        fixedRequest = (NSMutableURLRequest *)request;
    } else {
        fixedRequest = request.mutableCopy;
    }
    //防止Cookie丢失
    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    
    NSMutableDictionary *mDict = request.allHTTPHeaderFields.mutableCopy;
    [mDict setValuesForKeysWithDictionary:dict];
    fixedRequest.allHTTPHeaderFields = mDict;
    
    return fixedRequest;
}


#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    //这里不打开新窗口
    [self.wkWebView loadRequest:[self fixRequest:navigationAction.request]];
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(nonnull void (^)(void))completionHandler {
    
    //js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SQWebViewConfig sharedConfig].wkDefaultAlertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [[self SQ_topViewController]  presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //[UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@", message];// 复制到剪切板
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SQWebViewConfig sharedConfig].wkDefaultAlertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        completionHandler(NO);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    
    [[self SQ_topViewController] presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    //用于和JS交互，弹出输入框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[SQWebViewConfig sharedConfig].wkDefaultAlertTitle message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        completionHandler(nil);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        completionHandler(textField.text);
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [[self SQ_topViewController] presentViewController:alertController animated:YES completion:^{}];
}

- (UIViewController *)SQ_topViewController
{
    UIWindow *window = [self SQ_keyWindow];
    UIViewController *controller = [window rootViewController];
    return controller;
}

- (UIWindow *)SQ_keyWindow
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    return window;
}

#pragma mark - JavascriptBridgeProxy

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler
{
    if (self.btJavascriptBridge) {
        [self.btJavascriptBridge registerHandler:handlerName handler:handler];
    }
}

- (void)removeHandler:(NSString*)handlerName
{
    if (self.btJavascriptBridge) {
        [self.btJavascriptBridge removeHandler:handlerName];
    }
}

- (void)callHandler:(NSString*)handlerName
{
    if (self.btJavascriptBridge) {
        [self.btJavascriptBridge callHandler:handlerName];
    }
}

- (void)callHandler:(NSString*)handlerName data:(id)data
{
    if (self.btJavascriptBridge) {
        [self.btJavascriptBridge callHandler:handlerName data:data];
    }
}

- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback
{
    if (self.btJavascriptBridge) {
        [self.btJavascriptBridge callHandler:handlerName data:data responseCallback:responseCallback];
    }

}

- (void)setWebViewDelegate:(id)webViewDelegate
{
    if (self.btJavascriptBridge) {
        [self.btJavascriptBridge setWebViewDelegate:webViewDelegate];
    }
}
- (void)disableJavscriptAlertBoxSafetyTimeout
{
    if (self.btJavascriptBridge) {
        [self.btJavascriptBridge disableJavscriptAlertBoxSafetyTimeout];
    }
}

#pragma mark -

- (void)evaluateJavaScriptFromString:(NSString *)script completionBlock:(JavaScriptCompletionBlock)block {
    if (self.webView) {
        NSString *jsResult = [self.webView stringByEvaluatingJavaScriptFromString:script];
        block(jsResult, nil);
    } else {
        NSAssert(self.wkWebView, @"wkWebView 没有初始化 check");
        [self.wkWebView evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
            NSString *jsResult = nil;
            if (!error) {
                if ([result isKindOfClass:[NSString class]]) {
                    jsResult = result;
                } else {
                    jsResult = [NSString stringWithFormat:@"%@", result];
                }
            } else {
                NSLog(@"%@", error);
            }
            
            block(jsResult, error);
        }];
    }
}


@end
