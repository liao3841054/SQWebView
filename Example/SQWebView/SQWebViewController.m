//
//  SQWebViewController.m
//  SQWebView_Example
//
//  Created by 曹星星 on 2018/2/8.
//  Copyright © 2018年 251180323@qq.com. All rights reserved.
//

#import "SQWebViewController.h"
#import "SQWebView.h"

@interface SQWebViewController ()<SQWebViewDelegate>

@property(nonatomic ,strong)SQWebView *webView;

@end

@implementation SQWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView = [SQWebView initXWebViewWithWebType:SQWebViewTypeWKWebView withFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}

#pragma mark -

- (void)webViewDidFinishLoad:(SQWebView *)webView {
    
    self.title = [webView title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
