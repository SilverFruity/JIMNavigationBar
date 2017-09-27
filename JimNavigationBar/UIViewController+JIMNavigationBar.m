//
//  NavigationBarVC.m
//  SharedGym
//
//  Created by Jiang on 2017/9/17.
//

#import "UIViewController+JIMNavigationBar.h"

#import <objc/runtime.h>

#import "UIImage+imageExtention.h"
#import "UIButton+buttonWithBlock.h"
#import "UIView+JimFrameExtension.h"

#import "JIMNavigationBar.h"

static char JIMNavigationBarKey;
static char JIMNavigationSetKey;
static char JIMNavigationHiddenSysNavigationBarKey;

@implementation UIViewController(JIMNavigationBar)

+(void)load{
    Method viewdidLoad = class_getInstanceMethod([UIViewController  class], @selector(viewDidLoad));
    Method j_viewDidLoad = class_getInstanceMethod([UIViewController class], @selector(j_viewDidLoad));
    method_exchangeImplementations(viewdidLoad, j_viewDidLoad);
    
    Method viewWillAppear = class_getInstanceMethod([UIViewController  class], @selector(viewWillAppear:));
    Method j_viewWillAppear = class_getInstanceMethod([UIViewController class], @selector(j_viewWillAppear:));
    method_exchangeImplementations(viewWillAppear, j_viewWillAppear);
    
    Method viewDidDisappear = class_getInstanceMethod([UIViewController  class], @selector(viewDidDisappear:));
    Method j_viewDidDisappear = class_getInstanceMethod([UIViewController class], @selector(j_viewDidDisappear:));
    method_exchangeImplementations(viewDidDisappear, j_viewDidDisappear);
}

