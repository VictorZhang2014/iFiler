//
//  ViewController.m
//  iFinder
//
//  Created by VictorZhang on 16/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRMainViewController.h"
#import "ZRFileUtil.h"
#import "ZRFileModel.h"
#import "UIView+Toast.h"
#import "ZRAlertController.h"
#import "ZROpenFileViewController.h"
#import "ZRImageViewController.h"

#define  ZRCellForHeight        55


@interface ZRMainViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ZRMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.customTitle.length) {
        self.title = self.customTitle;
    } else {
        self.title = @"root";
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self configureData];
}

- (void)configureData
{
    if (!self.isSubPath) {
        NSError *error = nil;
        self.directories = [ZRFileUtil getDirectoriesByPathname:@"/" error:&error];
    }
    
    NSString *countStr = [NSString stringWithFormat:@"File(s):%ld", self.directories.count];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:countStr style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directories.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ZRCellForHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZRFileModel *model = [self.directories objectAtIndex:indexPath.row];
    
    NSString *reuse_cell = @"directory_reuse_cell";
    if (self.customTitle.length) {
        reuse_cell = [NSString stringWithFormat:@"%@_directory_reuse_cell", self.customTitle];
    }
    
//    int timeLabTag = 10;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse_cell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse_cell];
        
//        CGFloat tw = 80;
//        CGFloat th = 20;
//        CGFloat tx = tableView.frame.size.width - tw;
//        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(tx, 5, tw, th)];
//        time.textColor = WHOLLY_COLOR_GRAY;
//        time.font = WHOLLY_FONT13;
//        time.tag = timeLabTag;
//        [cell.contentView addSubview:time];
    }
    
    
    cell.textLabel.text = model.name;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.detailTextLabel.text = model.path;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    
    if (model.fileType == ZRFileTypeJPG) {
        cell.imageView.image = [UIImage imageNamed:model.path];
    } else {
        cell.imageView.image = [UIImage imageNamed:model.fileIcon];
    }
    
//    UILabel *timelabel = [cell.contentView viewWithTag:timeLabTag];
//    if (timelabel && model.fileModificationDate) {
//        timelabel.text = [model.fileModificationDate substringToIndex:10];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //此方法不能删除，因为在iOS8的真机时，editActionsForRowAtIndexPath方法会不起作用，只有实现了此方法，方可在iOS8上使用
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZRFileModel *model = [self.directories objectAtIndex:indexPath.row];
    
    UITableViewRowAction *copy = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"COPY" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        ZRFileModel *model = [self.directories objectAtIndex:indexPath.row];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = model.path;
        
        NSString *fullString = [NSString stringWithFormat:@"%@", model.path];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:@"Copy to PasteBoard successfully! " preferredStyle:UIAlertControllerStyleAlert];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.secureTextEntry = NO;
            textField.text = fullString;
        }];
        UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:action0];
        [self.navigationController presentViewController:alertC animated:YES completion:nil];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"DELETE" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        ZRFileModel *model = [self.directories objectAtIndex:indexPath.row];
        NSFileManager *fileMng = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileMng removeItemAtURL:[NSURL fileURLWithPath:model.path] error:&error];
        if (error) {
            [self.view makeToast:[NSString stringWithFormat:@"Delete Failed! "]];
        }
        
        NSRange range = [model.path rangeOfString:model.name];
        model.path = [model.path substringToIndex:range.location];
        NSArray *nextPathArray = [ZRFileUtil getDirectoriesByPathname:model.path error:&error];
        self.directories = nextPathArray;
        [self.tableView reloadData];
        
    }];
    
    UITableViewRowAction *airdrop = nil;
    if (model.fileType != ZRFileTypeFolder) {
        airdrop = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"AirDrop" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            ZRFileModel *model = [self.directories objectAtIndex:indexPath.row];
            if (model.fileType == ZRFileTypeJPG) {
                UIImage *image = [UIImage imageWithContentsOfFile:model.path];
                [self AirDropWithObject:image];
            } else {
                //路径前面必须添加file://  否则传到MacBook Pro就变成了路径
                [self AirDropWithObject:[NSURL fileURLWithPath:model.path]];
            }
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }];
        
        return @[delete, copy, airdrop];
    }

    
    return @[copy];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZRFileModel *model = [self.directories objectAtIndex:indexPath.row];
    NSError *error = nil;
    NSArray *nextPathArray = [ZRFileUtil getDirectoriesByPathname:model.path error:&error];
    if (nextPathArray.count <= 0) {
//        [self.view makeToast:[NSString stringWithFormat:@"No more content was found in %@", model.path] duration:1.0 position:CSToastPositionCenter];
    }
    
    if (model.fileType == ZRFileTypeJPG) {
        ZRImageViewController *imgVC = [[ZRImageViewController alloc] initWithImage:[UIImage imageWithContentsOfFile:model.path]];
        [self.navigationController pushViewController:imgVC animated:YES];
        return;
    }
    
    if (model.fileType != ZRFileTypeFolder) {
        ZROpenFileViewController *openFile = [[ZROpenFileViewController alloc] init];
        openFile.fileModel = model;
        openFile.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:openFile animated:YES];
        return;
    }
    
    
    ZRMainViewController *nextVC = [[ZRMainViewController alloc] init];
    if (model.name.length)
        nextVC.customTitle = model.name;
    nextVC.directories = nextPathArray;
    nextVC.isSubPath = YES;
    nextVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)AirDropWithObject:(id)object {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[object] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"ZRMainViewController has been deallocated!");
}

@end
