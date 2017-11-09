//
//  JIMNavigationBar.m
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/27.
//  Copyright © 2017年 Jiang. All rights reserved.
//

#import "UIButton+JIMButtonWithBlock.h"
#import "UIView+JimFrameExtension.h"
#import "JIMNavigationBar.h"

const double JIMNavigationBar_ToolBarWidthExtend = 32; //iOS11下UIToolbar左右两边默认边距为16，可以直接将其宽度增加32再向左移16就可以自己来控制点击范围
const double JIMNavigationBarHeight = 44;  //navigationBar的高度

UIEdgeInsets JIMBarItemImageInsets(BOOL isLeftItem,CGSize imageSize){
    CGFloat topMargin = (JIMNavigationBarHeight - imageSize.height) * 0.5;
    if (isLeftItem) {
        return UIEdgeInsetsMake(topMargin, 0.5 * JIMNavigationBar_ToolBarWidthExtend, topMargin, 0);
    }else{
        return UIEdgeInsetsMake(topMargin, 0, topMargin, 0.5 * JIMNavigationBar_ToolBarWidthExtend);
    }
}

UIBarButtonItem * JIMBarFixSpaceItem(){
    return [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

//iOS 11
UIBarButtonItem * JIMBarMarginItem(){
    UIBarButtonItem *item  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = 5;
    return item;
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

static UIImage *JIMNavigationBarDefaultReturnImage = nil;
static UIColor *JIMNavigationBarDefaultCoverColor = nil;
static CGFloat JIMNavigationBarDefaultReturnImageLeftMargin = 16;
static CGFloat JIMNavigationBarDefaultReturnImageRightMargin = 10;

@interface JIMNavigationBar()
{
    UIBarButtonItem * _backItem;
    NSMutableArray * _leftItems;
    NSMutableArray * _rightItems;
    UIView * _titleView;
}
@property (nonatomic, weak)UIViewController *caller;
@end

@implementation JIMNavigationBar
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.toolbar.frame = self.bounds;
}

-(UIColor *)coverColor{
    return self.toolbar.coverView.backgroundColor;
}
- (void)setCoverColor:(UIColor *)coverColor{
    self.toolbar.coverView.backgroundColor = coverColor;
}
- (void)setShadowImage:(UIImage *)shadowImage{
    [self.toolbar setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
}
- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics{
    [self.toolbar setBackgroundImage:backgroundImage forToolbarPosition:topOrBottom barMetrics:barMetrics];
}
+ (void)defaultReturnImage:(UIImage *)returnImage{
    if (!returnImage || CGSizeEqualToSize(returnImage.size, CGSizeZero)) return;
    JIMNavigationBarDefaultReturnImage = returnImage;
}
+ (void)defaultCoverColor:(UIColor *)color{
    JIMNavigationBarDefaultCoverColor = color;
}
+ (void)defaultReturnImageLeftMargin:(CGFloat)leftMargin{
    JIMNavigationBarDefaultReturnImageLeftMargin = leftMargin;
}
+ (void)defaultReturnImageRightMargin:(CGFloat)rightMargin{
    JIMNavigationBarDefaultReturnImageRightMargin = rightMargin;
}

- (instancetype)initWithCaller:(UIViewController *)caller{
    self = [super initWithFrame:CGRectZero];
    self.toolbar = [[JIMToolBar alloc]initWithFrame:self.bounds];
    self.coverColor = JIMNavigationBarDefaultCoverColor?:[UIColor clearColor];
    [self addSubview:self.toolbar];
    self.caller = caller;
    __weak typeof(self) weakself = self;
    UIButton *button = [UIButton jm_buttonWithBlock:^(UIButton *button) {
        [weakself.caller.navigationController popViewControllerAnimated:YES];
    }];
    _backItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    if (!JIMNavigationBarDefaultReturnImage) {
        JIMNavigationBarDefaultReturnImage = [UIImage imageNamed:[NSString stringWithFormat:@"JIMNavigationBar.bundle/back@%.0fx",[UIScreen mainScreen].scale]];
    }
    button.j_size = JIMNavigationBarDefaultReturnImage.size;
    [button setImage:JIMNavigationBarDefaultReturnImage forState:UIControlStateNormal];
    return self;
}



- (void)loadItems{
    NSMutableArray *items = [NSMutableArray array];
    
    //第一次显示的时候会将leftBarButtonItems设置为nil,但也会存在重新设置的情况
    _leftItems = [self.caller.navigationItem.leftBarButtonItems mutableCopy]?:_leftItems;
    
    if (_leftItems)
        self.caller.navigationItem.leftBarButtonItems = nil; //从系统导航栏中移除

    if (!_leftItems && !self.caller.isRootViewController) {
        _leftItems = [@[_backItem] mutableCopy];
    }
    
    //设置第一个button的左边距
    [self setButtonEdges:_leftItems isLeft:YES];
    
    //如果左边按钮不存在间距 - 针对iOS11
    if (![self hasFlexItem:_leftItems]) {
        //添加左边item之间的间距
        for (NSUInteger i = 1; i < _leftItems.count; i+=2) {
            [_leftItems insertObject:JIMBarMarginItem() atIndex:i];
        }
    }
    
    
    [items addObjectsFromArray:_leftItems];
    
    _rightItems = [self.caller.navigationItem.rightBarButtonItems mutableCopy]?:_rightItems;
    
    if (_rightItems)
        self.caller.navigationItem.rightBarButtonItems = nil;
    
    //设置最后一个button的右边距
    [self setButtonEdges:_rightItems isLeft:NO];
    
    //如果右边按钮不存在间距 - 针对iOS11
    if (![self hasFlexItem:_rightItems]) {
        //添加右边item之间的间距
        for (NSUInteger i = 1; i < _rightItems.count; i+=2) {
            [_rightItems insertObject:JIMBarMarginItem() atIndex:i];
        }
    }
    
    UIView *view = self.caller.navigationItem.titleView;
    if (view && !CGRectEqualToRect(CGRectZero, view.frame)) {
        _titleView = view;
    }
    [items addObject:JIMBarFixSpaceItem()];
    //计算titleView合适的宽度
    if (_titleView) {
        CGFloat itemWidth = 0;
        for (UIBarButtonItem *item in _leftItems) {
            itemWidth = itemWidth + item.customView.j_size.width + item.width;
        }
        for (UIBarButtonItem *item in _rightItems) {
            itemWidth = itemWidth + item.customView.j_size.width + item.width;
        }
        
        CGFloat titleViewMaxWidth = self.toolbar.j_width - itemWidth - JIMNavigationBar_ToolBarWidthExtend;
        if (_titleView.j_width >= titleViewMaxWidth) {
            _titleView.j_width = titleViewMaxWidth;
            if (_leftItems.firstObject == _backItem) { //
                if(_rightItems){
                    _titleView.j_width -= JIMNavigationBarDefaultReturnImageRightMargin;
                }else{
                    _titleView.j_width -= JIMNavigationBar_ToolBarWidthExtend*0.5;
                }
            }
            if (!_leftItems && !_rightItems) {
                _titleView.j_width -= JIMNavigationBar_ToolBarWidthExtend;
            }
        }
        [items addObject:[[UIBarButtonItem alloc]initWithCustomView:_titleView]];
        self.caller.navigationItem.titleView = nil;
        
    //使用navigationItem.title设置标题
    }else if (self.caller.navigationItem.title) {
        NSDictionary *attributes = nil;
        if (self.caller.navigationController.navigationBar.titleTextAttributes) {
            attributes =  self.caller.navigationController.navigationBar.titleTextAttributes;
        }else if ([UINavigationBar appearance].titleTextAttributes){
            attributes = [UINavigationBar appearance].titleTextAttributes;
        }
        [items addObject:JIMBarTitleItem(self.caller.navigationItem.title, attributes)];
    }
    
    [items addObject:JIMBarFixSpaceItem()];
    
    if (_rightItems) {
        [items addObjectsFromArray:_rightItems];
    }
    
    self.toolbar.items = items;

    NSUInteger totalCount = self.caller.navigationController.childViewControllers.count;
    //背景色设置，使用上一个VC的
    if (totalCount >= 2){
        UIColor *targetColor = self.caller.navigationController.childViewControllers[totalCount - 2].jimNavigationBar.coverColor;
        UIColor *currentColor = self.coverColor;
        UIColor *markColor = JIMNavigationBarDefaultCoverColor?:[UIColor clearColor];
        if (!CGColorEqualToColorIgnoreAlpha(targetColor.CGColor, markColor.CGColor)
            && CGColorEqualToColorIgnoreAlpha(currentColor.CGColor, markColor.CGColor)) {
            self.coverColor = targetColor;
        }
    }
}

//比较两个UIColor颜色是否相同,忽略alpha通道值
bool CGColorEqualToColorIgnoreAlpha(CGColorRef color1,CGColorRef color2){
    if(!color1 || !color2) return false;
    const CGFloat *a = CGColorGetComponents(color1); // R G B A 数组长度是CGColorSpaceGetNumberOfComponents + 1
    const CGFloat *b = CGColorGetComponents(color2);
    NSUInteger aCount = CGColorSpaceGetNumberOfComponents(CGColorGetColorSpace(color1));
    NSUInteger bCount = CGColorSpaceGetNumberOfComponents(CGColorGetColorSpace(color2));
    if (aCount != bCount) return false;
    for (NSUInteger index=0 ; index < aCount; index++) {
        if (a[index] != b[index]) return false;
    }
    return true;
}

- (void)setButtonEdges:(NSArray <UIBarButtonItem *>*)barButtonItems isLeft:(BOOL)isLeft{

    UIBarButtonItem *targetItem  =  isLeft?barButtonItems.firstObject:barButtonItems.lastObject;
    
    if (!targetItem) return;
    if (!targetItem.autoResize) return;
    
    NSAssert([targetItem.customView isKindOfClass:[UIButton class]], @"customView must be UIButton");
    
    { //针对AttributedString为nil的button
        [self itemsSetAttributes:barButtonItems state:UIControlStateNormal];
        [self itemsSetAttributes:barButtonItems state:UIControlStateHighlighted];
    }
    UIButton *button = targetItem.customView;
    CGSize contentSize = CGSizeZero;

    if (!button.imageView.hidden) {
        contentSize = [button imageForState:UIControlStateNormal].size;
    }
    if (!button.titleLabel.hidden) {
        NSAttributedString *attributeStr = [button attributedTitleForState:UIControlStateNormal];
        CGSize size = CGSizeZero;
        if (attributeStr) {
            size = [button attributedTitleForState:UIControlStateNormal].size;
        }else{
            size = [button.titleLabel sizeThatFits:CGSizeZero];
        }
        contentSize = CGSizeMake(ceil(size.width), size.height);
    }
    
    UIEdgeInsets insets = JIMBarItemImageInsets(isLeft, contentSize);
    //增大返回按钮的点击区域
    if (button == _backItem.customView) {
        insets = UIEdgeInsetsMake(insets.top, JIMNavigationBarDefaultReturnImageLeftMargin, insets.bottom, JIMNavigationBarDefaultReturnImageRightMargin);
    }
    
    button.j_height = contentSize.height + insets.top + insets.bottom;
    button.j_width = contentSize.width + insets.left + insets.right;
    //left + content_W * 0.5 = (content_W + left + right) / 2 + X;
    //X = left*0.5 - right *0.5
   UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, insets.left - insets.right, 0, 0);
    if (!button.imageView.hidden) {
        button.imageEdgeInsets = edgeInsets;
    }
    if (!button.titleLabel.hidden) {
        button.titleEdgeInsets = edgeInsets;
    }
    
}

- (void)itemsSetAttributes:(NSArray <UIBarButtonItem *>*)items state:(UIControlState)state{
    NSDictionary *attribute = [[UIBarButtonItem appearance] titleTextAttributesForState:state];
    if (attribute) {
        for (UIBarButtonItem *item in items) {
            UIButton *customView = item.customView;
            if (![customView isKindOfClass:[UIButton class]]) continue;
            if ([customView.titleLabel isHidden]) continue;
            if (![customView titleForState:state]) continue;
            if ([customView attributedTitleForState:state]) continue;
            NSString *title = [customView titleForState:state];
            [customView setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:attribute] forState:state];
        }
    }
}
- (BOOL)hasFlexItem:(NSArray <UIBarButtonItem *>*)items{
    for (UIBarButtonItem *item in items) {
        if (item.width != 0.0) {
            return YES;
        }
    }
    return NO;
}
@end

@implementation JIMToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentInsets = UIEdgeInsetsZero;
        _coverView = [[UIView alloc]initWithFrame:frame];
        [self addSubview:_coverView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //_contentInsets 
    self.subviews.firstObject.frame = CGRectMake(0, -_contentInsets.top, self.j_width, self.j_height + _contentInsets.top);
//    旋转180°，使分割线在下方(iOS10以上版本)
    self.subviews.firstObject.transform = CGAffineTransformMakeRotation(M_PI);
    
    NSUInteger version = [UIDevice currentDevice].systemVersion.floatValue;
    if (floor(version) == 9) {
        BOOL shadowImageIsToolBarSubView = NO;
        [self.subviews.firstObject addSubview:self.coverView];
        self.coverView.frame = self.subviews.firstObject.bounds;
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIImageView class]] && CGAffineTransformEqualToTransform(view.transform, CGAffineTransformIdentity)) {
                view.frame = CGRectMake(0, self.j_height - 0.5, self.j_width, 0.5);
                shadowImageIsToolBarSubView = YES;
                break;
            }
        }
        //说明此时shadowImageView是firstView的子视图
        if (!shadowImageIsToolBarSubView) { 
            self.coverView.frame = self.subviews.firstObject.frame;
        }
    }else{
        self.coverView.frame = self.subviews.firstObject.frame;
    }
}
@end

