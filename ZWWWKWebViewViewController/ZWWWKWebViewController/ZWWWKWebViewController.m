//
//  ZWWWKWebViewController.m
//  ZWWWKWebViewViewController
//
//  Created by WW Z on 2017/12/27.
//  Copyright © 2017年 WW Z. All rights reserved.
//

#import "ZWWWKWebViewController.h"
#import "DIYProtocol.h"
#import <WebKit/WebKit.h>
@interface ZWWWKWebViewController ()<WKUIDelegate,WKNavigationDelegate>
@property(nonatomic,strong)WKWebView *wkWebView;
@property(nonatomic,strong)UIProgressView *progressView;//进度条
@property(nonatomic,strong)UIButton *backButton;//返回键
@property(nonatomic,strong)UIButton *closeButton;//关闭键
@end

@implementation ZWWWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;//关闭毛玻璃效果
}

- (void)createUI{
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithCustomView:self.closeButton];
    self.navigationItem.leftBarButtonItems = @[backItem,closeItem];
    [self.view addSubview:self.wkWebView];
    [self.view addSubview:self.progressView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.wkWebView loadRequest:request];
}

#pragma mark --- 懒加载
- (WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _wkWebView;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 2)];
        _progressView.progressTintColor = kRGB(70, 163, 231);
    }
    return _progressView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton new];
        [_backButton setImage:[UIImage imageNamed:@"zwwBack"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"zwwBack"] forState:UIControlStateHighlighted];
        CGRect frame = _backButton.frame;
        frame.size = _backButton.currentImage.size;
        _backButton.frame = frame;
        if (@available(iOS 11.0,*)) {
                [_backButton setContentMode:UIViewContentModeScaleToFill];
                [_backButton setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 5, 10)];
        }
        [_backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)closeButton{
    if (!_closeButton){
        _closeButton = [UIButton new];
        [_closeButton setImage:[UIImage imageNamed:@"zwwClose"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage imageNamed:@"zwwClose"] forState:UIControlStateHighlighted];
        CGRect frame = _closeButton.frame;
        frame.size = _closeButton.currentImage.size;
        _closeButton.frame = frame;
        if (@available(iOS 11.0,*)) {
            [_closeButton setContentMode:UIViewContentModeScaleToFill];
            [_closeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 5, 10)];
        }
        [_closeButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}


#pragma mark --- 进度条监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"]) {
        self.progressView.hidden = NO;
        self.progressView.progress = [change[@"new"] floatValue];
        if (self.progressView.progress == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
            });
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark --- 按钮点击事件
- (void)backClick{
    
}

- (void)closeClick{
    [self.navigationController popViewControllerAnimated:YES];
}


// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:kDIYProtocolStr]) {
        [self handleCustomAction:URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - private method
- (void)handleCustomAction:(NSURL *)URL {
    NSString *absolute = URL.absoluteString;
    [DIYProtocol sharedRequestDIYProtocol].url = absolute;
}

#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return [[WKWebView alloc]init];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 从web界面中接收到一个脚本时调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}



- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
