//
//  RxWebViewController.m
//  RxWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import "RxWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#define KScreenW ([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height? [[UIScreen mainScreen] bounds].size.height:[[UIScreen mainScreen] bounds].size.width) //整个竖屏幕的宽
#define KScreenH ([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height? [[UIScreen mainScreen] bounds].size.width:[[UIScreen mainScreen] bounds].size.height) //整个竖屏幕的高

@interface RxWebViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UINavigationBarDelegate,NJKWebViewProgressDelegate>

@property (nonatomic)UIBarButtonItem* customBackBarItem;

@property (nonatomic)UIBarButtonItem* closeButtonItem;

@property (nonatomic)NJKWebViewProgress* progressProxy;

@property (nonatomic)NJKWebViewProgressView* progressView;

@property (nonatomic)UIView* currentSnapShotView;

@property (nonatomic)UIView* prevSnapShotView;

@property (nonatomic)UIView* swipingBackgoundView;

@property (nonatomic)UIPanGestureRecognizer* swipePanGesture;

@property (nonatomic)BOOL isSwipingBack;

@property (nonatomic)BOOL isSwipingPush;

@end

@implementation RxWebViewController

-(UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - init
-(instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        self.url = url;
        _progressViewColor = [UIColor colorWithRed:119.0/255 green:228.0/255 blue:115.0/255 alpha:1];
    }
    return self;
}

-(UILabel *)titleNavView
{
    return nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self updateNavigationItems];
    
    self.webView.delegate = self.progressProxy;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
    
}





-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.progressView removeFromSuperview];
    self.webView.delegate = nil;
}

#pragma mark - public funcs
-(void)reloadWebView{
    [self.webView reload];
}


-(void)startPopSnapshotView{
    if (self.isSwipingBack) {
        return;
    }
    if (!self.webView.canGoBack) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = [[UIView alloc] initWithFrame:self.webView.frame];
    self.prevSnapShotView.backgroundColor = [UIColor colorWithRed:240/255.0f  green:240/255.0f  blue:240/255.0f alpha:1];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.swipingBackgoundView.alpha = 1;
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];
}

-(void)startPresentSnapshotView{
    
    if (self.isSwipingPush) {
        return;
    }
    if (!self.webView.canGoForward) {
        return;
    }
    self.isSwipingPush = YES;
    
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = [[UIView alloc] initWithFrame:self.webView.frame];
    self.prevSnapShotView.backgroundColor = [UIColor colorWithRed:240/255.0f  green:240/255.0f  blue:240/255.0f alpha:1];
    center.x += 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.swipingBackgoundView.alpha = 1;
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(KScreenW/2, KScreenH/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(KScreenW/2, KScreenH/2);
    prevSnapshotViewCenter.x -= (KScreenW - distance)*60/KScreenW;
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (KScreenW - distance)/KScreenW;
}

-(void)pushSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    
    if (!self.isSwipingPush) {
        return;
    }
    
    if (distance >= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(KScreenW/2, KScreenH/2);
    currentSnapshotViewCenter.x += distance;
    
    CGPoint prevSnapshotViewCenter = CGPointMake(KScreenW/2, KScreenH/2);
    prevSnapshotViewCenter.x += (KScreenW + distance)*60/KScreenW;
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (KScreenW + distance)/KScreenW;
}

-(void)endPopSnapShotView{
    
    if (!self.isSwipingBack && !self.isSwipingPush) {
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    if (self.isSwipingBack) {
        
        if (self.currentSnapShotView.center.x >= KScreenW) {
            // pop success
            [UIView animateWithDuration:0.2 animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                
                self.currentSnapShotView.center = CGPointMake(KScreenW*3/2, KScreenH/2);
                self.prevSnapShotView.center = CGPointMake(KScreenW/2, KScreenH/2);
                self.swipingBackgoundView.alpha = 0;
            }completion:^(BOOL finished) {

                [self.webView goBack];
                [self performSelector:@selector(performFetch:) withObject:self afterDelay:0.2f];
                self.view.userInteractionEnabled = YES;
                self.isSwipingBack = NO;
            }];
        }else{
            //pop fail
            [UIView animateWithDuration:0.2 animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                
                self.currentSnapShotView.center = CGPointMake(KScreenW/2, KScreenH/2);
                self.prevSnapShotView.center = CGPointMake(KScreenW/2-60, KScreenH/2);
                self.prevSnapShotView.alpha = 1;
            }completion:^(BOOL finished) {
                [self.prevSnapShotView removeFromSuperview];
                [self.swipingBackgoundView removeFromSuperview];
                [self.currentSnapShotView removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                self.isSwipingBack = NO;
            }];
        }
        
    }else if (self.isSwipingPush){
        
        if (self.currentSnapShotView.center.x <= KScreenW/4) {
            // pop success
            [UIView animateWithDuration:0.2 animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                
                self.currentSnapShotView.center = CGPointMake(-KScreenW/2, KScreenH/2);
                self.prevSnapShotView.center = CGPointMake(KScreenW/2, KScreenH/2);
                self.swipingBackgoundView.alpha = 0;
            }completion:^(BOOL finished) {
                
                [self.webView goForward];
                
                [self performSelector:@selector(performFetch:) withObject:self afterDelay:0.2f];

                self.view.userInteractionEnabled = YES;
                self.isSwipingPush = NO;
            }];
        }else{
            //pop fail
            [UIView animateWithDuration:0.2 animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                
                self.currentSnapShotView.center = CGPointMake(KScreenW/2, KScreenH/2);
                self.prevSnapShotView.center = CGPointMake(KScreenW/2-60, KScreenH/2);
                self.prevSnapShotView.alpha = 1;
            }completion:^(BOOL finished) {
                [self.prevSnapShotView removeFromSuperview];
                [self.swipingBackgoundView removeFromSuperview];
                [self.currentSnapShotView removeFromSuperview];
                self.view.userInteractionEnabled = YES;
                self.isSwipingPush = NO;
            }];
        }
    }
}

