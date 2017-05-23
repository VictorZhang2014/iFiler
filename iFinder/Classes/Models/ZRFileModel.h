//
//  ZRFileModel.h
//  iFinder
//
//  Created by VictorZhang on 17/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ZRFileType) {
    ZRFileTypeFolder            = 0,
    ZRFileTypeDoc               = 1,
    ZRFileTypeXls               = 2,
    ZRFileTypePPT               = 3,
    ZRFileTypePDF               = 4,
    ZRFileTypeTxt               = 5,
    ZRFileTypeHtml              = 6,
    ZRFileTypeJS                = 7,
    ZRFileTypeJPG               = 8,
    ZRFileTypeZIP               = 9,
    ZRFileTypeVideo             = 10,
    ZRFileTypeMusic             = 11,
    ZRFileTypeDownload          = 12,
    ZRFileTypeFile              = 13,
};


@interface ZRFileModel : NSObject

//名称
@property (nonatomic, copy) NSString *name;

//路径
@property (nonatomic, copy) NSString *path;

//是否是目录
@property (nonatomic, assign) BOOL isDirectory;

//类型
@property (nonatomic, assign) ZRFileType fileType;

//文件icon名称
@property (nonatomic, copy) NSString *fileIcon;

/*
 * 文件属性
 * 有如下这些属性
     NSFileCreationDate = "1970-01-01 00:00:00 +0000";
     NSFileExtensionHidden = 0;
     NSFileGroupOwnerAccountID = 80;
     NSFileGroupOwnerAccountName = admin;
     NSFileModificationDate = "1970-01-01 00:00:00 +0000";
     NSFileOwnerAccountID = 0;
     NSFileOwnerAccountName = root;
     NSFilePosixPermissions = 509;
     NSFileReferenceCount = 92;
     NSFileSize = 2944;
     NSFileSystemFileNumber = 19283;
     NSFileSystemNumber = 16777218;
     NSFileType = NSFileTypeDirectory;
 */
@property (nonatomic, strong) NSDictionary *attributesOfFile;

//文件创建时间
@property (nonatomic, copy) NSString *fileCreationDate;

//文件修改时间
@property (nonatomic, copy) NSString *fileModificationDate;

@end
