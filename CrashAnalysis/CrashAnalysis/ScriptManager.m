//
//  ScriptManager.m
//  CrashAnalysis
//
//  Created by xiefei5 on 2017/8/19.
//  Copyright © 2017年 xiefei5. All rights reserved.
//

#import "ScriptManager.h"

NSString *const kSymbolicateCrashPathKey = @"kSymbolicateCrashPathKey";

@implementation ScriptManager

NSString *scriptPathInBundle(NSString *scriptName) {
    return filePathInBundle(scriptName, @"sh");
}

NSString *filePathInBundle(NSString *fileName,NSString *suffix) {
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:fileName ofType:suffix];
    return scriptPath;
}

NSString *symbolicatecrashPath() {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *path = [userDefault valueForKey:kSymbolicateCrashPathKey];
    return [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (void)executeScriptPath:(NSString *)path
                       executing:(void (^)(NSString *))executing
                      completion:(void (^)(BOOL))completion {
    [self executeScriptPath:path args:nil executing:executing completion:completion];
}

+ (void)executeScriptPath:(NSString *)path
                            args:(NSArray<NSString *> *)args
                       executing:(void (^)(NSString *))executing
                      completion:(void (^)(BOOL))completion {
    
    NSCParameterAssert(path);
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = path;
    if (args) {
        task.arguments  = args;
    }
    
    NSPipe *outputPipe = [[NSPipe alloc] init];
    task.standardOutput = outputPipe;
    [outputPipe.fileHandleForReading waitForDataInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:outputPipe.fileHandleForReading queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        NSData *data = outputPipe.fileHandleForReading.availableData;
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (output.length > 0) {
            executing([output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
        } else {
            if (![task isRunning] && completion) {
                BOOL success = ([task terminationStatus] == 0);
                completion(success);
            }
            return;
        }
        [outputPipe.fileHandleForReading waitForDataInBackgroundAndNotify];
    }];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [task launch];
    });
    [task waitUntilExit];
}

@end
