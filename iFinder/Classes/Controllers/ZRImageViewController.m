//
//  ZRImageViewController.m
//  iFinder
//
//  Created by VictorZhang on 05/05/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRImageViewController.h"
#import "UIImage+Helper.h"

@interface ZRImageViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZRImageViewController
- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _originalImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self toggleNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_backarrow"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissPresentVC)];
    
    /*
     * As the Apple Documentation said, it is the easiest way to implement pinch-in and pinch-out on an UIImageView, see below links.
     * http://stackoverflow.com/questions/500027/how-to-zoom-in-out-an-uiimage-object-when-user-pinches-screen
     * https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/UIScrollView_pg/ZoomZoom/ZoomZoom.html
     *
     */
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 6.0;
    _scrollView.contentSize = CGSizeMake(1280, 960);
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    UIImage *scaledImg = [self.originalImage aspectScaleToSize:rect.size];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:scaledImg];
    CGFloat Y = (rect.size.height - scaledImg.size.height) / 2;
    imgView.frame = CGRectMake(0, Y, rect.size.width, rect.size.height);
    imgView.userInteractionEnabled = YES;
    [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar)]];
    [imgView setMultipleTouchEnabled:YES];
    _imageView = imgView;
    [_scrollView addSubview:imgView];
    
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)toggleNavigationBar {
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else {
        self.navigationController.navigationBar.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    self.navigationController.navigationBar.alpha = 0.7;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    CGRect rect = [UIScreen mainScreen].bounds;
    self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height + rect.origin.y);
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)dismissPresentVC {
    self.navigationController.navigationBar.alpha = 1.0;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
