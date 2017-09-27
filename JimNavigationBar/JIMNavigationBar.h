//
//  JIMNavigationBar.h
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/27.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const double JIMNavigationBarOffsetX;
extern const double JIMNavigationBarHeight;
extern UIEdgeInsets JIMBarItemImageInsets(BOOL isLeftItem,CGSize imageSize);

@interface JIMToolBar: UIToolbar
@property (nonatomic, assign)UIEdgeInsets contentInsets;
@property (nonatomic, strong)UIView *coverView;
@property (nonatomic, strong)UIColor *defaultCoverColor;
@end

@interface JIMNavigationBar: UIView
- (instancetype)initWithCaller:(UIViewController *)caller;
@property (nonatomic, strong)JIMToolBar *toolbar;
@property (nonatomic, strong)NSString *backImageName;
- (void)loadItems;
@end
