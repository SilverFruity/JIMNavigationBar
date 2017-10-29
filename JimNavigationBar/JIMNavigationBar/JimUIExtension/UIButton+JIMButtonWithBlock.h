//
//  UIButton+buttonWithBlock.h
//  SharedGym
//
//  Created by Jiang on 2017/4/19.
//
//

#import <UIKit/UIKit.h>

typedef void (^JkmButtonBlock)(UIButton *button);

@interface UIButton (JIMButtonWithBlock)

+ (instancetype)jm_buttonWithBlock:(JkmButtonBlock)block;

+ (instancetype)jm_buttonWithBlock:(JkmButtonBlock)block forControlEvents:(UIControlEvents)event;

- (void)jm_addActionForEvent:(UIControlEvents)event block:(JkmButtonBlock)block;

- (void)jm_addActionBlock:(JkmButtonBlock)block;

@end
