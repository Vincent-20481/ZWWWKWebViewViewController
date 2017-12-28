//
//  DIYProtocol.m
//  ZWWWKWebViewViewController
//
//  Created by WW Z on 2017/12/27.
//  Copyright © 2017年 WW Z. All rights reserved.
//

#import "DIYProtocol.h"

@implementation DIYProtocol

+ (instancetype)sharedRequestDIYProtocol{
    static DIYProtocol * diyProtocol;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        diyProtocol = [[self alloc]init];
    });
    return diyProtocol;
}

- (void)setUrl:(NSString *)url{
    NSURL *baseUrl = [NSURL URLWithString:url];
    if ([baseUrl.scheme isEqualToString:@"http"]||[baseUrl.scheme isEqualToString:@"https"]) {
        ZWWWKWebViewController *wkWebView= [ZWWWKWebViewController new];
        wkWebView.url = url;
        UIViewController *viewSelf = kWindow.rootViewController;
        [viewSelf.navigationController pushViewController:wkWebView animated:YES];
    }else if ([baseUrl.scheme isEqualToString:kDIYProtocolStr]){
        if ([baseUrl.host isEqualToString:@"xx01"]) {
            NSLog(@"xx01");
        }else if ([baseUrl.host isEqualToString:@"xx02"]){
            NSLog(@"xx02");
        }
    }
    
}




#pragma mark --- 获取最上面的控制器
- (UIViewController*)topViewController{
    return [self topViewControllerWithRootViewController:kWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    }else if([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    }else if(rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }else{
        return rootViewController;
    }
}


@end
