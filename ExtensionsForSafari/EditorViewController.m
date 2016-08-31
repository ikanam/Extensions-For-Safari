//
//  EditorViewController.m
//  JavaScriptInject
//
//  Created by Tian on 16/8/30.
//  Copyright © 2016年 JerryTian. All rights reserved.
//

#import "EditorViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>

@interface EditorViewController () <WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *editorWebView;

@property (nonatomic, copy) NSString *content;

@end

@implementation EditorViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.snippet.name;
    
    [self.view addSubview:self.editorWebView];
    
    [self.editorWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self loadCodeMirror];
    
}

#pragma mark - Event Response

- (IBAction)didTapActionButton:(UIBarButtonItem *)sender {
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    self.content = [message.body objectForKey:@"content"];
    [self updateSnippet];
    
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self setCode:self.snippet.code];
}

#pragma mark - Private Method

- (void)updateSnippet {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm transactionWithBlock:^{
        self.snippet.code = self.content;
    }];
}


- (void)loadCodeMirror {
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"sublime" ofType:@"html" inDirectory:@"CodeMirror/html"];
    NSURL *htmlURL = [NSURL fileURLWithPath:htmlPath];
    
    NSString *codeMirrorPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/CodeMirror"];
    NSURL *codeMirrorURL = [NSURL fileURLWithPath:codeMirrorPath];
    
    [self.editorWebView loadFileURL:htmlURL allowingReadAccessToURL:codeMirrorURL];
    
}

- (void)setCode:(NSString *)code {
    [self.editorWebView evaluateJavaScript:[NSString stringWithFormat:@"setCode('%@')", code] completionHandler:nil];
}

- (void)getCodeSuccess:(void (^)(NSString *code))success {
    [self.editorWebView evaluateJavaScript:@"getCode()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        self.content = result;
    }];
}

#pragma mark -  Getter

- (WKWebView *)editorWebView {
    if (!_editorWebView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        //注册js方法
        [config.userContentController addScriptMessageHandler:self name:@"CodeMirrorChangeEvent"];
        _editorWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _editorWebView.scrollView.bounces = NO;
        _editorWebView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _editorWebView.navigationDelegate = self;
    }
    return _editorWebView;
}


@end
