//
//  ScriptManager.h
//  CrashAnalysis
//
//  Created by xiefei5 on 2017/8/19.
//  Copyright © 2017年 xiefei5. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kSymbolicateCrashPathKey;

@interface ScriptManager : NSObject


/**
 获取脚本路径

 @param scriptName 脚本名称
 @return 返回脚本路径
 */
extern NSString *scriptPathInBundle(NSString *scriptName);


/**
 获取文件路径

 @param fileName 文件名
 @param suffix 文件后缀名
 @return 返回文件绝对路径
 */
extern NSString *filePathInBundle(NSString *fileName,NSString *suffix);


extern NSString *symbolicatecrashPath();
/**
 执行shell脚本

 @param path 脚本路径
 @param executing 执行回调过程
 @param completion 完成回调
 */
+ (void)executeScriptPath:(NSString *)path
                       executing:(void (^)(NSString *))executing
                      completion:(void (^)(BOOL))completion;

/**
 执行shell脚本

 @param path 脚本路径
 @param args 参数
 @param executing 执行回调过程
 @param completion 完成回调
 */
+ (void)executeScriptPath:(NSString *)path
                            args:(NSArray<NSString *> *)args
                       executing:(void (^)(NSString *))executing
                      completion:(void (^)(BOOL))completion;
    

@end
