//
//  UIBarButtonItem+JIMNavigationBar.h
//  JimNavigationBar
//
//  Created by Jiang on 2017/9/17.
//  

#import <UIKit/UIKit.h>
@class JIMNavigationBar;
NS_ASSUME_NONNULL_BEGIN
/**
 *     1. JIMNavigationBar消除间距是通过扩大原生间距的两倍的宽度，然后居中完成的(其实就是左右增加)，超出的部分使用self.view.clipsToBounds裁剪了
 *     2. 其内部的item和屏幕的间距是基于UIButton的imageEdgeInsets和titleEdgeInsets完成的
 *     3. 所以在使用时你需要确保UIBarButtonItem的CustomView必须是UIButton，image和title其中一个必须存在，我也没测试过两个都不存在的情况
 *     4. jimNavigationBar是在self.view层上的，UINavigationBar是在UINavigationController.view层上的
 *     5. 需要注意的是所用的ViewController的左手势都是可以使用的，必要的时候需要手动关闭
 *     6. 要保持jimNavigationBar在最上层，只能通过Controller持有一个container，Controller.view是container的子视图，而jimNavigationBar也是container的子视图，但是却在Controller.view之上。但window默认显示规则为使用控制器的view来显示。就看能不能实现了...
 **/
@interface UIViewController(JIMNavigationBar)
+(void)JIMNavigationBarMethodExChange; //在想要添加JIMNavigationBar的基类的load方法中调用
@property (nonatomic, assign)BOOL hasSet;
@property (nonatomic, assign)BOOL hiddenSysNavigationBar;
@property (nonatomic, strong, readonly)JIMNavigationBar *jimNavigationBar;
- (BOOL)isRootViewController;
@end
NS_ASSUME_NONNULL_END
