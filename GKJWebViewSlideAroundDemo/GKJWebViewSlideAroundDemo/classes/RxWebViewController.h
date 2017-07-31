//
//  RxWebViewController.h
//  RxWebViewController
//
//  Created by roxasora on 15/10/23.
//  Copyright © 2015年 roxasora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^transferBack)(void);

@interface RxWebViewController : UIViewController

@property (nonatomic, strong) UIView *myWhiteLine;

@property (nonatomic)NSURL* url;

@property (nonatomic)UIWebView* webView;

@property (nonatomic)UIColor* progressViewColor;

-(instancetype)initWithUrl:(NSURL*)url;

-(void)reloadWebView;

@end



