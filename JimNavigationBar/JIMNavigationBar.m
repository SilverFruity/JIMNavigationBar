//
//  JIMNavigationBar.m
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/27.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "JIMNavigationBar.h"
#import "UIImage+imageExtention.h"
#import "UIButton+buttonWithBlock.h"
#import "UIView+JimFrameExtension.h"

#import "UIViewController+JIMNavigationBar.h"

const double JIMNavigationBarOffsetX = 16; //将navigationBar向左移动一段距离，用于减小两侧button的边界距离
const double JIMNavigationBarHeight = 44;  //navigationBar的高度

UIEdgeInsets JIMBarItemImageInsets(BOOL isLeftItem,CGSize imageSize){
    CGFloat topMargin = (JIMNavigationBarHeight - imageSize.height) * 0.5;
    if (isLeftItem) {
        return UIEdgeInsetsMake(topMargin, JIMNavigationBarOffsetX, topMargin, 10);
    }else{
        return UIEdgeInsetsMake(topMargin, 10, topMargin, JIMNavigationBarOffsetX);
    }
}

UIBarButtonItem * JIMBarFixSpaceItem(){
    return [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

UIBarButtonItem * JIMBarTitleItem(NSString *title, NSDictionary *attr){
    UILabel *lable = [UILabel new];
    if (attr) {
        lable.attributedText = [[NSAttributedString alloc]initWithString:title attributes:attr];
    }else{
        lable.text = title;
    }
    [lable sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:lable];
    return item;
}

@interface JIMNavigationBar()
{
    UIBarButtonItem * _backItem;
    NSArray * _leftItems;
    NSArray * _rightItems;
}
@property (nonatomic, weak)UIViewController *caller;
@end
@implementation JIMNavigationBar

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.toolbar.frame = self.bounds;
}

- (instancetype)initWithCaller:(UIViewController *)caller{
    self = [super initWithFrame:CGRectZero];
    self.toolbar = [[JIMToolBar alloc]initWithFrame:self.bounds];
    [self addSubview:self.toolbar];
    self.caller = caller;
    __weak typeof(self) weakself = self;
    UIButton *button = [UIButton buttonWithBlock:^(UIButton *button) {
        [weakself.caller.navigationController popViewControllerAnimated:YES];
    }];
    _backItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    return self;
}

- (void)setBackImageName:(NSString *)backImageName{
    UIButton *button = (UIButton *)_backItem.customView;
    UIImage *originalImage = [UIImage imageNamed:backImageName];
    CGFloat topMargin = (JIMNavigationBarHeight - originalImage.size.height) * 0.5;
    UIImage *backImage = [originalImage imageInset:UIEdgeInsetsMake(topMargin, JIMNavigationBarOffsetX, topMargin, 10)];
    button.j_size = backImage.size;
    [button setImage:backImage forState:UIControlStateNormal];
    [button setImage:[backImage imageRenderWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
}

- (void)loadItems{
    NSMutableArray *items = [NSMutableArray array];
    
    NSMutableArray *leftItems = [[self.caller.navigationItem.leftBarButtonItems mutableCopy] copy];
    if (!_leftItems || leftItems) {
        _leftItems = leftItems;
        self.caller.navigationItem.leftBarButtonItems = nil;
    }
    
    NSMutableArray *rightItems = [[self.caller.navigationItem.rightBarButtonItems mutableCopy] copy];
    if (!_rightItems || rightItems) {
        _rightItems = rightItems;
        self.caller.navigationItem.rightBarButtonItems = nil;
    }
    
    UIView  * titleView = self.caller.navigationItem.titleView;
    
    if (_leftItems) {
        [items addObjectsFromArray:_leftItems];
    }else{
        [items addObject:_backItem];
    }
    
    [items addObject:JIMBarFixSpaceItem()];
    //计算titleView合适的宽度
    if (titleView) {
        CGFloat itemWidth = 0;
        if (_leftItems) {
            for (UIBarButtonItem *item in _leftItems) {
                itemWidth += item.customView.j_size.width;
            }
        }else if (self.caller.navigationController.childViewControllers.firstObject != self.caller){
            itemWidth += _backItem.customView.j_size.width;
        }
        if (_rightItems) {
            for (UIBarButtonItem *item in _rightItems) {
                itemWidth += item.customView.j_size.width;
            }
        }
        if (titleView.j_width > self.j_width - itemWidth + 2*JIMNavigationBarOffsetX) {
            titleView.j_width = self.j_width - itemWidth - 32 + 2*JIMNavigationBarOffsetX;
        }
        [items addObject:[[UIBarButtonItem alloc]initWithCustomView:titleView]];
        self.caller.navigationItem.titleView = [UIView new];
        
        //使用navigationItem.title设置标题
    }else if (self.caller.navigationItem.title) {
        if (self.caller.navigationController.navigationBar.titleTextAttributes) {
            [items addObject:JIMBarTitleItem(self.caller.navigationItem.title, self.caller.navigationController.navigationBar.titleTextAttributes)];
        }else if ([UINavigationBar appearance].titleTextAttributes){
            [items addObject:JIMBarTitleItem(self.caller.navigationItem.title, [UINavigationBar appearance].titleTextAttributes)];
        }else{
            [items addObject:JIMBarTitleItem(self.caller.navigationItem.title, nil)];
        }
    }
    [items addObject:JIMBarFixSpaceItem()];
    if (_rightItems) {
        [items addObjectsFromArray:_rightItems];
    }
    self.toolbar.items = items;
    
    NSUInteger totalCount = self.caller.navigationController.childViewControllers.count;
    if (totalCount >= 2){
        UIColor *targetColor = self.caller.navigationController.childViewControllers[totalCount - 2].navigationBar.toolbar.coverView.backgroundColor;
        UIColor *currentColor = self.toolbar.coverView.backgroundColor;
        UIColor *markColor = self.toolbar.defaultCoverColor;
        if (!CGColorEqualToColor(targetColor.CGColor, markColor.CGColor)
            && CGColorEqualToColor(currentColor.CGColor, markColor.CGColor)) {
            self.toolbar.coverView.backgroundColor = targetColor;
        }
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
}
@end

@implementation JIMToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentInsets = UIEdgeInsetsZero;
        _coverView = [[UIView alloc]initWithFrame:frame];
        _coverView.backgroundColor = [UIColor clearColor];
        _defaultCoverColor = _coverView.backgroundColor;
        [self addSubview:_coverView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.subviews.firstObject.frame = CGRectMake(0, -_contentInsets.top, self.j_width, self.j_height + _contentInsets.top);
    self.subviews.firstObject.transform = CGAffineTransformMakeRotation(M_PI);
    self.coverView.frame = self.subviews.firstObject.frame;
}
@end

