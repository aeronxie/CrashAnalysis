//
//  FileItem.h
//  CrashAnalysis
//
//  Created by xiefei5 on 2017/8/19.
//  Copyright © 2017年 xiefei5. All rights reserved.
//

#import <Foundation/Foundation.h>


/*! 文件类型*/
typedef NS_OPTIONS(NSUInteger,FileType){
    FileType_DSYM = 0,
    FileType_Ips,
    FileType_CrashLog,
    FileType_All
};

extern NSArray<NSString *> *allowFileTypes(FileType type);

@interface FileItem : NSObject
// 文件类型
@property (nonatomic,readonly) FileType type;
// 文件绝对路径
@property (nonatomic,readonly) NSString *filePath;
// 文件全名（路径+名称+后缀）
@property (nonatomic,readonly) NSString *fileFullName;
// 文件名
@property (nonatomic,readonly) NSString *fileName;



/*!
 *  @param url        文件URL
 *  @param type       文件类型
 *  @param completion 返回item
 */
+ (instancetype)itemWithFileURL:(NSURL *)url
                           type:(FileType)type
                     completion:(void (^)(NSString *displayString))completion;


@end
