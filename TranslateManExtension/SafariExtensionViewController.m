//
//  SafariExtensionViewController.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/24.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "SafariExtensionViewController.h"
#import <Cocoa/Cocoa.h>
#import "GoogleTransService.h"
#import "SWTextField.h"
#import "LangUtil.h"
#import "LangSelectVC.h"
#import "MacroDefine.h"
#import "SWButton.h"
#import "SWTextView.h"
#import "SWSetting.h"
#import "NSView+Category.h"

@interface SafariExtensionViewController ()

@property (nonatomic) IBOutlet SWTextField *textView;

@property (nonatomic,weak) IBOutlet SWButton *fromLangBtn;
@property (nonatomic,weak) IBOutlet SWButton *toLangBtn;

@property (nonatomic,weak) IBOutlet NSView *resultView;

@property (nonatomic,weak) IBOutlet NSTextField *sourceTextLabel;

@property (nonatomic,weak) IBOutlet NSView *transPageView;

@property (nonatomic,weak) IBOutlet NSTextField *pinyinLabel;

@property (nonatomic,weak) IBOutlet SWButton *ttsBtn;

@property (nonatomic,weak) IBOutlet NSTextField *allresultLabel;

@property (nonatomic,weak) IBOutlet NSTextField *wordtypeLabel;
@property (nonatomic,weak) IBOutlet NSTextField *wordresultLabel;

@property (nonatomic,weak) IBOutlet NSTextField *arrowLabel;

@property (nonatomic,weak) IBOutlet SWButton *settingBtn;

@property (nonatomic,strong) GoogleTransService *service;

@property (nonatomic,strong) NSString *fromkey;
@property (nonatomic,strong) NSString *tokey;

@property (nonatomic,strong) TransObject *currentObject;

@property (nonatomic,strong) LangSelectVC *langVC;

@property (nonatomic,strong) SWSetting *settingVC;

/** 是否是简体中文 */
@property (nonatomic,assign) BOOL isZHHans;

@end

@implementation SafariExtensionViewController

+ (SafariExtensionViewController *)sharedController {
    static SafariExtensionViewController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[SafariExtensionViewController alloc] init];
        sharedController.preferredContentSize = NSMakeSize(330, 155);
    });
    return sharedController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isZHHans = [[LangUtil shareInstance] isCurrentLanguageZH];
    //NSLog(@"当前系统语言:%@",currentLanguage);
    
    [self configUI];
}

#pragma mark - Member

- (void)configUI
{
    self.resultView.wantsLayer = YES;
    self.resultView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.resultView.layer.cornerRadius = 5;
    
    self.sourceTextLabel.drawsBackground = YES;
    self.sourceTextLabel.backgroundColor = [NSColor whiteColor];
    [[self.sourceTextLabel cell] setLineBreakMode:NSLineBreakByCharWrapping];
    [[self.sourceTextLabel cell] setTruncatesLastVisibleLine:YES];
    
    self.pinyinLabel.drawsBackground = YES;
    self.pinyinLabel.backgroundColor = [NSColor whiteColor];
    [[self.pinyinLabel cell] setLineBreakMode:NSLineBreakByCharWrapping];
    [[self.pinyinLabel cell] setTruncatesLastVisibleLine:YES];
    
    self.allresultLabel.drawsBackground = YES;
    self.allresultLabel.backgroundColor = [NSColor whiteColor];
    
    self.wordtypeLabel.drawsBackground = YES;
    self.wordtypeLabel.backgroundColor = [NSColor whiteColor];
    
    self.wordresultLabel.drawsBackground = YES;
    self.wordresultLabel.backgroundColor = [NSColor whiteColor];
    
    self.textView.swdelegate = (id)self;
    self.textView.wantsLayer = YES;
    self.textView.layer.borderColor = [NSColor lightGrayColor].CGColor;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.cornerRadius = 5;
    
    self.fromLangBtn.wantsLayer = YES;
    //self.fromLangBtn.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.fromLangBtn.layer.shadowOpacity = 0.5;
    self.fromLangBtn.layer.shadowRadius = 0.5;
    self.fromLangBtn.layer.shadowColor = [NSColor whiteColor].CGColor;
    self.fromLangBtn.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    self.toLangBtn.wantsLayer = YES;
    //self.fromLangBtn.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.toLangBtn.layer.shadowOpacity = 0.5;
    self.toLangBtn.layer.shadowRadius = 0.5;
    self.toLangBtn.layer.shadowColor = [NSColor whiteColor].CGColor;
    self.toLangBtn.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    self.arrowLabel.wantsLayer = YES;
    //self.fromLangBtn.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.arrowLabel.layer.shadowOpacity = 0.5;
    self.arrowLabel.layer.shadowRadius = 0.5;
    self.arrowLabel.layer.shadowColor = [NSColor whiteColor].CGColor;
    self.arrowLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    
    self.settingBtn.isShowAnimation = YES;
    
    [self setSupportLang];
    
    //加载选择语言面板
    [self.view addSubview:self.langVC];
    //加载设置界面面板
    [self.view addSubview:self.settingVC.view];
    self.settingVC.view.hidden = YES;
    WS(weakSelf);
    [self.settingVC setFinish:^{
        weakSelf.settingVC.view.hidden = YES;
        weakSelf.transPageView.hidden = NO;
    }];
    
    self.transPageView.wantsLayer = YES;
    self.transPageView.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    
}

