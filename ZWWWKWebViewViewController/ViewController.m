//
//  ViewController.m
//  ZWWWKWebViewViewController
//
//  Created by WW Z on 2017/12/27.
//  Copyright © 2017年 WW Z. All rights reserved.
//

#import "ViewController.h"
#import "DIYProtocol.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)surf:(id)sender {
    [DIYProtocol sharedRequestDIYProtocol].url = @"https://www.so.com";
}

- (IBAction)diyxy0:(id)sender {
    [DIYProtocol sharedRequestDIYProtocol].url = @"XXXAPP://goJobPositionDetail?jobPositionId=1111&jxxxtttttt=23344";
}

- (IBAction)diyxy1:(id)sender {
    [DIYProtocol sharedRequestDIYProtocol].url = @"XXXAPP://goWebView?url=http://baidu.com";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
