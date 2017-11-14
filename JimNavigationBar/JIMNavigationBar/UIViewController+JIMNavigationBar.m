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
static char JIMNavigationSetKey;
static char JIMNavigationHiddenSysNavigationBarKey;

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


#if !__has_feature(objc_arc)
    Method dealloc = class_getInstanceMethod(self, @selector(dealloc));
    Method j_dealloc = class_getInstanceMethod(self, @selector(j_dealloc));
    method_exchangeImplementations(dealloc, j_dealloc);
    #if DEBUG
    //如果是UIViewController的子类，则不能交换UIViewController的方法实现，需要自己实现改方法并调用super
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
    //移除 KVO
    [self removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
    [self removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItems"];
    [self removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
    [self removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItems"];
    [self removeObserver:self forKeyPath:@"navigationItem.title"];
    [self removeObserver:self forKeyPath:@"navigationItem.titleView"];
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


