//
//  ViewController.m
//  TranslateMan
//
//  Created by wangshiwen on 2018/10/24.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "ViewController.h"
#import <SafariServices/SafariServices.h>
#import "GlobalFunction.h"
#import "SWButton.h"
#import "LangUtil.h"
#import "FileMd5Info.h"

@interface ViewController()

@property (nonatomic,weak) IBOutlet NSButton *setting1Btn;
@property (nonatomic,weak) IBOutlet NSButton *setting2Btn;
@property (nonatomic,weak) IBOutlet NSButton *setting3Btn;
@property (nonatomic,weak) IBOutlet NSButton *stateImageView;
@property (nonatomic,weak) IBOutlet NSTextField *stateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //拷贝配置文件
    [self copySettingFile];
    
    //设置选项
    BOOL doubleclick = [[[LangUtil shareInstance] getSettingForKey:@"doubleclick"] boolValue];
    BOOL selecttext = [[[LangUtil shareInstance] getSettingForKey:@"selecttext"] boolValue];
    BOOL autoplay = [[[LangUtil shareInstance] getSettingForKey:@"autoplay"] boolValue];
    
    [self.setting1Btn setState:doubleclick];
    [self.setting2Btn setState:selecttext];
    [self.setting3Btn setState:autoplay];
    
    //注册窗口唤醒服务
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:NSApplicationDidBecomeActiveNotification object:nil];
    
}

-(void)applicationDidBecomeActive:(NSNotification *)notification{
    //NSLog(@"重新进来后响应，该区域编写重新进入页面的逻辑");
    //刷新状态
    [self refreshExtensionState];
}

#pragma mark - Member

- (void)refreshExtensionState
{
    //获取插件状态
    [SFSafariExtensionManager getStateOfSafariExtensionWithIdentifier:@"com.instrument.TranslateMac.TranslateManExtension" completionHandler:^(SFSafariExtensionState * _Nullable state, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.stateImageView setImage:[NSImage imageNamed:state.isEnabled?NSImageNameStatusAvailable:NSImageNameStatusUnavailable]];
            if (state.isEnabled) {
                self.stateLabel.stringValue = NSLocalizedString(@"ExtensionStateAvailable", nil);
            }else{
                self.stateLabel.stringValue = NSLocalizedString(@"ExtensionStateUnavailable", nil);
            }
        });
    }];
}

- (NSString *)getSupportDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appGroupName = @"F4KDKTF5YA.com.instrument.TranslateMac"; /* For example */
    
    NSURL *groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
    
    NSError* theError = nil;
    
    if (![fm fileExistsAtPath:groupContainerURL.path]) {
        if (![fm createDirectoryAtURL: groupContainerURL withIntermediateDirectories:YES attributes:nil error:&theError]) {
            // Handle the error.
        }
    }
    
    return groupContainerURL.path;
}

- (BOOL)copySettingFile
{
    NSString *rootpath = [self getSupportDirectory];
    //[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:rootpath]];
    
    NSString *settingPath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
    NSString *googlePath = [[NSBundle mainBundle] pathForResource:@"GoogleLang" ofType:@"plist"];
    
    NSString *settingToPath = [rootpath stringByAppendingPathComponent:@"Setting.plist"];
    NSString *googleToPath = [rootpath stringByAppendingPathComponent:@"GoogleLang.plist"];
    
    //NSString *settingPathMd5  = [FileMd5Info getFileMD5WithPath:settingPath];
    //NSString *settingToPathMd5  = [FileMd5Info getFileMD5WithPath:settingToPath];
    
    NSString *googlePathMd5  = [FileMd5Info getFileMD5WithPath:googlePath] ? :@"";
    NSString *googleToPathMd5  = [FileMd5Info getFileMD5WithPath:googleToPath] ? : @"";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:settingToPath]) {
        [GlobalFunction copyFileFromPath:settingPath toPath:settingToPath];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:googleToPath] ) {
        [GlobalFunction copyFileFromPath:googlePath toPath:googleToPath];
    }else if(![googlePathMd5 isEqualToString:googleToPathMd5]){
        BOOL issus = [[NSFileManager defaultManager] removeItemAtPath:googleToPath error:nil];
        if (issus) {
            [GlobalFunction copyFileFromPath:googlePath toPath:googleToPath];
        }
    }
    
    return NO;
}

#pragma mark - Action

- (IBAction)settingClick:(id)sender{

    [SFSafariApplication showPreferencesForExtensionWithIdentifier:@"com.instrument.TranslateMac.TranslateManExtension" completionHandler:^(NSError * _Nullable error) {
        NSLog(@"%@",error.description);
    }];
}

- (IBAction)setSettingOneBtnClick:(id)sender{
    BOOL isON = self.setting1Btn.state;
    [[LangUtil shareInstance] setSettingForKey:@"doubleclick" andValue:@(isON)];
}

- (IBAction)setSettingTwoBtnClick:(id)sender{
    BOOL isON = self.setting2Btn.state;
    [[LangUtil shareInstance] setSettingForKey:@"selecttext" andValue:@(isON)];
}

- (IBAction)setSettingThreeBtnClick:(id)sender{
    BOOL isON = self.setting3Btn.state;
    [[LangUtil shareInstance] setSettingForKey:@"autoplay" andValue:@(isON)];
}

- (IBAction)helpBtnClick:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://mushroomdev.github.io/TranslateMan/"]];
    
}

@end
