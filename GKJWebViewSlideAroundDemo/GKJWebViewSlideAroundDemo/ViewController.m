//
//  ViewController.m
//  GKJWebViewSlideAroundDemo
//
//  Created by Kangjia on 2017/7/31.
//  Copyright © 2017年 idol. All rights reserved.
//

#import "ViewController.h"
#import "RxWebViewController.h"

#define KScreenW ([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height? [[UIScreen mainScreen] bounds].size.height:[[UIScreen mainScreen] bounds].size.width) //整个竖屏幕的宽
#define KScreenH ([[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height? [[UIScreen mainScreen] bounds].size.width:[[UIScreen mainScreen] bounds].size.height) //整个竖屏幕的高

@interface ViewController ()

@property (nonatomic ,strong) UIButton *pushButton;
@property (nonatomic ,strong) UILabel *pushBtnLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self commontInitUI];
}

- (void)commontInitUI{
    
    self.pushButton = [[UIButton alloc] initWithFrame:CGRectMake((KScreenW-160/2)/2, (KScreenH-30)/2, 160/2, 60/2)];
    _pushButton.backgroundColor = [UIColor orangeColor];
    _pushButton.tag = 57119;
    _pushButton.layer.cornerRadius = 3.0f;
    _pushButton.layer.borderColor = [UIColor clearColor].CGColor;
    _pushButton.layer.borderWidth = 0.5f;
    _pushButton.layer.masksToBounds = YES;
    [_pushButton addTarget:self action:@selector(pushClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pushButton];
    
    self.pushBtnLab = [[UILabel alloc] initWithFrame:_pushButton.bounds];
    _pushBtnLab.backgroundColor = [UIColor clearColor];
    _pushBtnLab.textColor = [UIColor whiteColor];
    _pushBtnLab.textAlignment = NSTextAlignmentCenter;
    _pushBtnLab.font = [UIFont systemFontOfSize:13.0];
    _pushBtnLab.text = @"PUSH";
    [_pushButton addSubview:_pushBtnLab];
}

-(void)pushClick{
    
    RxWebViewController* webViewController = [[RxWebViewController alloc] initWithUrl:[NSURL URLWithString:@"https://www.baidu.com/"]];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
