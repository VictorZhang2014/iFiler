//
//  ZRHomeViewController.m
//  iFinder
//
//  Created by VictorZhang on 17/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRHomeViewController.h"
#import "ZRMainViewController.h"
#import "ZRFileUtil.h"
#import "UIView+Toast.h"
#import "ZRAlertController.h"
#import "ZRUtils.h"
//#import <MobileCoreServices/MobileCoreServices.h>
//#import <CloudKit/CloudKit.h>

#define TYPE_PUBLIC_IMAGE @"public.image"
#define TYPE_PUBLIC_VIDEO @"public.movie"

@interface ZRHomeViewController()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//@property (nonatomic, strong) NSMetadataQuery *dataQuery;

@end

@implementation ZRHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home and Recent";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        if ([ZRUtils isJailBreak]) {
            [self gointoHomeDirectory:@[NSHomeDirectory()] title:@"Home"];
        } else {
            [self gointoHomeDirectory:@[[NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()]] title:@"Home"];
        }
    } else if (indexPath.row == 1) {
        [self gointoHomeDirectory:@[[NSString stringWithFormat:@"%@/Documents/Inbox", NSHomeDirectory()], [NSString stringWithFormat:@"%@/Documents/Victor", NSHomeDirectory()]] title:@"Download from Airdrop"];
    } else if (indexPath.row == 2) {
        [self gointoPhotoLibrary];
    } else if (indexPath.row == 3) {
//        [self gointoiCloudDrive];
    }
    

}

- (void)gointoHomeDirectory:(NSArray *)paths title:(NSString *)title
{
    NSError *error = nil;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSString *path in paths) {
         NSArray *nextPathArray = [ZRFileUtil getDirectoriesByPathname:path error:&error];
        [list addObjectsFromArray:nextPathArray];
    }
    
    ZRMainViewController *nextVC = [[ZRMainViewController alloc] init];
    nextVC.customTitle = title;
    nextVC.directories = list;
    nextVC.isSubPath = YES;
    nextVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)gointoPhotoLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate event
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:TYPE_PUBLIC_IMAGE]) {
        UIImage *mediaImage = nil;
        if (picker.allowsEditing) {
            mediaImage = info[UIImagePickerControllerEditedImage];
        } else {
            mediaImage = info[UIImagePickerControllerOriginalImage];
        }
        [self AirDropWithObject:mediaImage withVC:picker];
    } else if ([mediaType isEqualToString:TYPE_PUBLIC_VIDEO]) {
        NSString *videoPath = info[UIImagePickerControllerMediaURL];
        [self AirDropWithObject:videoPath withVC:picker];
    }
}

- (void)AirDropWithObject:(id)object withVC:(UIViewController *)vc {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[object] applicationActivities:nil];
    controller.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    };
    [vc presentViewController:controller animated:YES completion:nil];
}

//- (void)gointoiCloudDrive {
//    
////    NSFileManager *fileMng = [NSFileManager defaultManager];
////    NSURL *url = [fileMng URLForUbiquityContainerIdentifier:nil];
////    if (!url) {
////        [[ZRAlertController defaultAlert] alertShowWithTitle:@"" message:@"iCloud is not available! Please ensure that whether iCloud has been opened!" okayButton:@"Okay" completion:nil];
////        return;
////    }
////    
////    NSString *DocumentsPath = [url URLByAppendingPathComponent:@"Documents"];
////    
//    
//    CKContainer *container = [CKContainer defaultContainer];
//    CKDatabase *database_pub = container.publicCloudDatabase;//公共数据
//    CKDatabase *database_pri = container.privateCloudDatabase;//隐私数据
//    
//    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
//    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"1" predicate:predicate];
//    
//    [database_pub performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
//        
//        NSLog(@"%@",results);
//    }];
//    
//    [database_pri performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
//        
//        NSLog(@"%@",results);
//    }];
//    
//    
//    return;
//    _dataQuery = [[NSMetadataQuery alloc] init];
//    _dataQuery.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
//    _dataQuery.predicate = [NSPredicate predicateWithValue:YES];
//
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryDidUpdate:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
//    
//    [_dataQuery startQuery];
//}
//
//- (void)metadataQueryDidUpdate:(NSNotification *)noti {
//    NSArray *results = [_dataQuery results];
//    for (id item in results) {
//        
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
//        [_dataQuery stopQuery];
//    }
//    
////    let results = metaQuery.results
////    for item in results {
////        let fileURL = item.valueForAttribute(NSMetadataItemURLKey)
////    }
////    NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
////    NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidUpdateNotification, object: nil)
////    metaQuery.stopQuery()
//}

@end
