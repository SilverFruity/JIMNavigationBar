//
//  UIView+AjustFrame.h
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import <UIKit/UIKit.h>


@interface UIView (JimFrameExtension)

- (CGSize)j_size;
- (void)setJ_size:(CGSize)j_size;

- (CGFloat)j_height;
- (void)setJ_height:(CGFloat)j_height;

- (CGFloat)j_width;
- (void)setJ_width:(CGFloat)j_width;

- (CGPoint)j_origin;
- (void)setJ_origin:(CGPoint)j_origin;

- (CGFloat)j_x;
- (void)setJ_x:(CGFloat)j_x;

- (CGFloat)j_y;
- (void)setJ_y:(CGFloat)j_y;


@end