- (void)setSupportLang
{
    //获取原语言
    NSString *fromlang = [[LangUtil shareInstance] getSettingForKey:@"fromlang"];
    if (fromlang) {
        self.fromkey = fromlang;
        NSString *title = [[[LangUtil shareInstance] getLangForKey:fromlang] objectForKey:self.isZHHans ? @"title" : @"title_en"];
        [self.fromLangBtn setTitle:title];
    }else{
        self.fromkey = @"auto";
        [self.fromLangBtn setTitle:@"自动检测"];
    }
    //获取翻译语言
    NSString *tolang = [[LangUtil shareInstance] getSettingForKey:@"tolang"];
    if (tolang) {
        self.tokey = tolang;
        [self.toLangBtn setTitle:[[[LangUtil shareInstance] getLangForKey:tolang] objectForKey:self.isZHHans ? @"title" : @"title_en"]];
    }else{
        self.tokey = @"en";
        [self.toLangBtn setTitle:@"英语"];
    }
    
}

- (void)playSound:(NSData *)data
{
    NSSound *sound = [[NSSound alloc] initWithData:data];
    [sound play];
}

#pragma mark - GoogleTransServiceDelegate

- (void)finishTranslate:(TransObject *)transObject
{
    self.currentObject = transObject;
    
    //修改尺寸
    self.preferredContentSize = NSMakeSize(330, 300);
    
    self.wordtypeLabel.hidden = YES;
    self.wordresultLabel.hidden = YES;
    self.allresultLabel.hidden = YES;
    
    if (transObject.sourcetext) {
        self.sourceTextLabel.stringValue = transObject.sourcetext;
    }
    if (transObject.pinyin) {
        self.pinyinLabel.stringValue = transObject.pinyin;
    }
    if (transObject.wordtype) {
        self.wordtypeLabel.hidden = NO;
        self.wordtypeLabel.stringValue = transObject.wordtype;
    }else{
        self.allresultLabel.hidden = NO;
        self.allresultLabel.stringValue = transObject.result;
    }
    if (transObject.synonymArray && transObject.synonymArray.count>0) {
        self.wordresultLabel.hidden = NO;
        NSString *synony = @"";
        for (int i=0;i<transObject.synonymArray.count; i++) {
            NSString *word = transObject.synonymArray[i];
            synony = [synony stringByAppendingString:word];
            if (i!=transObject.synonymArray.count-1) {
                synony = [synony stringByAppendingString:@"; "];
            }
        }
        self.wordresultLabel.stringValue = synony;
    }
    self.allresultLabel.stringValue = transObject.result;
    
    //获取发音
    //if ([transObject.type isEqualToString:@"Word"]) {
        WS(weakSelf);
        [self.service wordTTS:transObject.result lang:transObject.tolang result:^(NSData *data){
            [weakSelf finishTranslateTTS:data];
        }];
    //}
    
}

- (void)finishTranslateTTS:(NSData *)data
{
    if (self.currentObject) {
        self.currentObject.voiceData = data;
        BOOL autoplay = [[[LangUtil shareInstance] getSettingForKey:@"autoplay"] boolValue];
        if (autoplay) {
            [self playSound:data];
        }
    }
}
#pragma mark - SWTextFieldDelegate

