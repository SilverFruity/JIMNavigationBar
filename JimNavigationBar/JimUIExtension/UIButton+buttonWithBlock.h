//
//  UIButton+buttonWithBlock.h
//  SharedGym
//
//  Created by Jiang on 2017/4/19.
//
//

#import <UIKit/UIKit.h>

typedef void (^JkmButtonBlock)(UIButton *button);

@interface UIButton (buttonWithBlock)

+ (instancetype)buttonWithBlock:(JkmButtonBlock)block;

+ (instancetype)buttonWithBlock:(JkmButtonBlock)block forControlEvents:(UIControlEvents)event;

- (void)observeEvent:(UIControlEvents)event block:(JkmButtonBlock)block;

- (void)addActionBlock:(JkmButtonBlock)block;

@end
