//
//  NextViewController.m
//  JimNavigationBar
//
//  Created by Jiang on 2017/10/29.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "NextViewController.h"
#import "JIMNavigationBar.h"
@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.jimNavigationBar.coverColor = [UIColor greenColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
