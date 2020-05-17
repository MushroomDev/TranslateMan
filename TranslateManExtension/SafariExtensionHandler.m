//
//  SafariExtensionHandler.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/24.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "SafariExtensionHandler.h"
#import "SafariExtensionViewController.h"
#import "GoogleTransService.h"
#import "LangUtil.h"

@interface SafariExtensionHandler ()

@property (nonatomic,strong)GoogleTransService *transService;

@end

@implementation SafariExtensionHandler

- (void)messageReceivedWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {
    // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message")
    [page getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties *properties) {
        NSLog(@"The extension received a message (%@) from a script injected into (%@) with userInfo (%@)", messageName, properties.url, userInfo);
        if ([messageName isEqualToString:@"askForHotKey"]) {
            [page dispatchMessageToScriptWithName:@"answerForHotKey" userInfo:@{@"hotKey":@"Shift"}];
        }else if([messageName isEqualToString:@"askForTranslate"]){
            NSString *word = [userInfo objectForKey:@"text"];
            NSString *type = [userInfo objectForKey:@"type"];
            NSLog(@"翻译文字的长度为:%d",word.length);
            if (word.length>10000) {
                return;
            }
            if ([type isEqualToString:@"1"]) {//双击
                BOOL doubleclick = [[[LangUtil shareInstance] getSettingForKey:@"doubleclick"] boolValue];
                if (!doubleclick) {
                    return;
                }
            }else{//划词
                BOOL selecttext = [[[LangUtil shareInstance] getSettingForKey:@"selecttext"] boolValue];
                if (!selecttext) {
                    return;
                }
            }
            //获取网页翻译语言
            NSString *webTransLangKey = [[LangUtil shareInstance] getSettingForKey:@"webTransLang"];
            
            [self.transService translateWorld:word from:@"auto" to:webTransLangKey source:1   result:^(TransObject *result){
                [page dispatchMessageToScriptWithName:@"answerForTranslate" userInfo:[result coverToDic]];
            }];
        }
        
    }];
}

- (void)messageReceivedFromContainingAppWithName:(NSString *)messageName userInfo:(nullable NSDictionary<NSString *, id> *)userInfo
{
    NSLog(@"============%@ %@",messageName,userInfo);
}

- (void)contextMenuItemSelectedWithCommand:(NSString *)command inPage:(SFSafariPage *)page userInfo:(nullable NSDictionary<NSString *, id> *)userInfo
{
    NSLog(@"command %@",command);
    // 要翻译句子
    if ([command isEqualToString:@"Translate"]) {
            
    }
}

- (void)toolbarItemClickedInWindow:(SFSafariWindow *)window {
    // This method will be called when your toolbar item is clicked.
    NSLog(@"The extension's toolbar item was clicked");
    
    [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
        [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
            // Invoke handleMessage() in script.js.  UserInfo is ignored, just for example purposes.
            [activePage dispatchMessageToScriptWithName:@"message" userInfo:@{ @"myKey": @"myValue" }];
        }];
    }];
}

- (void)validateToolbarItemInWindow:(SFSafariWindow *)window validationHandler:(void (^)(BOOL enabled, NSString *badgeText))validationHandler {
    // This method will be called whenever some state changes in the passed in window. You should use this as a chance to enable or disable your toolbar item and set badge text.
    validationHandler(YES, nil);
}

- (SFSafariExtensionViewController *)popoverViewController {
    return [SafariExtensionViewController sharedController];
}

- (void)finishTranslate:(TransObject *)transObject
{
    
}

- (void)finishTranslateTTS:(NSData *)data
{
    
}

#pragma mark - Getter

/** 获取Google翻译对象 */
- (GoogleTransService *)transService
{
    if (_transService == nil) {
        _transService = [[GoogleTransService alloc] init];
    }
    return _transService;
}

@end
