//
//  ViewController.m
//  ZWWWKWebViewViewController
//
//  Created by WW Z on 2017/12/27.
//  Copyright © 2017年 WW Z. All rights reserved.
//

#import "ViewController.h"
#import "ZWWWKWebViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)surf:(id)sender {
    ZWWWKWebViewController *wkWebView = [ZWWWKWebViewController new];
    wkWebView.url = @"https://www.so.com";
    [self.navigationController pushViewController:wkWebView animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
