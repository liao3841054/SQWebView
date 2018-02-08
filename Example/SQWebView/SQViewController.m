//
//  SQViewController.m
//  SQWebView
//
//  Created by 251180323@qq.com on 02/08/2018.
//  Copyright (c) 2018 251180323@qq.com. All rights reserved.
//

#import "SQViewController.h"
#import "SQWebViewController.h"

@interface SQViewController ()

@end

@implementation SQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"WebView Demo";
    
    UIButton *webButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [webButton setTitle:@"Web" forState:UIControlStateNormal];
    [webButton setFrame:CGRectMake(100, 100, 100, 40)];
    [webButton setBackgroundColor:[UIColor blackColor]];
    [webButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:webButton];
    
}

- (void)buttonClicked:(UIButton *)button{
    
    SQWebViewController *webVc = [[SQWebViewController alloc] init];
    [self.navigationController pushViewController:webVc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
