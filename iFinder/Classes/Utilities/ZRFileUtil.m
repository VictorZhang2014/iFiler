//
//  ZRUtil.m
//  iFinder
//
//  Created by VictorZhang on 17/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRFileUtil.h"
#include <dirent.h>
#import "ZRUtils.h"




@implementation ZRFileUtil

+ (NSArray<ZRFileModel *> *)getDesignatedDirectoriesWithName:(NSString *)name
{
    NSMutableArray<ZRFileModel *> * result = [[NSMutableArray alloc] init];
    
    if (name.length > 0) {
        if (![ZRUtils isJailBreak]) {
            NSString *path = [NSString stringWithFormat:@"%@/Documents/Inbox/", NSHomeDirectory()];
            NSArray<ZRFileModel *> * resultList = [self getDirectoriesByPathname:path error:nil];
            for (ZRFileModel *model in resultList) {
                if ([model.name containsString:name]) {
                    [result addObject:model];
                }
            }
        } else {
            NSArray<ZRFileModel *> * resultList = [self getDirectoriesByPathname:NSHomeDirectory() error:nil];
            for (ZRFileModel *model in resultList) {
                if ([model.name containsString:name]) {
                    [result addObject:model];
                }
            }
            
            resultList = [self getDirectoriesByPathname:@"/Applications/" error:nil];
            for (ZRFileModel *model in resultList) {
                if ([model.name containsString:name]) {
                    [result addObject:model];
                }
            }
            
            resultList = [self getDirectoriesByPathname:@"/private/var/mobile/Containers/Bundle/Application" recursively:YES error:nil];
            for (ZRFileModel *model in resultList) {
                if ([model.name containsString:name]) {
                    [result addObject:model];
                }
            }
            
            resultList = [self getDirectoriesByPathname:@"/private/var/mobile/Containers/Data/Application" recursively:YES error:nil];
            for (ZRFileModel *model in resultList) {
                if ([model.name containsString:name]) {
                    [result addObject:model];
                }
            }
        }
    }
    
    return result;
}

+ (NSArray<ZRFileModel *> *)getDirectoriesByPathnameInC:(NSString *)pathName {
    NSMutableArray<ZRFileModel *> * resultList = [[NSMutableArray alloc] init];
    
    const char * root = [pathName UTF8String];
    
    DIR *dp = NULL;
    struct dirent *dptr = NULL;
    
    dp = opendir(root);
    
    if(NULL == dp) {
        printf("\n Cannot open Input directory %s \n", root);
    } else {
        
        const char *name = NULL;
        //循环读取
        while(NULL != (dptr = readdir(dp))) {
            name = dptr->d_name;
            
            ZRFileModel *model = [[ZRFileModel alloc] init];
            model.name = [NSString stringWithUTF8String:name];
            NSString *path = [pathName isEqualToString:@"/"] ? @"/" : [NSString stringWithFormat:@"%@/", pathName];
            NSString *tmpPath = [NSString stringWithFormat:@"%@%@", path , [NSString stringWithUTF8String:name]];
            model.path = tmpPath;
            
            //设置文件类型，以及图标
            if (dptr->d_type == DT_DIR) {
                model.fileType = ZRFileTypeFolder;
                model.fileIcon = @"folder";
            } else {
                NSString *iconPath = @"";
                model.fileType = [self recognizeFileType:[NSString stringWithUTF8String:name] iconPath:&iconPath];
                model.fileIcon = iconPath;
            }

            [resultList addObject:model];
        }
        free(dptr);
        closedir(dp);
    }
    return resultList;
}

