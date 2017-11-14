//
//  UIBarButtonItem+JIMNavigationBar.h
//  JimNavigationBar
//
//  Created by Jiang on 2017/11/15.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIBarButtonItem (JIMNavigationBar)
@property (nonatomic)BOOL autoResize; //主要针对最左边和最右边的按钮是否需要自动重新调整大小
///图片
//Block
+ (UIBarButtonItem *)itemWithImage:(UIImage *)image block:(nullable void(^)(id sender))block;
+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName block:(nullable void(^)(id sender))block;

//Selector
+ (UIBarButtonItem *)itemWithImage:(UIImage *)image target:(nullable id)target action:(SEL)action;
+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName target:(nullable id)target action:(SEL)action;

///文字
//Block
+ (UIBarButtonItem *)itemWithNormalTitle:(NSAttributedString *)normalTitle
                        highlightedTitle:(nullable NSAttributedString *)highlightedTitle
                                   block:(void (^)(id sender))block;

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title block:(nullable void (^)(id sender))block;

//Selector
+ (UIBarButtonItem *)itemWithNormalTitle:(NSAttributedString *)normalTitle
                        highlightedTitle:(nullable NSAttributedString *)highlightedTitle
                                  target:(nullable id)target
                                  action:(SEL)action;

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title target:(nullable id)target action:(SEL)action;
@end
NS_ASSUME_NONNULL_END
