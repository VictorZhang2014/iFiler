//
//  ZRAlertController.m
//  ZRAlertController
//
//  Created by Victor John on 7/1/16.
//  Copyright © 2016 Victor Studio. All rights reserved.
//
//  https://github.com/VictorZhang2014/ZRQRCodeViewController
//  An open source library for iOS that be written by Objective-C that is compatible with iOS 7.0 and later.
//  The main functionality that QR/BR Code Scanning that are easier to call.
//

#import "ZRAlertController.h" 

#define kiOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

static AlertBlock completionBlock;

static AlertBlock okayBlock;
static AlertBlock cancelBlock;

static AlertBlock1 okayBlock1;
static AlertBlock1 cancelBlock1;

static AlertBlock2 okayBlock2;
static AlertBlock2 cancelBlock2;

static ActionBlock actionBlockHandler;

typedef NS_ENUM(NSInteger){
    ZRAlertMethodStyleCompletion,
    ZRAlertMethodStyleDefault,
    ZRAlertMethodStyleOneInput,
    ZRAlertMethodStyleTwoInput
}ZRAlertMethodStyle;

@interface ZRDelegateController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate>
@property (nonatomic, assign) ZRAlertMethodStyle methodStyle;

@end

@implementation ZRDelegateController

#pragma mark - UIAlertViewDelegate events
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        switch (self.methodStyle) {
            case ZRAlertMethodStyleDefault:
                if (okayBlock)
                    okayBlock();
                break;
            case ZRAlertMethodStyleOneInput:
                if (okayBlock1)
                    okayBlock1([alertView textFieldAtIndex:0]);
                break;
            case ZRAlertMethodStyleTwoInput:
                if (okayBlock2)
                    okayBlock2([alertView textFieldAtIndex:0], [alertView textFieldAtIndex:1]);
                break;
            default:
                break;
        }
    } else {
        switch (self.methodStyle) {
            case ZRAlertMethodStyleCompletion:
                if (completionBlock)  
                    completionBlock();
                break;
            case ZRAlertMethodStyleDefault:
                if (cancelBlock)
                    cancelBlock();
                break;
            case ZRAlertMethodStyleOneInput:
                if (cancelBlock1)
                    cancelBlock1([alertView textFieldAtIndex:0]);
                break;
            case ZRAlertMethodStyleTwoInput:
                if (cancelBlock2)
                    cancelBlock2([alertView textFieldAtIndex:0], [alertView textFieldAtIndex:1]);
                break;
            default:
                break;
        }

    }
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionBlockHandler) {
        actionBlockHandler((int)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    }
}

@end




@interface ZRAlertController()
@property (nonatomic, strong) ZRDelegateController *delegateController;
@property (weak)UIAlertController* currentAlertController;
@end

@implementation ZRAlertController

- (UIViewController *)rootViewController {
    if (self.ownViewController) {
        return self.ownViewController;
    }
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

+ (instancetype)defaultAlert
{
    static ZRAlertController *alertController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertController = [[ZRAlertController alloc] init];
    });
    return alertController;
}

- (void)dismiss
{
    [self dismissWithCompletion:nil];
}


- (void)dismissWithCompletion:(void (^ __nullable)(void))completion
{
    if (self.currentAlertController && self.ownViewController.presentedViewController == self.currentAlertController) {
        [self.currentAlertController dismissViewControllerAnimated:NO completion:nil];
        if(completion){
            completion();
        }
    } else if (completion) {
        completion();
    }
}

- (ZRDelegateController *)delegateController
{
    if (!_delegateController) {
        _delegateController = [[ZRDelegateController alloc] init];
    }
    return _delegateController;
}

- (void)alertShow:(UIViewController *)controller title:(NSString *  _Nullable )title message:(NSString *)message okayButton:(NSString *)okay completion:(void (^  _Nullable )())completion
{
    completionBlock = completion;
    if (kiOS8) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:okay style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion();
            }
        }];
        [alertC addAction:action];
        [controller presentViewController:alertC animated:YES completion:nil];
    } else {
        self.delegateController.methodStyle = ZRAlertMethodStyleCompletion;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self.delegateController cancelButtonTitle:nil otherButtonTitles:okay, nil];
        [alert show];
    }
}

