//
//  NavigationBarVC.h
//  SharedGym
//
//  Created by Jiang on 2017/9/17.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class JIMNavigationBar;

static  NSString * JimNavi_BackImageName = @"";


@interface UIViewController(JIMNavigationBar)
@property (nonatomic, assign)BOOL hasSet;
@property (nonatomic, assign)BOOL hiddenSysNavigationBar;
@property (nonatomic, strong, readonly)JIMNavigationBar *navigationBar;
@end

@interface UIBarButtonItem(JIMNavigationBarBarButtonItem)

+ (UIBarButtonItem *)itemWithImage:(UIImage *)image isLeft:(BOOL)isLeft block:(nullable void(^)(id sender))block;

+ (UIBarButtonItem *)leftItemWithImage:(UIImage *)image block:(nullable void (^)(id sender))block;
+ (UIBarButtonItem *)leftItemWithImageName:(NSString *)name block:(nullable void (^)(id sender))block;

+ (UIBarButtonItem *)rightItemWithImage:(UIImage *)image block:(nullable void (^)(id sender))block;
+ (UIBarButtonItem *)rightItemWithImageName:(NSString *)name block:(nullable void (^)(id sender))block;


/**
 使用属性字符串创建item

 @param titles 第一个是普通状态下的，第二个是高亮状态，传入个数为1个的数组会使用默认的高亮状态
 @param isLeft 是否是左边的按钮
 @param block 回调
 @return UIBarButtonItem
 */
+ (UIBarButtonItem *)itemWithAttributeTitle:(NSArray <NSAttributedString *>*)titles isLeft:(BOOL)isLeft block:(void (^)(id sender))block;

+ (UIBarButtonItem *)leftItemWithTitle:(NSString *)title block:(nullable void (^)(id sender))block;
+ (UIBarButtonItem *)rightItemWithTitle:(NSString *)title block:(nullable void (^)(id sender))block;

@end
NS_ASSUME_NONNULL_END
