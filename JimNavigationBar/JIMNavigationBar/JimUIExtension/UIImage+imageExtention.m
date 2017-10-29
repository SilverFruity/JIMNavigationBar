//
//  UIImage+imageExtention.m
//  SharedGym
//
//  Created by Jiang on 2017/4/18.
//
//

#import "UIImage+imageExtention.h"
#define IMGEX_SCREEN_SCALE [UIScreen mainScreen].scale
@implementation UIImage (imageExtention)

+ (UIImage *)imageWithColor:(UIColor *)color{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetAlpha(context, CGColorGetAlpha(color.CGColor));
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage *)resizeImage:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(ctx, rect);
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage *)cornerImageWithCornerRadius:(CGFloat)radius{
   return [self cornerImageWithCornerRadius:radius fillColor:[UIColor clearColor]];
}

- (UIImage *)cornerImageWithCornerRadius:(CGFloat)radius fillColor:(UIColor *)fillColor{
    //绘图
    UIGraphicsBeginImageContextWithOptions(self.size, NO, IMGEX_SCREEN_SCALE);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    //填充颜色
    CGContextFillRect(context, rect);
    //利用贝塞尔曲线裁剪矩形
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [path addClip];
    //绘制图像
    [self drawInRect:rect];
    //获取图像
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageInternalInset:(UIEdgeInsets)insets{
    if (UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero)) {
        return self;
    }
    CGRect imageRect =  CGRectMake(insets.left, insets.top, self.size.width, self.size.height);
    CGSize newSize = CGSizeZero;
    newSize.height = imageRect.size.height + (insets.top + insets.bottom);
    newSize.width  = imageRect.size.width + (insets.left + insets.right);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, IMGEX_SCREEN_SCALE);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
    //绘制图像
    [self drawInRect:imageRect];
    //获取图像
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (UIImage *)imageRenderWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
