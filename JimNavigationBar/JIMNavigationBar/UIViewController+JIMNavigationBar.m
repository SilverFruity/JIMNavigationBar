//
//  NavigationBarVC.m
//  SharedGym
//
//  Created by Jiang on 2017/9/17.
//

#import "UIViewController+JIMNavigationBar.h"
#import "JIMNavigationBar.h"
#import "UIButton+JIMButtonWithBlock.h"
#import "UIView+JimFrameExtension.h"
#import <objc/runtime.h>
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

- (BOOL)isRootViewController{
    return self.navigationController.childViewControllers.firstObject == self;
}

- (JIMNavigationBar *)jimNavigationBar{
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
    //系统相册自带一个UINavigationController
    if ([self.parentViewController isKindOfClass:[UIImagePickerController class]]) {
        return;
    }
    [self.navigationController.navigationBar setHidden:self.hiddenSysNavigationBar];
    
    if (self.hasSet) return;
    
    if (self.navigationController && self.hiddenSysNavigationBar) {
        [self.view addSubview:self.jimNavigationBar];;
        CGRect naviFrame = self.navigationController.navigationBar.frame;
        CGFloat widthExtend = JIMNavigationBar_ToolBarWidthExtend > 0 ? JIMNavigationBar_ToolBarWidthExtend : 0;
        CGRect barFrame = CGRectMake(-0.5 * widthExtend, 0, CGRectGetWidth(naviFrame) + widthExtend, CGRectGetHeight(naviFrame));
        CGFloat maxY = CGRectGetMaxY(naviFrame);
        CGFloat height = CGRectGetHeight(naviFrame);
        self.jimNavigationBar.frame =  naviFrame;
        self.jimNavigationBar.toolbar.frame = barFrame;
        self.jimNavigationBar.toolbar.contentInsets = UIEdgeInsetsMake(maxY - height , 0, 0, 0);

        self.view.clipsToBounds = JIMNavigationBar_ToolBarWidthExtend > 0;

        [self.jimNavigationBar loadItems];

        self.hasSet = YES;

        [self addNavigationItemsObserver];
    }
}

- (void)j_viewDidDisappear:(BOOL)animated{
    [self j_viewDidDisappear:animated];
    if (self.navigationController || !self.hasSet) {
        return;
    }
    //移除 KVO
    [self removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
    [self removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItems"];
    [self removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
    [self removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItems"];
    [self removeObserver:self forKeyPath:@"navigationItem.title"];
    [self removeObserver:self forKeyPath:@"navigationItem.titleView"];
}


- (void)addNavigationItemsObserver{
    //KVO
    [self addObserver:self forKeyPath:@"navigationItem.leftBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.leftBarButtonItems" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.rightBarButtonItem" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.rightBarButtonItems" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.title" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationItem.titleView" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (change[NSKeyValueChangeNewKey] == [NSNull null] || !self.hiddenSysNavigationBar) {
        return;
    }
    [self.jimNavigationBar loadItems];
}

@end

@implementation UIBarButtonItem(JIMNavigationBarBarButtonItem)

+ (UIBarButtonItem *)itemWithImage:(UIImage *)image block:(void(^)(id sender))block{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *newImage = image;
    button.j_size = newImage.size;
    [button setImage:newImage forState:UIControlStateNormal];
    [button jm_addActionForEvent:UIControlEventTouchUpInside block:block];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;
}
+ (UIBarButtonItem *)itemWithImageName:(NSString *)imageName block:(nullable void(^)(id sender))block{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self itemWithImage:image block:block];
}

+ (UIBarButtonItem *)itemWithNormalTitle:(NSAttributedString *)normalTitle
                        highlightedTitle:(NSAttributedString *)highlighted
                                   block:(void (^)(id sender))block{
    UIButton *button  = [UIButton jm_buttonWithBlock:block];
    [button setAttributedTitle:normalTitle forState:UIControlStateNormal];
    NSAttributedString *highlightedTitle = highlighted;
    if (!highlightedTitle) {
        NSMutableAttributedString *mutableStr = [normalTitle mutableCopy];
        [mutableStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, normalTitle.length)];
        highlightedTitle = [mutableStr copy];
    }
    [button setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    return item;
}

+ (NSArray <NSAttributedString *>*)itemAttributedTitlesWithTitle:(NSString *)title{
    NSDictionary *normalAttributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateHighlighted];
    if (!normalAttributes) {
        normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    }
    if (!highlightedAttributes) {
       highlightedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    }
    NSAttributedString *normalTitle = [[NSAttributedString alloc]initWithString:title attributes:normalAttributes];
    NSAttributedString *highlightedTitle = [[NSAttributedString alloc]initWithString:title attributes:highlightedAttributes];
    
    return @[normalTitle,highlightedTitle];
}

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title block:(nullable void (^)(id sender))block{
    NSArray <NSAttributedString *>*titles = [self itemAttributedTitlesWithTitle:title];
    return [self itemWithNormalTitle:titles.firstObject highlightedTitle:titles.lastObject block:block];
}





@end