//
//  UIButton+buttonWithBlock.m
//  SharedGym
//
//  Created by Jiang on 2017/4/19.
//
//

#import "UIButton+buttonWithBlock.h"
#import <objc/runtime.h>

static char *const JMBlockCacheKey = "blockCacheKey";

@implementation UIButton (buttonWithBlock)

+ (instancetype )buttonWithBlock:(JkmButtonBlock)block{
    return [[self class] buttonWithBlock:block forControlEvents:UIControlEventTouchUpInside];
}

+ (instancetype)buttonWithBlock:(JkmButtonBlock)block forControlEvents:(UIControlEvents)event{
    UIButton *button = [[[self class]alloc]init];
    [button observeEvent:event block:block];
    return button;
}

- (void)observeEvent:(UIControlEvents)event block:(JkmButtonBlock)block{
    if (block) {
        self.JMBlock = block;
    }
    [self addTarget:self action:@selector(JkmBlockButttonTouched:) forControlEvents:event];
}

- (void)addActionBlock:(JkmButtonBlock)block{
    [self observeEvent:UIControlEventTouchUpInside block:block];
}

#pragma mark 点击
- (void)JkmBlockButttonTouched:(UIButton *)sender{
    if (self.JMBlock) {
        self.JMBlock(sender);
    }
}

#pragma mark - GET & SET
- (JkmButtonBlock)JMBlock{
    NSArray *blockCaches =  objc_getAssociatedObject(self, &JMBlockCacheKey);
    if (blockCaches == nil) {
        return nil;
    }
    return blockCaches.firstObject;
}
- (void)setJMBlock:(JkmButtonBlock)JMBlock{
    JkmButtonBlock block = [JMBlock copy];
    objc_setAssociatedObject(self, &JMBlockCacheKey, @[block], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
