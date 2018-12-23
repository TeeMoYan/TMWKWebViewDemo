//
//  ViewController.m
//  TMCookieTest
//
//  Created by 闫振 on 2018/12/11.
//  Copyright © 2018年 TeeMo. All rights reserved.
//

#import "ViewController.h"
#import "WKViewController.h"
typedef enum {
    BtnClickTypeLogIn = 0,
    BtnClickTypeJumpWkWeb = 1,
    BtnClickTypeLogOut = 2,
    BtnClickTypeRefreshUIWeb = 3,
}BtnClickType;
@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic,strong)NSArray *mDataArr;;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES) ;
    NSString *documentD = [paths objectAtIndex:0];
    
    NSLog(@"缓存路径=========%@",documentD);
    self.mDataArr = @[@"登录成功设置Cookie",@"跳转WKWebView",@"退出登录删除Cookie",@"刷新UIWebView"];
    [self creatBtns];
    
    // UIWebView 和 login方法 在这里模拟登录后 NSHTTPCookieStorage 中有 cookie  实际用法在WKViewController
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - 200, self.view.frame.size.width, 200)];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    [self.view addSubview:self.webView];
    
}

- (void)refreshUIWebView{
    
    [self.webView loadRequest:[self cookieAppendRequest:@"http://www.baidu.com"]];
    
}
- (void)creatBtns{
    
    for (int i = 0;i < self.mDataArr.count ; i++) {
        UIButton *logout_btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        logout_btn.tag = i;
        [logout_btn setTitle:_mDataArr[i] forState:(UIControlStateNormal)];
        [self.view addSubview:logout_btn];
        logout_btn.backgroundColor = [UIColor orangeColor];
        logout_btn.frame = CGRectMake(90, 80*(1+i), 200, 40);
        [logout_btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [logout_btn addTarget:self action:@selector(btnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self lookCookie];
}
- (void)lookCookie{
    NSHTTPCookieStorage *storages = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storages cookies]) {
        NSLog(@"查看Cookie========%@",cookie);
    }
}
- (void)btnClick:(UIButton *)btn{
    if (btn.tag == BtnClickTypeLogIn) {
        [self login];
    }else if (btn.tag == BtnClickTypeJumpWkWeb){
        [self jumpWKWebBtn];
    }else if (btn.tag == BtnClickTypeLogOut){
        [self logout];
    }else if (btn.tag == BtnClickTypeRefreshUIWeb){
        [self refreshUIWebView];
    }
}
- (void)logout{
    
    NSHTTPCookieStorage *storages = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storages cookies]) {
        
        [storages deleteCookie:cookie];
        NSLog(@"删除Cookie========%@",cookie);
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"app_cookies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//模拟登录 实际开发中不用设置，直接拿到cooki 共享给WKWebView
- (void)login{
    [self setCookieWithDomain:@"http://www.baidu.com" sessionName:@"TeeMo_Cookie_WebView" sessionValue:@"123456789" expiresDate:nil];
}
- (NSURLRequest *)cookieAppendRequest:(NSString *)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    //Cookies数组转换为requestHeaderFields
    NSDictionary *requestHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    //设置请求头
    request.allHTTPHeaderFields = requestHeaderFields;
    NSLog(@"%@",request.allHTTPHeaderFields);
    return request;
}

- (void)setCookieWithDomain:(NSString*)domainValue
                sessionName:(NSString *)name
               sessionValue:(NSString *)value
                expiresDate:(NSDate *)date{
    
    //    NSURL *url = [NSURL URLWithString:domainValue];
    //    NSString *domain = [url host];
    
    //创建字典存储cookie的属性值
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:domainValue forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    if (date) {
        [cookieProperties setObject:date forKey:NSHTTPCookieExpires];
    }else{
        [cookieProperties setObject:[NSDate dateWithTimeIntervalSince1970:([[NSDate date] timeIntervalSince1970]+365*24*3600)] forKey:NSHTTPCookieExpires];
    }
    [[NSUserDefaults standardUserDefaults] setObject:cookieProperties forKey:@"app_cookies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //删除原cookie, 如果存在的话
//    NSArray * arrayCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    for (NSHTTPCookie * cookice in arrayCookies) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookice];
//
//    }
    //使用字典初始化新的cookie
    NSHTTPCookie *newcookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    //使用cookie管理器 存储cookie
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newcookie];
}

- (void)jumpWKWebBtn{
    
    [self.navigationController pushViewController:[WKViewController new] animated:YES];
    
}



@end
