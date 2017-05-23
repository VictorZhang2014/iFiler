//
//  ZROpenFileViewController.m
//  iFinder
//
//  Created by VictorZhang on 22/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZROpenFileViewController.h"
#import "ZRFileModel.h"

@interface ZROpenFileViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ZROpenFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    switch (self.fileModel.fileType) {
        case ZRFileTypePDF:
        case ZRFileTypePPT: {
            [self openDocumentWithPathname:self.fileModel.path];
            break;
        }
        default: {
            [self openFileInWebViewWithPathname:self.fileModel.path];
            break;
        }
    }
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openDocumentWithPathname:(NSString *)pathname {
    NSURL *url = [NSURL fileURLWithPath:pathname];
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    documentController.delegate = self;
    [documentController presentPreviewAnimated:YES];
}

- (void)openFileInWebViewWithPathname:(NSString *)pathname {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:webView];
    _webView = webView;
    
    NSURL *url = [NSURL fileURLWithPath:pathname];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

@end
