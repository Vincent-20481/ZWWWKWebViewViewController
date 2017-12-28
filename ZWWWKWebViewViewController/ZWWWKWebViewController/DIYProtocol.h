//
//  DIYProtocol.h
//  ZWWWKWebViewViewController
//
//  Created by WW Z on 2017/12/27.
//  Copyright © 2017年 WW Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kWindow [UIApplication sharedApplication].keyWindow
#define kScreenBounds [[UIScreen mainScreen] bounds]
#define kScreenWidth kScreenBounds.size.width
#define kScreenHeight kScreenBounds.size.height
#define kRGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPX(str) ((iPhoneX?str+24:str))
#define iPXB (iPhoneX?34:0)

#define kDIYProtocolStr @"XXXAPP" //自定义协议头
#import "ZWWWKWebViewController.h"

@interface DIYProtocol : NSObject

+ (instancetype)sharedRequestDIYProtocol;

//传入url
@property(nonatomic,copy)NSString *url;


@end
