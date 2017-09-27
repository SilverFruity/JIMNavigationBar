//
//  ViewController.m
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/27.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+JIMNavigationBar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateHighlighted];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithTitle:@"GG" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithTitle:@"HH" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItems = @[item1,item2];
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftItemWithTitle:@"更多" block:nil];
    self.hiddenSysNavigationBar = NO;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"更多" block:nil];
    NSLog(@"%@",[UIButton buttonWithType:UIButtonTypeCustom].imageView);
    NSLog(@"%@",[UIButton buttonWithType:UIButtonTypeCustom].titleLabel);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
