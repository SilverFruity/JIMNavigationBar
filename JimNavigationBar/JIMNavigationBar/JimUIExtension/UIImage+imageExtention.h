//
//  UIImage+imageExtention.h
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (imageExtention)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)resizeImage:(CGSize)size;

- (UIImage *)cornerImageWithCornerRadius:(CGFloat)radius;

- (UIImage *)cornerImageWithCornerRadius:(CGFloat)radius fillColor:(UIColor *)fillColor;

- (UIImage *)imageInternalInset:(UIEdgeInsets)insets;

- (UIImage *)imageRenderWithColor:(UIColor *)color;

@end

