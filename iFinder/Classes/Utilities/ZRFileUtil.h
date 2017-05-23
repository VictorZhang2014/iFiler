//
//  ZRUtil.h
//  iFinder
//
//  Created by VictorZhang on 17/04/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZRFileModel.h"

@interface ZRFileUtil : NSObject

+ (ZRFileType)isDocument:(NSString *)name;

+ (NSArray<ZRFileModel *> *)getDesignatedDirectoriesWithName:(NSString *)name;

+ (NSArray<ZRFileModel *> *)getDirectoriesByPathnameInC:(NSString *)pathName;

+ (NSArray<ZRFileModel *> *)getDirectoriesByPathname:(NSString *)pathName error:(NSError **)error;

@end
