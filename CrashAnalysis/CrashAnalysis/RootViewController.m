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

@interface RootViewController () {
    NSString *_deskTopPath;
}

@property (nonatomic,strong) FileItem *ipsItem;
@property (nonatomic,strong) FileItem *dsymItem;
@property (nonatomic,strong) FileItem *crashItem;

@property (weak) IBOutlet NSProgressIndicator *indicator;
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
    self.indicator.hidden = YES;
}

- (void)viewDidAppear {
    [self fetchSymbolicatePathFromCache];
    [self fetchDeskTopPath];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (void)fetchDeskTopPath {
    [ScriptManager executeScriptPath:scriptPathInBundle(@"GetdeskTop") executing:^(NSString *output) {
        _deskTopPath = output;
    } completion:nil];
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

- (void)startAnimation {
    self.indicator.hidden = NO;
//    self.FileOutputButton.enabled = NO;
    [self.indicator startAnimation:self];
}

- (void)stopAnimation {
    self.indicator.hidden = YES;
//    self.FileOutputButton.enabled = YES;
    [self.indicator startAnimation:self];
}

- (BOOL)checkValid {
    if (self.dsymTextfield.stringValue.length <= 0) {
        [self showAlertView:@"请选择DSYM文件" message:@"选择文件失败" excuteblock:nil];
        return NO;
    }
    if (self.ipsTextfield.stringValue.length <= 0) {
        [self showAlertView:@"请选择ips文件" message:@"选择文件失败" excuteblock:nil];
        return NO;
    }
    return YES;
}

- (void)showAlertView:(NSString *)infoTxt message:(NSString *)msg excuteblock:(dispatch_block_t)block {
    NSAlert *alert = [[NSAlert alloc] init];
    if (block) {
        [alert addButtonWithTitle:@"直接打开"];
    }
    [alert addButtonWithTitle:@"知道了~"];
    [alert setMessageText:msg];
    [alert setInformativeText:infoTxt];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger returnCode) {
        if (returnCode == 1000) {
            if (block) {
                block();
            }
        }
    }];
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

- (IBAction)AnalysisCrash:(NSButton *)sender {
    if (![self checkValid]) return;
    [self startAnimation];
    sender.enabled = NO;
    NSString *scriptPath = scriptPathInBundle(@"AnalysisScript");
    NSString *arg1 = symbolicatecrashPath();
    NSString *arg2 = _ipsItem.filePath;
    NSString *arg3 = _dsymItem.filePath;
    
    NSString *outputFullPath = [_ipsItem.fileFullName stringByDeletingPathExtension];
    outputFullPath = [[_deskTopPath stringByAppendingPathComponent:outputFullPath] stringByAppendingFormat:@".crash"];
    NSString *arg4 = _crashItem.filePath.length > 0 ?_crashItem.filePath : outputFullPath;
    
    NSArray<NSString *> *args = @[arg1,arg2,arg3,arg4];

    __weak typeof(self) weakSelf = self;
    [ScriptManager executeScriptPath:scriptPath args:args executing:^(NSString *output) {
        
    } completion:^(BOOL success) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (success) {
            [strongSelf stopAnimation];
            sender.enabled = YES;
            [strongSelf showAlertView:[NSString stringWithFormat:@"解析出的文件路径为:%@",arg4] message:@"解析已完成"excuteblock:^{
                [ScriptManager executeScriptPath:scriptPathInBundle(@"OpenCrashLog") args:@[arg4] executing:nil completion:nil];
            }];
        }
    }];

}

@end