-(void)performFetch:(id)object{
    [self.prevSnapShotView removeFromSuperview];
    [self.swipingBackgoundView removeFromSuperview];
    [self.currentSnapShotView removeFromSuperview];
}


#pragma mark - update nav items

-(void)updateNavigationItems{
    if (self.webView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem, self.closeButtonItem] animated:NO];
        
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:nil animated:NO];
    }
}

#pragma mark - events handler
-(void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x > 0) {  //开始动画
            [self startPopSnapshotView];
        }else if (location.x >= KScreenW-50 && translation.x < 0){
            [self startPresentSnapshotView];
        }
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        if (self.isSwipingBack) {
            [self popSnapShotViewWithPanGestureDistance:translation.x];
        }else if (self.isSwipingPush){
            [self pushSnapShotViewWithPanGestureDistance:translation.x];
        }
    }
}

-(void)customBackItemClicked{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)closeItemClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - webView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [self updateNavigationItems];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (theTitle.length > 10) {
        theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
    }
    self.title = theTitle;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(BOOL)stringContentString:(NSString *)motherString subString:(NSString *)sonString{
    if ([motherString rangeOfString:sonString].location!=NSNotFound) {
        return YES;
    }else{
        return NO;
    }
}

-(UIImage*)clipImage:(UIView*)view{
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - NJProgress delegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - setters and getters
-(void)setUrl:(NSURL *)url{
    _url = url;
}

-(void)setProgressViewColor:(UIColor *)progressViewColor{
    _progressViewColor = progressViewColor;
}

-(UIWebView*)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH)];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.delegate = (id)self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        [_webView addGestureRecognizer:self.swipePanGesture];
    }
    return _webView;
}

-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"game_left_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"game_left_arrow_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    }
    return _closeButtonItem;
}

-(UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

-(BOOL)isSwipingBack{
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}

-(BOOL)isSwipingPush{
    if (!_isSwipingPush) {
        _isSwipingPush = NO;
    }
    return _isSwipingPush;
}

-(UIPanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    }
    return _swipePanGesture;
}

-(NJKWebViewProgress*)progressProxy{
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = (id)self;
        _progressProxy.progressDelegate = (id)self;
    }
    return _progressProxy;
}

-(NJKWebViewProgressView*)progressView{
    if (!_progressView) {
        CGFloat progressBarHeight = 3.0f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}

@end
