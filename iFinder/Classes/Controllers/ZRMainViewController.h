//
//  ViewController.h
//  iFinder
//
//  Created by VictorZhang on 16/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZRFileModel;
@interface ZRMainViewController : UITableViewController

@property (nonatomic, copy) NSString *customTitle;

@property (nonatomic, assign) BOOL isSubPath;

@property (nonatomic, strong) NSArray<ZRFileModel *> *directories;

@end

