//
//  ViewController.m
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/27.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+JIMNavigationBar.h"
#import "JIMNavigationBar.h"


@interface ViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong)UIColor *color;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.color = [UIColor colorWithRed:100.f/256.f green:149.f/256.f blue:237.f/256.f alpha:1.0];
    
    
    [[JIMNavigationBar appearance] setShadowImage:[UIImage new]];
    [[JIMNavigationBar appearance] setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    [JIMNavigationBar defaultReturnImage:[UIImage imageNamed:@"back"]];
    [JIMNavigationBar defaultCoverColor:self.color];
    [JIMNavigationBar defaultReturnImageLeftMargin:10];
    [JIMNavigationBar defaultReturnImageRightMargin:10];
    
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                           NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                                           NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                                forState:UIControlStateHighlighted];
    
   
    self.scrollView.delegate = self;
    self.scrollView.contentSize = [UIScreen mainScreen].bounds.size;
    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0);
    self.scrollView.contentOffset = CGPointMake(0, -CGRectGetMaxY(self.navigationController.navigationBar.frame));
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:view];
    
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat value = 64;
    if (scrollView.contentOffset.y > 64) return;
    CGFloat alpha = 1 - (scrollView.contentOffset.y + scrollView.contentInset.top) / value;
    self.jimNavigationBar.coverColor = [self.color colorWithAlphaComponent:alpha>1?1:alpha];
}
@end
