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
@interface ZWWWKWebViewController ()<WKUIDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate>
@property(nonatomic,strong)WKWebView *wkWebView;
@property (nonatomic, strong) id <UIGestureRecognizerDelegate>delegate;//手势代理
@property(nonatomic,strong)UIProgressView *progressView;//进度条
@property(nonatomic,strong)UIButton *backButton;//返回键
@property(nonatomic,strong)UIButton *closeButton;//关闭键
@property(nonatomic,strong)UILabel *titleLabel;//网页title
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
    self.delegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.delegate;
}

- (void)createUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    adjustsScrollViewInsets(self.wkWebView);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithCustomView:self.closeButton];
    self.closeButton.hidden = YES;//默认不显示关闭按钮,当有多层网页才显示
    self.navigationItem.leftBarButtonItems = @[backItem,closeItem];
    [self.view addSubview:self.wkWebView];
    [self.view addSubview:self.progressView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.wkWebView loadRequest:request];
    UIView *titleView = [[UIView alloc]initWithFrame:self.titleLabel.frame];
    [titleView addSubview:self.titleLabel];
    self.navigationItem.titleView = titleView;
}

#pragma mark --- 懒加载
- (WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-iPX(64))];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        _wkWebView.allowsBackForwardNavigationGestures = YES;
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
            [_backButton setContentEdgeInsets:UIEdgeInsetsMake((44-frame.size.height)/2, 0, (44-frame.size.height)/2, (40-frame.size.width))];
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
            [_closeButton setContentEdgeInsets:UIEdgeInsetsMake((44-frame.size.height)/2, 0, (44-frame.size.height)/2, (40-frame.size.width))];
        }
        [_closeButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.frame = CGRectMake(0, 0, kScreenWidth-(100*2), 44);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}


#pragma mark --- 进度条监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"]) {
        self.progressView.hidden = NO;
        self.progressView.progress = [change[@"new"] floatValue];
        if (self.progressView.progress == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
            });
            //判断是否有多层网页
            if (self.wkWebView.canGoBack) {
                self.closeButton.hidden = NO;
            }else{
                self.closeButton.hidden = YES;
            }
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark --- 按钮点击事件
- (void)backClick{
    if (self.wkWebView.canGoBack) {
        [self.wkWebView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- WKNavigationDelegate
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

// 自定义协议跳转
- (void)handleCustomAction:(NSURL *)URL {
    NSString *absolute = URL.absoluteString;
    [DIYProtocol sharedRequestDIYProtocol].url = absolute;
}

// 身份验证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler{
    // 不要证书验证
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

// 导航错误
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}

// WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    self.titleLabel.text = @"加载中...";
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        self.titleLabel.text = title;
    }];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        self.titleLabel.text = title;
    }];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%@", error.localizedDescription);
    self.titleLabel.text = @"加载失败";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"加载失败" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}



#pragma mark --- WKUIDelegate
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


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.navigationController.viewControllers.count <= 1 ){
        return NO;
    }
    return YES;
}

// 允许同时响应多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}



#pragma mark --- 控制器释放
- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
    NSLog(@"%@控制器释放了",self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