- (void)alertShowWithTitle:(NSString * _Nullable)title message:(NSString *)message okayButton:(NSString *)okay completion:(void(^ _Nullable)())completion
{
    [self alertShow:self.rootViewController title:title message:message okayButton:okay completion:completion];
}

- (void)alertShow:(UIViewController *)controller title:(NSString *  _Nullable )title message:(NSString *)message cancelButton:(NSString *)cancel okayButton:(NSString *)okay okayHandler:(AlertBlock)okayHandler cancelHandler:(AlertBlock)cancelHandler
{
    okayBlock = okayHandler;
    cancelBlock = cancelHandler;
    
    if (kiOS8) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action0 = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock)
                cancelBlock();
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:okay style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (okayBlock)
                okayBlock();
        }];
        [alertC addAction:action0];
        [alertC addAction:action1];
        [controller presentViewController:alertC animated:YES completion:nil];
    } else {
        self.delegateController.methodStyle = ZRAlertMethodStyleDefault;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self.delegateController cancelButtonTitle:cancel otherButtonTitles:okay, nil];
        [alert show];
    }
}

- (void)alertShowWithTitle:(NSString * _Nullable)title message:(NSString *)message cancelButton:(NSString *)cancel okayButton:(NSString *)okay okayHandler:(AlertBlock)okayHandler cancelHandler:(AlertBlock)cancelHandler
{
    [self alertShow:self.rootViewController title:title message:message cancelButton:cancel okayButton:okay okayHandler:okayHandler cancelHandler:cancelHandler];
}

- (void)alertShow:(UIViewController *)controller title:(NSString *  _Nullable )title message:(NSString *)message cancelButton:(NSString *)cancel okayButton:(NSString *)okay alertStyle:(ZRAlertStyle)style placeHolder:(NSString *)placeHolder okayHandler:(AlertBlock1)okayHandler cancelHandler:(AlertBlock1)cancelHandler
{
    okayBlock1 = okayHandler;
    cancelBlock1 = cancelHandler;
    
    if (kiOS8) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeHolder;
            if (style == ZRAlertStylePlainTextInput) {
                textField.secureTextEntry = NO;
            } else if (style == ZRAlertStyleSecureTextInput) {
                textField.secureTextEntry = YES;
            } else {
                NSLog(@"The parameter of ZRAlertStyle is not correct!");
            }
        }];
        
        UIAlertAction *action0 = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock1)
                cancelBlock1(alertC.textFields.firstObject);
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:okay style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (okayBlock1)
                okayBlock1(alertC.textFields.firstObject);
        }];
        [alertC addAction:action0];
        [alertC addAction:action1];
        [controller presentViewController:alertC animated:YES completion:nil];
        
    } else {
        
        self.delegateController.methodStyle = ZRAlertMethodStyleOneInput;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self.delegateController cancelButtonTitle:cancel otherButtonTitles:okay, nil];
        
        if (style == ZRAlertStylePlainTextInput) {
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        } else if (style == ZRAlertStyleSecureTextInput) {
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        } else {
            NSLog(@"The parameter of ZRAlertStyle is not correct!");
            return;
        }
        [alert textFieldAtIndex:0].placeholder = placeHolder;
        [alert show];
        
    }

}

- (void)alertShowWithTitle:(NSString * _Nullable)title message:(NSString *)message cancelButton:(NSString *)cancel okayButton:(NSString *)okay alertStyle:(ZRAlertStyle)style placeHolder:(NSString *)placeHolder okayHandler:(AlertBlock1)okayHandler cancelHandler:(AlertBlock1)cancelHandler
{
    [self alertShow:self.rootViewController title:title message:message cancelButton:cancel okayButton:okay alertStyle:style placeHolder:placeHolder okayHandler:okayHandler cancelHandler:cancelHandler];
}