- (void)keyDownTranslate
{
    //NSString *tempstr = [self.textView.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (self.textView.stringValue.length>0) {
        WEAK(self);
        [self.service translateWorld:self.textView.stringValue from:self.fromkey to:self.tokey source:0 result:^(TransObject *result){
            //结果
            [self finishTranslate:result];
        }];
    }else{
        self.allresultLabel.stringValue = @"";
    }
}

#pragma mark - Action

- (IBAction)setFromLanguageBtn:(id)sender
{
    //修改尺寸
    self.transPageView.hidden = YES;
    self.langVC.hidden = NO;
    //self.preferredContentSize = NSMakeSize(330, 300);
    [self.langVC show];
    self.langVC.frame = self.view.bounds;
    
    WS(weakSelf);
    [self.langVC setFinishchange:^(NSDictionary *langdic,LangSelectVC *selectVC) {
        if (langdic) {
            NSString *langname = [langdic objectForKey:weakSelf.isZHHans ? @"title" : @"title_en"];
            NSString *key = [langdic objectForKey:@"key"];
            weakSelf.fromkey = key;
            [weakSelf.fromLangBtn setTitle:langname];
            //刷新翻译
            [weakSelf keyDownTranslate];
            [[LangUtil shareInstance] useLang:key];
            [[LangUtil shareInstance] setLang:key type:0];
        }
        weakSelf.transPageView.hidden = NO;
    }];
}

- (IBAction)setToLanguageBtn:(id)sender
{
    //修改尺寸
    self.transPageView.hidden = YES;
    self.langVC.hidden = NO;
    //self.preferredContentSize = NSMakeSize(330, 300);
    [self.langVC show];
    self.langVC.frame = self.view.bounds;
    
    WS(weakSelf);
    [self.langVC setFinishchange:^(NSDictionary *langdic,LangSelectVC *selectVC) {
        if (langdic) {
            NSString *langname = [langdic objectForKey:self.isZHHans ? @"title" : @"title_en"];
            NSString *key = [langdic objectForKey:@"key"];
            if (![key isEqualToString:@"auto"]) {
                weakSelf.tokey = key;
                [weakSelf.toLangBtn setTitle:langname];
                //刷新翻译
                [weakSelf keyDownTranslate];
                [[LangUtil shareInstance] useLang:key];
                [[LangUtil shareInstance] setLang:key type:1];
            }
        }
        weakSelf.transPageView.hidden = NO;
    }];
}

- (IBAction)setPlayVoiceBtn:(id)sender
{
    if (self.currentObject && self.currentObject.voiceData) {
        [self playSound:self.currentObject.voiceData];
    }
}

- (IBAction)setSettingBtn:(id)sender
{
    self.allresultLabel.stringValue = @"";
    
    self.settingVC.view.hidden = NO;
    self.transPageView.hidden = YES;
    //self.settingVC.view.frame = self.transPageView.bounds;
    //self.settingVC.view.origin = CGPointMake(0, -30);
}

#pragma mark - Getter

- (GoogleTransService *)service
{
    if (_service == nil) {
        _service = [[GoogleTransService alloc] init];
    }
    return _service;
}

- (LangSelectVC *)langVC
{
    if (_langVC == nil) {
        _langVC = [[LangSelectVC alloc] initWithFrame:self.view.bounds];
        _langVC.hidden = YES;
    }
    return _langVC;
}

- (SWSetting *)settingVC
{
    if (_settingVC == nil) {
        _settingVC = [[SWSetting alloc] initWithNibName:@"SWSetting" bundle:nil];
    }
    return _settingVC;
}

#pragma mark - System

- (void)keyDown:(NSEvent *)event {
    [super keyDown:event];
    
    if ([event keyCode] == 125 ||  [event keyCode] == 126) {
        [super keyDown:event];
    }
    NSLog(@"按键了 %d",[event keyCode]);
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    //NSLog(@"view x:%f y:%f width:%f height:%f",self.view.x,self.view.y,self.view.width,self.view.height);
    self.settingVC.view.origin = CGPointMake(0, 0);
    
}

@end
