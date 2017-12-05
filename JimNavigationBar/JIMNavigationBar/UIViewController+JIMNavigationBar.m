//
//  UIBarButtonItem+JIMNavigationBar.m
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/17.
//

#import "UIViewController+JIMNavigationBar.h"
#import "JIMNavigationBar.h"
#import <objc/runtime.h>

static char JIMNavigationBarKey;
static char JIMNavigationBarHasSetKey;
static char JIMNavigationHiddenSysNavigationBarKey;
static char JIMNavigationBarInheritColor;

@implementation UIViewController(JIMNavigationBar)

+(void)JIMNavigationBarMethodExChange{
#if DEBUG
    static NSMutableDictionary *MethodsHasExChangedCache = nil; //检测父类是否已经交换过方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MethodsHasExChangedCache = [NSMutableDictionary dictionary];
    });
    Class currentClass = [self superclass];
    while (![NSStringFromClass(currentClass) isEqualToString:@"UIResponder"]) { //针对先是父类交换后，子类再进行交换的情况
        NSNumber *hasExChanged = [MethodsHasExChangedCache valueForKey:NSStringFromClass(currentClass)];
        if (hasExChanged){
            NSAssert2(!hasExChanged, @"has Exchanged superClass(%@)'s Methods, currentClass is %@",currentClass,self);
        }
        currentClass = [currentClass superclass];
    }
    for (NSString *class in MethodsHasExChangedCache.allKeys) { //针对先是子类交换后，父类再进行交换的情况
        NSString *superClassString = NSStringFromClass(NSClassFromString(class).superclass);
        BOOL hasExChanged = [superClassString isEqualToString:NSStringFromClass(self)];
        NSAssert2(!hasExChanged, @"has Exchanged superClass(%@)'s Methods, currentClass is %@",self,class);
    }
#endif

    Method viewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method j_viewWillAppear = class_getInstanceMethod(self, @selector(j_viewWillAppear:));
#if DEBUG
    //如果是UIViewController的子类，则不能交换UIViewController的方法实现，需要自己实现改方法并调用super
    if (![NSStringFromClass(self) isEqualToString:@"UIViewController"]) {
        IMP willAppear1 = class_getMethodImplementation(self, @selector(viewWillAppear:));
        IMP willAppear2 = class_getMethodImplementation([UIViewController class], @selector(viewWillAppear:));
        NSAssert(willAppear1 != willAppear2, @"%@ need implement method `viewWillAppear:`",self);
    }
#endif
    method_exchangeImplementations(viewWillAppear, j_viewWillAppear);

    
    Method viewDidLayoutSubviews = class_getInstanceMethod(self, @selector(viewDidLayoutSubviews));
    Method j_viewDidLayoutSubviews = class_getInstanceMethod(self, @selector(j_viewDidLayoutSubviews));
#if DEBUG
    //如果是UIViewController的子类，则不能交换UIViewController的方法实现，需要自己实现改方法并调用super
    if (![NSStringFromClass(self) isEqualToString:@"UIViewController"]) {
        IMP layoutSubViews1 = class_getMethodImplementation(self, @selector(viewDidLayoutSubviews));
        IMP layoutSubViews2 = class_getMethodImplementation([UIViewController class], @selector(viewDidLayoutSubviews));
        NSAssert(layoutSubViews1 != layoutSubViews2, @"%@ need implement method `viewDidLayoutSubviews:`",self);
    }
#endif
    method_exchangeImplementations(viewDidLayoutSubviews, j_viewDidLayoutSubviews);

#if !__has_feature(objc_arc)
    Method dealloc = class_getInstanceMethod(self, @selector(dealloc));  //只有在MRC下才能获取到dealloc方法
    Method j_dealloc = class_getInstanceMethod(self, @selector(j_dealloc));
    method_exchangeImplementations(dealloc, j_dealloc);
    #if DEBUG
    //如果是UIViewController的子类，则不能交换UIViewController的方法实现
    if (![NSStringFromClass(self) isEqualToString:@"UIViewController"]) {
        IMP dealloc1 = class_getMethodImplementation(self, @selector(dealloc));
        IMP dealloc2 = class_getMethodImplementation([UIViewController class], @selector(dealloc));
        NSAssert(dealloc1 != dealloc2, @"%@ need implement method `dealloc`",self);
    }
    #endif
    
#else
    NSAssert(NO, @"请将UIViewController+JIMNavigationBar.m 改为-fno-objc-arc");
#endif
    
    
#if DEBUG
    [MethodsHasExChangedCache setValue:@(YES) forKey:NSStringFromClass(self)];
#endif
}

#if !__has_feature(objc_arc)
- (void)j_dealloc{
    if (objc_getAssociatedObject(self, &JIMNavigationBarKey)) { //避免在dealloc的时候调用懒加载导致崩溃
        [self.jimNavigationBar removeCallerObservers:self];
        [self.jimNavigationBar release];
    }
    NSNumber *hasSet = objc_getAssociatedObject(self, &JIMNavigationBarHasSetKey);
    if (hasSet) [hasSet release];
    NSNumber *hidden = objc_getAssociatedObject(self, &JIMNavigationHiddenSysNavigationBarKey);
    if (hidden) [hidden release];
    [self j_dealloc];
}
#endif
- (void)j_viewDidLayoutSubviews{
    [self j_viewDidLayoutSubviews];
    if (!self.jimNavigationBar.hidden) {
        [self.view bringSubviewToFront:self.jimNavigationBar];
    }
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
- (BOOL)jimNavigationBarHasSet{
    NSNumber *has = objc_getAssociatedObject(self, &JIMNavigationBarHasSetKey);
    return has ? has.boolValue : NO;
}

- (void)setJimNavigationBarHasSet:(BOOL)jimNavigationBarHasSet{
    [self willChangeValueForKey:@"jimNavigationBarHasSet"];
    objc_setAssociatedObject(self, &JIMNavigationBarHasSetKey, @(jimNavigationBarHasSet), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"jimNavigationBarHasSet"];
}

- (BOOL)hiddenSysNavigationBar{
    NSNumber *hidden = objc_getAssociatedObject(self, &JIMNavigationHiddenSysNavigationBarKey);
    return hidden ? hidden.boolValue : YES;
}

- (void)setHiddenSysNavigationBar:(BOOL)hiddenSysNavigationBar{
    objc_setAssociatedObject(self, &JIMNavigationHiddenSysNavigationBarKey, @(hiddenSysNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)inheritCoverColor{
    NSNumber *inherit = objc_getAssociatedObject(self, &JIMNavigationBarInheritColor);
    return inherit ? inherit.boolValue : YES;
}
- (void)setInheritCoverColor:(BOOL)inheritColor{
    objc_setAssociatedObject(self, &JIMNavigationBarInheritColor, @(inheritColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)j_viewWillAppear:(BOOL)animated{
    [self j_viewWillAppear:animated];
    //系统相册自带一个UINavigationController
    if ([self.parentViewController isKindOfClass:[UIImagePickerController class]]) {
        return;
    }
    [self.navigationController.navigationBar setHidden:self.hiddenSysNavigationBar];
    
    if (self.jimNavigationBar.hidden) return;
    if (self.jimNavigationBarHasSet) return;
    
    if (self.navigationController && self.hiddenSysNavigationBar) {
        self.navigationController.view.backgroundColor = [UIColor whiteColor];//不设置颜色会导致在半透明的时候出现黑框
        [self.view addSubview:self.jimNavigationBar];
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

        self.jimNavigationBarHasSet = YES;
    }
}

@end