- (void)alertShow:(UIViewController *)controller title:(NSString *  _Nullable )title message:(NSString *)message cancelButton:(NSString *)cancel okayButton:(NSString *)okay alertStyle:(ZRAlertStyle)style placeHolder1:(NSString *)placeHolder1 placeHolder2:(NSString *)placeHolder2 sureHandler:(AlertBlock2)okayHandler abolishHandler:(AlertBlock2)cancelHandler
{
    okayBlock2 = okayHandler;
    cancelBlock2 = cancelHandler;
    
    if (kiOS8) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeHolder1;
        }];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeHolder2;
            textField.secureTextEntry = YES;
        }];
        
        UIAlertAction *action0 = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock2)
                cancelBlock2(alertC.textFields.firstObject, alertC.textFields.lastObject);
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:okay style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (okayBlock2)
                okayBlock2(alertC.textFields.firstObject, alertC.textFields.lastObject);
        }];
        [alertC addAction:action0];
        [alertC addAction:action1];
        [controller presentViewController:alertC animated:YES completion:nil];
        
    } else {
        
        self.delegateController.methodStyle = ZRAlertMethodStyleTwoInput;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self.delegateController cancelButtonTitle:cancel otherButtonTitles:okay, nil];
        
        if (style == ZRAlertStyleLoginAndPasswordInput) {
            [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        } else {
            NSLog(@"The parameter of ZRAlertStyle is not correct!");
            return;
        }
        
        [alert show];
        
    }
}

- (void)alertShowWithTitle:(NSString * _Nullable)title message:(NSString *)message cancelButton:(NSString *)cancel okayButton:(NSString *)okay alertStyle:(ZRAlertStyle)style placeHolder1:(NSString *)placeHolder1 placeHolder2:(NSString *)placeHolder2 sureHandler:(AlertBlock2)okayHandler abolishHandler:(AlertBlock2)cancelHandler
{
    [self alertShow:self.rootViewController title:title message:message cancelButton:cancel okayButton:okay alertStyle:style placeHolder1:placeHolder1 placeHolder2:placeHolder2 sureHandler:okayHandler abolishHandler:cancelHandler];
}


/*
 * Action Sheet
 **/
- (void)actionView:(UIViewController *)viewController title:( NSString * _Nullable)title cancel:(NSString *)cancel others:(NSArray *)others handler:(ActionBlock)handler
{
    if (kiOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (int i = 0; i < others.count; i++) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:others[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(i + 1, others[i]);
                }
            }];
            [alertController addAction:action];
        }
        if (cancel.length) {
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(0, cancel);
                }
            }];
            [alertController addAction:actionCancel];
        }
        self.currentAlertController = alertController;
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        actionBlockHandler = handler;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:title delegate:self.delegateController cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        for (NSString *item in others) {
            [action addButtonWithTitle:item];
        }
        [action showInView:self.ownViewController.view];
    }
}

- (void)actionViewWithTitle:(NSString * _Nullable)title cancel:(NSString *)cancel others:(NSArray *)others handler:(ActionBlock)handler
{
    [self actionView:self.rootViewController title:title cancel:cancel others:others handler:handler];
}

- (void)actionViewWithTitle:(NSString * _Nullable)title cancel:(NSString *)cancel others:(NSArray *)others actionStyle:(UIAlertActionStyle)actionStyle handler:(ActionBlock)handler
{
    if (kiOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (int i = 0; i < others.count; i++) {
            UIAlertActionStyle tmpStyle = UIAlertActionStyleDefault;
            if (i == 0) {
                if (actionStyle == UIAlertActionStyleDestructive) {
                    tmpStyle = UIAlertActionStyleDestructive;
                }
            }
            UIAlertAction *action = [UIAlertAction actionWithTitle:others[i] style:tmpStyle handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(i + 1, others[i]);
                }
            }];
            [alertController addAction:action];
        }
        if (cancel.length) {
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(0, cancel);
                }
            }];
            [alertController addAction:actionCancel];
        }
        [self.rootViewController presentViewController:alertController animated:YES completion:nil];
    } else {
        actionBlockHandler = handler;
        NSString *destructiveTitle = @"";
        if (actionStyle == UIAlertActionStyleDestructive) {
            destructiveTitle = [others firstObject];
        }
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:title delegate:self.delegateController cancelButtonTitle:cancel destructiveButtonTitle:destructiveTitle otherButtonTitles:nil, nil];
        int i = 0;
        for (NSString *item in others) {
            if (actionStyle == UIAlertActionStyleDestructive && i == 0) {
                ++i;
                continue;
            }
            [action addButtonWithTitle:item];
        }
        [action showInView:self.ownViewController.view];
    }
}

@end
