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
        UIViewController *topController = [self topViewController];
        [topController.navigationController pushViewController:wkWebView animated:YES];
    }else if ([baseUrl.scheme isEqualToString:kDIYProtocolStr]){
        if ([baseUrl.host isEqualToString:@"goJobPositionDetail"]) {
            NSLog(@"协议方法已获取:%@",baseUrl.host);
            NSMutableDictionary *dict = [self getURLParameters:url];
            NSLog(@"携带参数%@",dict);
        }else if ([baseUrl.host isEqualToString:@"goWebView"]){
            NSLog(@"协议方法已获取:%@",baseUrl.host);
            NSMutableDictionary *dict = [self getURLParameters:url];
            NSLog(@"携带参数%@",dict);
            ZWWWKWebViewController *wkWebView= [ZWWWKWebViewController new];
            wkWebView.url = dict[@"url"];
            UIViewController *topController = [self topViewController];
            [topController.navigationController pushViewController:wkWebView animated:YES];
        }
    }
    
}

/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters:(NSString *)urlStr {
    // 查找参数
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            id existValue = [params valueForKey:key];
            if (existValue != nil) {
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
            } else {
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        // 设置值
        [params setValue:value forKey:key];
    }
    return params;
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
