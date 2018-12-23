//
//  WKViewController.m
//  TMCookieTest
//
//  Created by 闫振 on 2018/12/11.
//  Copyright © 2018年 TeeMo. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "WKViewController.h"

#import "WKCookieManager.h"

@interface WKViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"WK_Web";
    self.navigationController.navigationBar.translucent = NO;
    [self creatBtn];
    
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *contoller = [[WKUserContentController alloc] init];
    [contoller addUserScript:[[WKCookieManager shareManager] futhureCookieScript]];
    configuration.userContentController = contoller;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width,self.view.frame.size.height - 100) configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[[WKCookieManager shareManager]cookieAppendRequest:@"http://www.baidu.com"]];
    //JS->OC
    //注入的公共方法
    // window.webkit.messageHandlers.<name>.postMessage(<messageBody>) for all  前端要这样写
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"JSSendMessageToOC"];
    
}

- (void)lookCookie:(UIButton *)btn{
    
    NSHTTPCookieStorage *storages = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storages cookies]) {
        NSLog(@"%@",cookie);
    }
}

#pragma mark - WKNavigationDelegate

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
    NSLog(@"开始加载的时候调用。。");
    NSLog(@"%lf", self.webView.estimatedProgress);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    [[WKCookieManager shareManager] fixNewRequestCookieWithRequest:navigationAction.request];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
//OC->JS
- (void)ocSendMessageToJs:(NSString *)method parameter:(NSString *)para{
    
    NSString *jsStr2 = [NSString stringWithFormat:@"%@(%@)",method,para];
    [self.webView evaluateJavaScript:jsStr2 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"%@---%@",message.name,message.body);
    
    //  第一个参数为f方法名（自行和前端协商格式）
    NSDictionary *dic = message.body;
    NSString *common_mothed = dic.allKeys.firstObject;
    
    //注入的公共方法
    if (![message.name isEqualToString:@"JSSendMessageToOC"]) {
        return;
    }
    
    if ([common_mothed isEqualToString:@"XXX"]) {
        
    }
    
}


#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler();
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //必须移除 否则VC不释放
    [self.webView.configuration.userContentController  removeScriptMessageHandlerForName:@"JSSendMessageToOC"];
}
#pragma mark - dealloc
- (void)dealloc{
    NSLog(@"dealloc:走了");
}

- (void)creatBtn{
    UIButton *uiweb_btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    uiweb_btn.backgroundColor = [UIColor orangeColor];
    uiweb_btn.frame = CGRectMake(90, 20, 200, 40);
    [uiweb_btn setTitle:@"look_cookie" forState:(UIControlStateNormal)];
    [self.view addSubview:uiweb_btn];
    [uiweb_btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [uiweb_btn addTarget:self action:@selector(lookCookie:) forControlEvents:(UIControlEventTouchUpInside)];
    
}

@end
