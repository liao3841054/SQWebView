//
//  SQWebViewConfig.m
//  pro
//
//  Created by liaoyp on 2018/1/19.
//  Copyright © 2018年 Roylee. All rights reserved.
//

#import "SQWebViewConfig.h"

@implementation SQWebViewConfig

+ (SQWebViewConfig *)sharedConfig {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _wkDefaultAlertTitle = @"警告";
    }
    return self;
}


@end
