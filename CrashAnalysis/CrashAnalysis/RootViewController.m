//
//  ViewController.m
//  CrashAnalysis
//
//  Created by xiefei5 on 2017/8/19.
//  Copyright © 2017年 xiefei5. All rights reserved.
//

#import "RootViewController.h"
#import "ScriptManager.h"
#import "FileItem.h"

@interface RootViewController ()

@property (nonatomic,strong) FileItem *ipsItem;
@property (nonatomic,strong) FileItem *dsymItem;
@property (nonatomic,strong) FileItem *crashItem;
@property (weak) IBOutlet NSButton *choiceDsymButton;
@property (weak) IBOutlet NSButton *choiceIpsButton;
@property (weak) IBOutlet NSButton *FileOutputButton;
@property (weak) IBOutlet NSTextField *dsymTextfield;
@property (weak) IBOutlet NSTextField *ipsTextfield;
@property (weak) IBOutlet NSTextField *crashTextfield;
@property (weak) IBOutlet NSButton *startAnalysis;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear {
    [self fetchSymbolicatePathFromCache];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)fetchSymbolicatePathFromCache {
    NSString *scriptPath = scriptPathInBundle(@"FindSymbolicatecrash");
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *symbolicatePath = [userDefault valueForKey:kSymbolicateCrashPathKey];
    if (symbolicatePath && symbolicatePath > 0) return;
    
    [ScriptManager executeScriptPath:scriptPath executing:^(NSString *output) {
        [userDefault setValue:output forKey:kSymbolicateCrashPathKey];
        [userDefault synchronize];
    } completion:nil];
}

- (void)handlerWithFileType:(FileType)type {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.showsHiddenFiles     = NO;
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles       = YES;
    openPanel.allowedFileTypes = allowFileTypes(type);
    
    NSWindow *mainWindow = [NSApplication sharedApplication].mainWindow;
    
    [openPanel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self initItemWithURL:openPanel.URL type:type];
        }
    }];
}

- (void)initItemWithURL:(NSURL *)url type:(FileType)type {

    switch (type) {
        case FileType_DSYM:
           _dsymItem = [FileItem itemWithFileURL:url type:FileType_DSYM completion:nil];
            self.dsymTextfield.stringValue = _dsymItem.fileFullName;
            break;
        case FileType_Ips:
            _ipsItem = [FileItem itemWithFileURL:url type:FileType_Ips completion:nil];
            self.ipsTextfield.stringValue = _ipsItem.fileFullName;
            break;
        case FileType_CrashLog:
            _crashItem = [FileItem itemWithFileURL:url type:FileType_CrashLog completion:nil];
            self.crashTextfield.stringValue = _crashItem.fileFullName;
            break;
        default:
            break;
    }
}

- (IBAction)choiceDsym:(id)sender {
    [self handlerWithFileType:FileType_DSYM];
}

- (IBAction)choiceIps:(id)sender {
    [self handlerWithFileType:FileType_Ips];
}

- (IBAction)outputCrashFile:(id)sender {
    [self handlerWithFileType:FileType_CrashLog];
}

- (IBAction)AnalysisCrash:(id)sender {
    
    NSString *scriptPath = scriptPathInBundle(@"AnalysisScript");
    NSString *arg1 = symbolicatecrashPath();
    NSString *arg2 = _ipsItem.filePath;
    NSString *arg3 = _dsymItem.filePath;
    NSString *arg4 = [_crashItem.filePath stringByAppendingString:@".crash"];
    NSArray<NSString *> *args = @[arg1,arg2,arg3,arg4];

    [ScriptManager executeScriptPath:scriptPath args:args executing:^(NSString *output) {
        
    } completion:^(BOOL success) {
        
    }];

}

@end
