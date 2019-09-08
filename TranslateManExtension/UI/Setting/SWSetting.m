//
//  SWSetting.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/30.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "SWSetting.h"

#pragma mark - UI
#import "SWTextField.h"
#import "SWButton.h"
#import "LangSelectVC.h"

#pragma mark - tools
#import "MacroDefine.h"
#import "LangUtil.h"
#import "NSView+Category.h"

@interface SWSetting ()

@property (nonatomic,weak) IBOutlet SWButton *backBtn;

@property (nonatomic,weak) IBOutlet NSView *bgview;

@property (nonatomic,weak) IBOutlet NSView *cellview;

@property (nonatomic,weak) IBOutlet NSView *line1view;
@property (nonatomic,weak) IBOutlet NSView *line2view;
@property (nonatomic,weak) IBOutlet NSView *line3view;
@property (nonatomic,weak) IBOutlet NSView *line4view;

@property (nonatomic,weak) IBOutlet SWButton *setting1Btn;
@property (nonatomic,weak) IBOutlet SWButton *setting2Btn;
@property (nonatomic,weak) IBOutlet SWButton *setting3Btn;

/** 切换语言按钮 **/
@property (nonatomic,weak) IBOutlet SWTextField *webTransLangLabel;

/** 切换语言按钮 **/
@property (nonatomic,weak) IBOutlet SWButton *switchLangBtn;

@end

@implementation SWSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgview.wantsLayer = YES;
    self.bgview.layer.backgroundColor = ALLRGBColor(233, 248, 247).CGColor;
    self.bgview.layer.cornerRadius = 5;
    
    self.cellview.wantsLayer = YES;
    self.cellview.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.backBtn.wantsLayer = YES;
    self.backBtn.layer.shadowOpacity = 0.5;
    self.backBtn.layer.shadowRadius = 0.5;
    self.backBtn.layer.shadowColor = [NSColor whiteColor].CGColor;
    self.backBtn.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    self.line1view.wantsLayer = YES;
    self.line1view.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;

    self.line2view.wantsLayer = YES;
    self.line2view.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    
    self.line3view.wantsLayer = YES;
    self.line3view.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    
    self.line4view.wantsLayer = YES;
    self.line4view.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    
    BOOL doubleclick = [[[LangUtil shareInstance] getSettingForKey:@"doubleclick"] boolValue];
    BOOL selecttext = [[[LangUtil shareInstance] getSettingForKey:@"selecttext"] boolValue];
    BOOL autoplay = [[[LangUtil shareInstance] getSettingForKey:@"autoplay"] boolValue];
    NSString *webTransLangKey = [[LangUtil shareInstance] getSettingForKey:@"webTransLang"];
    
    BOOL isZHHans = [[LangUtil shareInstance] isCurrentLanguageZH];
    NSString *webTransLang = [[[LangUtil shareInstance] getLangForKey:webTransLangKey] objectForKey:isZHHans ? @"title" : @"title_en"];
    
    [self.setting1Btn setState:doubleclick];
    [self.setting2Btn setState:selecttext];
    [self.setting3Btn setState:autoplay];
    self.webTransLangLabel.stringValue = webTransLang;
    
    //定义点击文字的事件
    WS(weakSelf);
    [self.webTransLangLabel setClickEvent:^{
        [weakSelf setSwitchBtnClick:nil];
    }];
}

#pragma mark - Action

- (IBAction)setBackBtnClick:(id)sender{
    if (self.finish) {
        self.finish();
    }
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

- (IBAction)setSwitchBtnClick:(id)sender{
    WS(weakSelf);
    LangSelectVC *langVC = [[LangSelectVC alloc] initWithFrame:self.view.bounds];
    [langVC setFinishchange:^(NSDictionary *langdic,LangSelectVC *selectVC) {
        if (langdic) {
            BOOL isZHHans = [[LangUtil shareInstance] isCurrentLanguageZH];
            NSString *langname = [langdic objectForKey:isZHHans ? @"title" : @"title_en"];
            NSString *key = [langdic objectForKey:@"key"];
            weakSelf.webTransLangLabel.stringValue = langname;
            [[LangUtil shareInstance] setSettingForKey:@"webTransLang" andValue:key];
        }
        [selectVC removeFromSuperview];
    }];
    [langVC show];
    [self.view addSubview:langVC];
}

#pragma mark - System

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    NSLog(@"view x:%f y:%f width:%f height:%f",self.view.x,self.view.y,self.view.width,self.view.height);
}

@end