- (JIMNavigationBar *)navigationBar{
    JIMNavigationBar *bar = objc_getAssociatedObject(self, &JIMNavigationBarKey);
    if (!bar) {
        bar = [[JIMNavigationBar alloc]initWithCaller:self];
        objc_setAssociatedObject(self, &JIMNavigationBarKey, bar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return bar;
}
- (BOOL)hasSet{
    NSNumber *has = objc_getAssociatedObject(self, &JIMNavigationSetKey);
    return has ? has.boolValue : NO;
}
- (void)setHasSet:(BOOL)hasSet{
    objc_setAssociatedObject(self, &JIMNavigationSetKey, @(hasSet), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hiddenSysNavigationBar{
    NSNumber *hidden = objc_getAssociatedObject(self, &JIMNavigationHiddenSysNavigationBarKey);
    return hidden ? hidden.boolValue : YES;
}

- (void)setHiddenSysNavigationBar:(BOOL)hiddenSysNavigationBar{
    objc_setAssociatedObject(self, &JIMNavigationHiddenSysNavigationBarKey, @(hiddenSysNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)j_viewDidLoad{
    [self j_viewDidLoad];
    if ([self.parentViewController isKindOfClass:[UINavigationController class]] && self.hiddenSysNavigationBar){
        self.navigationController.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)j_viewWillAppear:(BOOL)animated{
    [self j_viewWillAppear:animated];
    if ([self.parentViewController isKindOfClass:[UIImagePickerController class]]) {
        return;
    }
    [self.navigationController.navigationBar setHidden:self.hiddenSysNavigationBar];
    if (self.hasSet) {
        return;
    }
    if ([self.parentViewController isKindOfClass:[UINavigationController class]] && self.hiddenSysNavigationBar) {
        self.navigationBar.backImageName = JimNavi_BackImageName;
        [self.view addSubview:self.navigationBar];;
        CGRect naviFrame = self.navigationController.navigationBar.frame;
        CGFloat offset = JIMNavigationBarOffsetX > 0 ? JIMNavigationBarOffsetX : 0;
        CGRect barFrame = CGRectMake(-offset, 0, CGRectGetWidth(naviFrame) + 2 * offset, CGRectGetHeight(naviFrame));
        CGFloat maxY = CGRectGetMaxY(naviFrame);
        CGFloat height = CGRectGetHeight(naviFrame);
        self.navigationBar.frame =  naviFrame;
        self.navigationBar.toolbar.frame = barFrame;
        self.navigationBar.toolbar.contentInsets = UIEdgeInsetsMake(maxY - height , 0, 0, 0);
        
        self.view.clipsToBounds = JIMNavigationBarOffsetX > 0;
        
        [self.navigationBar loadItems];
        
        self.hasSet = YES;
        
        [self addNavigationItemsObserver];
    }
}

- (void)j_viewDidDisappear:(BOOL)animated{
    [self j_viewDidDisappear:animated];
    //移除 KVO
    [self removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
    [self removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItems"];
    [self removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
    [self removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItems"];
}

- (void)addNavigationItemsObserver{
    //KVO
    [self addObserver:self forKeyPath:@"navigationItem.leftBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.leftBarButtonItems" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.rightBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.rightBarButtonItems" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (!change[NSKeyValueChangeNewKey]) {
        return;
    }
    [self.navigationBar loadItems];
}

@end

@implementation UIBarButtonItem(JIMNavigationBarBarButtonItem)

+ (UIBarButtonItem *)itemWithImage:(UIImage *)image isLeft:(BOOL)isLeft block:(void(^)(id sender))block{
    
    UIEdgeInsets insets = JIMBarItemImageInsets(isLeft,image.size);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *newImage = [image imageInset:insets];
    button.j_size = newImage.size;
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    [button observeEvent:UIControlEventTouchUpInside block:block];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;
}

+ (UIBarButtonItem *)leftItemWithImage:(UIImage *)image block:(void (^)(id sender))block{
    return [self itemWithImage:image isLeft:YES block:block];
}

+ (UIBarButtonItem *)leftItemWithImageName:(NSString *)name block:(nullable void (^)(id sender))block{
    UIImage *image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return [self itemWithImage:image isLeft:YES block:block];
}

+ (UIBarButtonItem *)rightItemWithImage:(UIImage *)image block:(void (^)(id sender))block{
    return [self itemWithImage:image isLeft:NO block:block];
}

+ (UIBarButtonItem *)rightItemWithImageName:(NSString *)name block:(nullable void (^)(id sender))block{
    UIImage *image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return [self itemWithImage:image isLeft:NO block:block];
}

+ (UIBarButtonItem *)itemWithAttributeTitle:(NSArray <NSAttributedString *>*)titles isLeft:(BOOL)isLeft block:(void (^)(id sender))block{
    NSAssert(titles.count > 0, @"数组的长度不能为0");
    UIButton *button  = [UIButton buttonWithBlock:block];
    NSAttributedString *title = titles.firstObject;
    [button setAttributedTitle:title forState:UIControlStateNormal];
    NSAttributedString *highlightedTitle;
    if (titles.count >= 2) {
        highlightedTitle = titles[1];
    }
    if (titles.count == 1) {
        NSMutableAttributedString *mutableStr = [title mutableCopy];
        [mutableStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, title.length)];
        highlightedTitle = [mutableStr copy];
    }
    [button setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
    
    UIEdgeInsets insets = JIMBarItemImageInsets(YES, title.size);
    button.j_height = title.size.height + insets.top + insets.bottom;
    button.j_width = title.size.width + insets.left + insets.right;
    //left + title_W * 0.5 = (title_W + left + right) / 2 + X;
    //X = left*0.5 - right *0.5
    if (isLeft) {
        button.titleEdgeInsets = UIEdgeInsetsMake(0, (insets.left-insets.right), 0, 0);
    }else{
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, (insets.left-insets.right));
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;
}

+ (NSArray <NSAttributedString *>*)itemAttributedTitlesWithTitle:(NSString *)title{
    NSDictionary *normalAttributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateHighlighted];
    if (!normalAttributes) {
        normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont buttonFontSize]]};
    }
    if (!highlightedAttributes) {
       highlightedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont buttonFontSize]],
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    }
    NSAttributedString *normalTitle = [[NSAttributedString alloc]initWithString:title attributes:normalAttributes];
    NSAttributedString *highlightedTitle = [[NSAttributedString alloc]initWithString:title attributes:highlightedAttributes];
    return @[normalTitle,highlightedTitle];
}

+ (UIBarButtonItem *)leftItemWithTitle:(NSString *)title block:(void (^)(id sender))block{
    return [self itemWithAttributeTitle:[self itemAttributedTitlesWithTitle:title] isLeft:YES block:block];
}

+ (UIBarButtonItem *)rightItemWithTitle:(NSString *)title block:(void (^)(id sender))block{
        return [self itemWithAttributeTitle:[self itemAttributedTitlesWithTitle:title] isLeft:NO block:block];
}




@end
