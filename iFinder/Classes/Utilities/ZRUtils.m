//
//  ZRUtils.m
//  iFinder
//
//  Created by VictorZhang on 12/05/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRUtils.h"
#import <UIKit/UIKit.h>

@implementation ZRUtils

+ (BOOL)isJailBreak
{
    NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil];
    if (applist.count > 0) {
        return YES;
    }
    return NO;
}

+ (void)loadFirstFiles
{
    NSString *cfilename = @"C Programming Language.pdf";
    NSString *cppfilename = @"C++ Programming Tutorial.pdf";
    
    NSString *sandboxPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Victor"];
    NSString *cfile = [[NSBundle mainBundle] pathForResource:cfilename ofType:@""];
    NSString *cppfile = [[NSBundle mainBundle] pathForResource:cppfilename ofType:@""];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:sandboxPath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:sandboxPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    [fileManager copyItemAtPath:cfile toPath:[sandboxPath stringByAppendingPathComponent:cfilename] error:&error];
    [fileManager copyItemAtPath:cppfile toPath:[sandboxPath stringByAppendingPathComponent:cppfilename] error:&error];
}

@end
