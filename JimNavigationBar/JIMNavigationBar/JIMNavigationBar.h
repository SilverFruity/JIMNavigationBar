//
//  JIMNavigationBar.h
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/27.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+JIMNavigationBar.h"
extern const double JIMNavigationBar_ToolBarWidthExtend;
extern const double JIMNavigationBarHeight;
NS_ASSUME_NONNULL_BEGIN
@interface JIMToolBar: UIToolbar
@property (nonatomic, assign)UIEdgeInsets contentInsets;
@property (nonatomic, strong)UIView *coverView;

@end

@interface JIMNavigationBar: UIView
@property (nonatomic, strong)JIMToolBar *toolbar;
@property (nonatomic, strong, readonly)UIView *titleView;
@property (nonatomic, strong)UIColor *coverColor;

- (void)setShadowImage:(UIImage * _Nonnull)shadowImage UI_APPEARANCE_SELECTOR;
- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics UI_APPEARANCE_SELECTOR;

- (instancetype)initWithCaller:(UIViewController *)caller;
+ (void)defaultReturnImage:(UIImage *)returnImage;
+ (void)defaultCoverColor:(UIColor *)color;                 //默认为透明
+ (void)defaultReturnImageLeftMargin:(CGFloat)leftMargin;   //返回图片的扩展左边距 16
+ (void)defaultReturnImageRightMargin:(CGFloat)rightMargin; //返回图片的扩展右边距 10
- (void)loadItems;
@end
NS_ASSUME_NONNULL_END
