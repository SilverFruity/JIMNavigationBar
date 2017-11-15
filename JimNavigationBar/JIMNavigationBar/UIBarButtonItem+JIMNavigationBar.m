//
//  UIBarButtonItem+JIMNavigationBar.m
//  JimNavigationBar
//
//  Created by Jiang on 2017/11/15.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "UIBarButtonItem+JIMNavigationBar.h"
#import "UIButton+JIMButtonWithBlock.h"
#import "UIView+JimFrameExtension.h"
#import <objc/runtime.h>

static char JIMNavigationBarAutoResizeKey;
@implementation UIBarButtonItem (JIMNavigationBar)

+ (UIBarButtonItem *)itemWithImage:(UIImage *)image block:(void(^)(id sender))block{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.j_size = image.size;
    [button setImage:image forState:UIControlStateNormal];
    [button jm_addActionForEvent:UIControlEventTouchUpInside block:block];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;
}
+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName block:(nullable void(^)(id sender))block{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self itemWithImage:image block:block];
}

+ (UIBarButtonItem *)itemWithImage:(UIImage *)image target:(nullable id)target action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.j_size = image.size;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;
}
+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName target:(nullable id)target action:(SEL)action{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self itemWithImage:image target:target action:action];
}

+ (UIBarButtonItem *)itemWithNormalTitle:(NSAttributedString *)normalTitle
                        highlightedTitle:(NSAttributedString *)highlightedTitle
                                   block:(void (^)(id sender))block{
    UIButton *button  = [self buttonWithNormalTitle:normalTitle highlightedTitle:highlightedTitle];
    [button jm_addActionForEvent:UIControlEventTouchUpInside block:block];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;
}

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title block:(nullable void (^)(id sender))block{
    NSArray <NSAttributedString *>*titles = [self itemAttributedTitlesWithTitle:title];
    return [self itemWithNormalTitle:titles.firstObject highlightedTitle:titles.lastObject block:block];
}

+ (UIBarButtonItem *)itemWithNormalTitle:(NSAttributedString *)normalTitle
                        highlightedTitle:(nullable NSAttributedString *)highlightedTitle
                                  target:(nullable id)target
                                  action:(SEL)action{
    UIButton *button = [self buttonWithNormalTitle:normalTitle highlightedTitle:highlightedTitle];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [UIBarButtonItem new];
}

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title target:(nullable id)target action:(SEL)action{
    NSArray <NSAttributedString *>*titles = [self itemAttributedTitlesWithTitle:title];
    return [self itemWithNormalTitle:titles.firstObject highlightedTitle:titles.lastObject target:target action:action];
}

+ (UIButton *)buttonWithNormalTitle:(NSAttributedString *)normalTitle
                   highlightedTitle:(NSAttributedString *)highlightedTitle{
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setAttributedTitle:normalTitle forState:UIControlStateNormal];
    NSAttributedString *highlighted = highlightedTitle;
    if (!highlighted) {
        NSMutableAttributedString *mutableStr = [normalTitle mutableCopy];
        [mutableStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, normalTitle.length)];
        highlighted = [mutableStr copy];
    }
    [button setAttributedTitle:highlighted forState:UIControlStateHighlighted];
    [button sizeToFit];
    return button;
}
+ (NSArray <NSAttributedString *>*)itemAttributedTitlesWithTitle:(NSString *)title{
    NSDictionary *normalAttributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateHighlighted];
    if (!normalAttributes) {
        normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    }
    if (!highlightedAttributes) {
        highlightedAttributes = @{NSFontAttributeName:normalAttributes[NSFontAttributeName],
                                  NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    }
    NSAttributedString *normalTitle = [[NSAttributedString alloc]initWithString:title attributes:normalAttributes];
    NSAttributedString *highlightedTitle = [[NSAttributedString alloc]initWithString:title attributes:highlightedAttributes];
    
    return @[normalTitle,highlightedTitle];
}

- (BOOL)autoResize{
    NSNumber *resize = objc_getAssociatedObject(self, &JIMNavigationBarAutoResizeKey);
    return resize?resize.boolValue : YES;
}

- (void)setAutoResize:(BOOL)autoResize{
    objc_setAssociatedObject(self, &JIMNavigationBarAutoResizeKey, @(autoResize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
