//
//  ZRImageViewController.h
//  iFinder
//
//  Created by VictorZhang on 05/05/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZRImageViewController : UIViewController

@property (nonatomic, strong, readonly) UIImage *originalImage;

- (instancetype)initWithImage:(UIImage *)image;

@end
