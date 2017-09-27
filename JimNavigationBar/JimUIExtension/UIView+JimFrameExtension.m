//
//  UIView+AjustFrame.m
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import "UIView+JimFrameExtension.h"

@implementation UIView (JimFrameExtension)
- (CGSize)j_size{
    return self.frame.size;
}

- (void)setJ_size:(CGSize)j_size{
    self.j_width = j_size.width;
    self.j_height = j_size.height;
}

- (CGFloat)j_height{
    return CGRectGetHeight(self.frame);
}
- (void)setJ_height:(CGFloat)j_height{
    self.frame = CGRectMake(self.j_x, self.j_y, self.j_width, j_height);
}

- (CGFloat)j_width{
    return self.frame.size.width;
}
- (void)setJ_width:(CGFloat)j_width{
    self.frame = CGRectMake(self.j_x, self.j_y, j_width, self.j_height);
}

- (CGPoint)j_origin{
    return self.frame.origin;
}

- (void)setJ_origin:(CGPoint)j_origin{
    self.frame = CGRectMake(j_origin.x, j_origin.y, self.j_width, self.j_height);
}

- (void)setJ_x:(CGFloat)j_x{
    self.frame = CGRectMake(j_x, self.j_y, self.j_width, self.j_height);
}

- (CGFloat)j_x{
    return self.frame.origin.x;
}

- (CGFloat)j_y{
    return self.frame.origin.y;
}

- (void)setJ_y:(CGFloat)j_y{
    self.frame = CGRectMake(self.j_x, j_y, self.j_width, self.j_height);
}

@end
