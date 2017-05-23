//
//  UIImage+Helper.m
//  iFinder
//
//  Created by VictorZhang on 05/05/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)

- (UIImage *)aspectScaleToSize:(CGSize)size {
    CGSize imageSize = CGSizeMake(self.size.width, self.size.height);
    
    CGFloat hScaleFactor = imageSize.width / size.width;
    CGFloat vScaleFactor = imageSize.height / size.height;
    
    CGFloat scaleFactor = MAX(hScaleFactor, vScaleFactor);
    
    CGFloat newWidth = imageSize.width   / scaleFactor;
    CGFloat newHeight = imageSize.height / scaleFactor;
    
    // center vertically or horizontally in size passed
    CGFloat leftOffset = (size.width - newWidth) / 2;
    CGFloat topOffset = (size.height - newHeight) / 2;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    }

    [self drawInRect:CGRectMake(leftOffset, topOffset, newWidth, newHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


@end
