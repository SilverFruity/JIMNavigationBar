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
static char JimNavigationBarContainerKey;
static char JimNavigationBarUseRealViewKey;

@implementation UIViewController(JIMNavigationBar)
+(void)JIMNavigationBarMethodExChange{
    
#if DEBUG
   NSDictionary *methodsExChangedCache =  [self classExchangedMethodsCache];
#endif
    
    //view getter
    [self ExChangeMethodWithSelectorString:@"view"];
    
    //loadView
    [self ExChangeMethodWithSelectorString:@"loadView"];
    
    //viewDidLoad
    [self ExChangeMethodWithSelectorString:@"viewDidLoad"];
    
    //viewWillAppear
    [self ExChangeMethodWithSelectorString:@"viewWillAppear:"];
    
    
#if !__has_feature(objc_arc)
    //dealloc
    [self ExChangeMethodWithSelectorString:@"dealloc"];//只有在MRC下才能获取到dealloc方法
#else
    //如果遇见编译错误: "cannot create __weak reference in file using manual reference counting"
    //将Build Settings -> Weak References in Manual Retain Release 改为 YES
    NSAssert(NO, @"请将UIViewController+JIMNavigationBar.m 改为-fno-objc-arc");
#endif
    
    
#if DEBUG
    [methodsExChangedCache setValue:@(YES) forKey:NSStringFromClass(self)];
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


- (UIView *)jimNavigationBarContainer{
    return objc_getAssociatedObject(self, &JimNavigationBarContainerKey);
}

- (void)setJimNavigationBarContainer:(UIView *)jimNavigationBarContainer{
    return objc_setAssociatedObject(self, &JimNavigationBarContainerKey, jimNavigationBarContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)useRealView{
    NSNumber *useRealView = objc_getAssociatedObject(self, &JimNavigationBarUseRealViewKey);
    return useRealView?useRealView.boolValue : NO;
}
- (void)setUseRealView:(BOOL)useRealView{
    objc_setAssociatedObject(self, &JimNavigationBarUseRealViewKey, @(useRealView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - methods swizzling
- (UIView *)j_view{
    if (self.useRealView) {
        return self.jimNavigationBarContainer;
    }
    return self.jimNavigationBarContainer.subviews.firstObject;
}

- (void)j_loadView{
    self.jimNavigationBarContainer = [UIView new];
    UIView *subView = [UIView new];
    subView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.jimNavigationBarContainer addSubview:subView];
    self.view = self.jimNavigationBarContainer;
}

- (void)j_viewDidLoad{
    [self j_viewDidLoad];
    
//    self.useRealView = YES;
}

- (void)j_viewWillAppear:(BOOL)animated{
    [self j_viewWillAppear:animated];
    //系统相册自带一个UINavigationController
    if ([self.parentViewController isKindOfClass:[UIImagePickerController class]]) {
        return;
    }
    
    [self.navigationController.navigationBar setHidden:self.hiddenSysNavigationBar];
    
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

+ (void)ExChangeMethodWithSelectorString:(NSString *)selectorString{
    //view getter
    Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(selectorString));
    Method j_Method = class_getInstanceMethod(self, NSSelectorFromString([NSString stringWithFormat:@"j_%@",selectorString]));
    method_exchangeImplementations(originalMethod, j_Method);
#if DEBUG
    [self whetherWillExchangUIViewControllerMethod:selectorString];
#endif
}

//如果是UIViewController的子类，则不能交换UIViewController的方法实现
+ (void)whetherWillExchangUIViewControllerMethod:(NSString *)selectorString{
    if (![NSStringFromClass(self) isEqualToString:@"UIViewController"]) {
        IMP dealloc1 = class_getMethodImplementation(self, NSSelectorFromString(selectorString));
        IMP dealloc2 = class_getMethodImplementation([UIViewController class], NSSelectorFromString(selectorString));
        NSAssert(dealloc1 != dealloc2, @"%@ need implement method `%@`",self,selectorString);
    }
}

+ (NSDictionary *)classExchangedMethodsCache{
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
    return MethodsHasExChangedCache;
}
@end