+ (NSArray<ZRFileModel *> *)getDirectoriesByPathname:(NSString *)pathName recursively:(BOOL)recursively error:(NSError **)error
{
    NSMutableArray<ZRFileModel *> * resultList = [[NSMutableArray alloc] init];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *err = nil;
    NSArray *array = nil;
    if (recursively) {
        array = [manager subpathsAtPath:pathName];
    } else {
        array = [manager contentsOfDirectoryAtPath:pathName error:&err];
    }
    if (err) {
        if (error != NULL) {
            *error = err;
        }
        
        NSLog(@"Failed to get directories! Error Message: %@", err.userInfo);
        return nil;
    } else {
        BOOL isDirectory = NO;
        for (NSString *name in array) {
            ZRFileModel *model = [[ZRFileModel alloc] init];
            model.name = name;
            NSString *path = [pathName isEqualToString:@"/"] ? @"/" : [NSString stringWithFormat:@"%@/", pathName];
            NSString *tmpPath = [NSString stringWithFormat:@"%@%@", path , name];
            model.path = tmpPath;
            if ([manager fileExistsAtPath:tmpPath isDirectory:&isDirectory]) {
                model.isDirectory = isDirectory;
            }
            
            //设置文件类型，以及图标
            if (isDirectory) {
                model.fileType = ZRFileTypeFolder;
                model.fileIcon = @"folder";
            } else {
                NSString *iconPath = @"";
                model.fileType = [self recognizeFileType:name iconPath:&iconPath];
                model.fileIcon = iconPath;
            }
            
            //获取文件属性
            NSDictionary *attributesDict = [manager attributesOfItemAtPath:tmpPath error:&err];
            if (attributesDict) {
                NSString *createDateStr = [NSString stringWithFormat:@"%@", attributesDict[NSFileCreationDate]];
                NSString *modifyDateStr = [NSString stringWithFormat:@"%@", attributesDict[NSFileModificationDate]];
                model.fileCreationDate = createDateStr;
                model.fileModificationDate = modifyDateStr;
                model.attributesOfFile = attributesDict;
            }
            
            [resultList addObject:model];
        }
    }
    return resultList;
}

+ (NSArray<ZRFileModel *> *)getDirectoriesByPathname:(NSString *)pathName error:(NSError **)error
{
    return [self getDirectoriesByPathname:pathName recursively:NO error:error];
}

+ (ZRFileType)recognizeFileType:(NSString *)name iconPath:(NSString **)iconPath
{
    name = [name lowercaseString];
    
    if ([name containsString:@".doc"] || [name containsString:@".docx"]) {
        *iconPath = @"ic_file_doc_blue";
        return ZRFileTypeDoc;
    }
    if ([name containsString:@".xls"] || [name containsString:@".xlsx"]) {
        *iconPath = @"ic_file_xls_blue";
        return ZRFileTypeXls;
    }
    if ([name containsString:@".ppt"]) {
        *iconPath = @"ic_file_ppt_blue";
        return ZRFileTypePPT;
    }
    if ([name containsString:@".pdf"]) {
        *iconPath = @"ic_file_pdf_blue";
        return ZRFileTypePDF;
    }
    if ([name containsString:@".txt"] || [name containsString:@".plist"] || [name containsString:@".xml"]) {
        *iconPath = @"ic_file_txt_blue";
        return ZRFileTypeTxt;
    }
    if ([name containsString:@".htm"] || [name containsString:@".html"]) {
        *iconPath = @"ic_file_htm_blue";
        return ZRFileTypeHtml;
    }
    if ([name containsString:@".js"]) {
        *iconPath = @"ic_file_js_blue";
        return ZRFileTypeJS;
    }
    if ([name containsString:@".jpg"] || [name containsString:@".jpeg"] || [name containsString:@".png"] || [name containsString:@".gif"]) {
        *iconPath = @"ic_file_jpg";
        return ZRFileTypeJPG;
    }
    if ([name containsString:@".zip"] || [name containsString:@".rar"] || [name containsString:@".7zip"]) {
        *iconPath = @"ic_file_zip_blue";
        return ZRFileTypeZIP;
    }
    if ([name containsString:@".video"] || [name containsString:@".mp4"] || [name containsString:@".avi"] || [name containsString:@".swf"] || [name containsString:@".mov"] || [name containsString:@".wmv"] || [name containsString:@".mpeg"]) {
        *iconPath = @"ic_file_video_blue";
        return ZRFileTypeVideo;
    }
    if ([name containsString:@".wav"] || [name containsString:@".mp3"] || [name containsString:@".wma"] || [name containsString:@".wav"] || [name containsString:@".ogg"] || [name containsString:@".acc"]) {
        *iconPath = @"ic_file_music_blue";
        return ZRFileTypeMusic;
    }
    
    if ([name containsString:@".bundle"] || [name containsString:@".framework"]) {
        *iconPath = @"folder";
        return ZRFileTypeFolder;
    }
    
    *iconPath = @"ic_file";
    return ZRFileTypeFile;
}

+ (ZRFileType)isDocument:(NSString *)name
{
    name = [name lowercaseString];
    if ([name containsString:@".doc"] || [name containsString:@".docx"]) {
        return ZRFileTypeDoc;
    }
    if ([name containsString:@".xls"] || [name containsString:@".xlsx"]) {
        return ZRFileTypeXls;
    }
    if ([name containsString:@".ppt"]) {
        return ZRFileTypePPT;
    }
    if ([name containsString:@".pdf"]) {
        return ZRFileTypePDF;
    }
    return ZRFileTypeFile;
}


@end
