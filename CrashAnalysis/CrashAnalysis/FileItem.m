//
//  FileItem.m
//  CrashAnalysis
//
//  Created by xiefei5 on 2017/8/19.
//  Copyright © 2017年 xiefei5. All rights reserved.
//

#import "FileItem.h"

@implementation FileItem


+ (instancetype)itemWithFileURL:(NSURL *)url type:(FileType)type completion:(void (^)(NSString *))completion {
    
    FileItem *item = [[FileItem alloc] init];
    item->_type          = type;
    item->_filePath      = url.path;
    item->_fileFullName  = [url.path lastPathComponent];
    item->_fileName      = [item.fileFullName stringByDeletingPathExtension];
    if (completion) {
        completion(item->_fileFullName);
    }
    return item;
}


NSArray<NSString *> *allowFileTypes(FileType type) {
    NSMutableArray *fileTypesArray = [NSMutableArray arrayWithCapacity:2];
    switch (type) {
        case FileType_DSYM:
            [fileTypesArray addObject:@"dSYM"];
            break;
        case FileType_Ips:
            [fileTypesArray addObject:@"ips"];
            [fileTypesArray addObject:@"crash"];
            break;
        case FileType_CrashLog:
            [fileTypesArray addObject:@"crash"];
            break;
        default:
            break;
    }
    return fileTypesArray;
}

@end
