//
//  LangSelectVC.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/26.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "LangSelectVC.h"
#import "LangUtil.h"
#import "FlippedView.h"
#import "NSView+Category.h"
#import "SWButton.h"
#import "MacroDefine.h"

@interface LangSelectVC ()

@property (nonatomic,strong) FlippedView *contentView;

@property (nonatomic,strong) NSMutableArray *langBtnArray;
@property (nonatomic,strong) NSMutableArray *offtenuseBtnArray;

@property (nonatomic,strong) NSView *lineview;

@property (nonatomic,strong) NSView *bgview;

@property (nonatomic,strong) NSScrollView *scrollView;

@property (nonatomic) BOOL iscreate;

/** 是否是简体中文 */
@property (nonatomic,assign) BOOL isZHHans;

/** 是否显示自动检测 */
@property (nonatomic,assign) BOOL isShowAuto;

@end

@implementation LangSelectVC

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.isShowAuto = YES;
        [self createUI];
        self.lineview.wantsLayer = YES;
        self.lineview.layer.backgroundColor = [NSColor windowBackgroundColor].CGColor;
        
        [self createLangBtn];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect andShowAuto:(BOOL)isShow
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.isShowAuto = isShow;
        [self createUI];
        
        self.lineview.wantsLayer = YES;
        self.lineview.layer.backgroundColor = [NSColor windowBackgroundColor].CGColor;
        
        [self createLangBtn];
    }
    return self;
}


#pragma mark - Member

- (void)createUI
{
    self.isZHHans = [[LangUtil shareInstance] isCurrentLanguageZH];
    //NSLog(@"当前系统语言:%@",currentLanguage);
    
    self.scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    
    //[self.scrollView setScrollerStyle:NSScrollerStyleOverlay];
    [self.scrollView setHasVerticalScroller:NO];
    [self.scrollView setHasHorizontalScroller:NO];
    [self.scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    //[self.scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    //[self.scrollView setVerticalScrollElasticity:NSScrollElasticityNone];
    
    //self.scrollView.layer.borderWidth = 1;
    //self.scrollView.layer.borderColor = [NSColor redColor].CGColor;
    self.scrollView.wantsLayer = YES;
    self.scrollView.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    
    self.contentView = [[FlippedView alloc] initWithFrame:self.bounds];
    self.scrollView.documentView = self.contentView;
    self.contentView.wantsLayer = YES;
    self.contentView.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    
    //返回按钮
    SWButton *backBtn =  [[SWButton alloc] initWithFrame:CGRectMake(0, 10, 90, 30)];
    [backBtn setTitle:self.isZHHans ? @"← 语言" : @"← Language"];
    // 一般用法， 用这个就够了， 设置btn的属性，别用cell，坑人
    [backBtn setAlignment:NSTextAlignmentCenter];
    [backBtn setFont:[NSFont systemFontOfSize:13]];
    //[backBtn setSound:[NSSound soundNamed:@"Pop"]];
    [backBtn setBordered:NO];
    [backBtn setTarget:self];
    backBtn.wantsLayer = YES;
    //self.fromLangBtn.layer.backgroundColor = [NSColor clearColor].CGColor;
    backBtn.layer.shadowOpacity = 0.5;
    backBtn.layer.shadowRadius = 0.5;
    backBtn.layer.shadowColor = [NSColor whiteColor].CGColor;
    backBtn.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    //[backBtn setBezelStyle:(NSBezelStyleTexturedSquare)];
    //[[backBtn cell] setBackgroundColor:[NSColor whiteColor]];
    //backBtn.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    [backBtn setAction:@selector(backBtnClick:)];
    [self.contentView addSubview:backBtn];
    
    self.bgview = [[NSView alloc] initWithFrame:CGRectMake(10, 40, self.contentView.bounds.size.width-20, self.contentView.bounds.size.height-50)];
    [self.contentView addSubview:self.bgview];
    
    self.bgview.wantsLayer = YES;
    self.bgview.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.bgview.layer.cornerRadius = 10;
    
    self.iscreate = YES;
}

- (void)createLangBtn
{
    NSArray *offtenUse = [[LangUtil shareInstance] getSettingForKey:@"offtenuse"];
    NSArray *alllang = [[LangUtil shareInstance] getLangArray];
    
    self.langBtnArray = [NSMutableArray array];
    self.offtenuseBtnArray = [NSMutableArray array];
    
    CGFloat viewheight = 40;
    
    if (offtenUse.count>0) {
        viewheight += 10;
        for (int i=1; i<=offtenUse.count;i++) {
            NSString *key = [offtenUse objectAtIndex:i-1];
            NSDictionary *dic = [[LangUtil shareInstance] getLangForKey:key];
            NSString *title = [dic objectForKey:self.isZHHans ? @"title" : @"title_en"];
            
            int index = (i-1)%3;
            int cell = 0;
            if (i%3==0) {
                cell = i/3;
            }else{
                cell = i/3+1;
            }
            
            float y = viewheight+(cell-1)*(30+10);
            float x = 15*(index+1)+index*90;
            
            //NSLog(@"index:%d cell:%d x:%f y:%f",index,cell,x,y);
            
            NSButton *btn = [self createBtn:title x:x y:y tag:i recommend:YES];
            [self.offtenuseBtnArray addObject:btn];
            [self.contentView addSubview:btn];
            
            if (i == offtenUse.count) {
                viewheight = btn.bottom;
            }
        }
        viewheight += 10;
        
        //分割线
        self.lineview = [[NSView alloc] initWithFrame:CGRectMake(30, viewheight, self.width-60, 1)];
        [self.contentView addSubview:self.lineview];
        self.lineview.wantsLayer = YES;
        self.lineview.layer.backgroundColor = ALLRGBColor(236, 236, 236).CGColor;
    }
    
    
    if (alllang.count>0) {
        viewheight += 10;
        for (int i=1; i<=alllang.count;i++) {
            NSDictionary *dic = [alllang objectAtIndex:i-1];
            NSString *title = [dic objectForKey:self.isZHHans ? @"title" : @"title_en"];
            
            int index = (i-1)%3;
            int cell = 0;
            if (i%3==0) {
                cell = i/3;
            }else{
                cell = i/3+1;
            }
            
            float y = viewheight+(cell-1)*(30+10);
            float x = 15*(index+1)+index*90;
            
            NSLog(@"index:%d cell:%d x:%f y:%f",index,cell,x,y);
            
            NSButton *btn = [self createBtn:title x:x y:y tag:i recommend:NO];
            [self.langBtnArray addObject:btn];
            [self.contentView addSubview:btn];
            
            if (i== alllang.count) {
                viewheight = btn.bottom;
            }
        }
        viewheight += 40;
    }
    self.contentView.height = viewheight;
    [self updateHeight];
}


- (void)refreshBtns
{
    NSArray *offtenUse = [[LangUtil shareInstance] getSettingForKey:@"offtenuse"];
    NSArray *alllang = [[LangUtil shareInstance] getLangArray];
    
    CGFloat viewheight = 40;
    
    if (offtenUse.count>0) {
        viewheight += 10;
        for (int i=1; i<=offtenUse.count;i++) {
            NSString *key = [offtenUse objectAtIndex:i-1];
            NSDictionary *dic = [[LangUtil shareInstance] getLangForKey:key];
            NSString *title = [dic objectForKey:self.isZHHans ? @"title" : @"title_en"];
            
            int index = (i-1)%3;
            int cell = 0;
            if (i%3==0) {
                cell = i/3;
            }else{
                cell = i/3+1;
            }
            
            float y = viewheight+(cell-1)*(30+10);
            float x = 15*(index+1)+index*90;
            
            //NSLog(@"index:%d cell:%d x:%f y:%f",index,cell,x,y);
            
            if (i-1<=self.offtenuseBtnArray.count-1) {
                NSButton *btn = self.offtenuseBtnArray[i-1];
                [btn setTitle:title];
                btn.origin = CGPointMake(x, y);
                btn.tag = i;
            }else{
                NSButton *btn = [self createBtn:title x:x y:y tag:i recommend:NO];
                [self.contentView addSubview:btn];
                [self.offtenuseBtnArray addObject:btn];
            }
            
            if (i == offtenUse.count) {
                NSButton *btn = self.offtenuseBtnArray[i-1];
                viewheight = btn.bottom;
            }
            
            //最后一个
            if (i == offtenUse.count && self.offtenuseBtnArray.count>offtenUse.count) {
                for (int k = i-1;k<self.offtenuseBtnArray.count ; k++) {
                    NSButton *btn = self.offtenuseBtnArray[k];
                    btn.hidden = YES;
                }
            }
        }
        viewheight += 10;
        
        self.lineview.frame = CGRectMake(25, viewheight, self.width-50, 1);
    }
    
    if (alllang.count>0) {
        viewheight += 10;
        for (int i=1; i<=alllang.count;i++) {
            NSDictionary *dic = [alllang objectAtIndex:i-1];
            NSString *title = [dic objectForKey:self.isZHHans ? @"title" : @"title_en"];
            
            int index = (i-1)%3;
            int cell = 0;
            if (i%3==0) {
                cell = i/3;
            }else{
                cell = i/3+1;
            }
            
            float y = viewheight+(cell-1)*(30+10);
            float x = 15*(index+1)+index*90;
            
            //NSLog(@"index:%d cell:%d x:%f y:%f",index,cell,x,y);
            
            NSButton *btn = nil;
            if (i-1<=self.langBtnArray.count-1) {
                btn = self.langBtnArray[i-1];
                [btn setTitle:title];
                btn.origin = CGPointMake(x, y);
                btn.tag = i;
            }else{
                btn = [self createBtn:title x:x y:y tag:i recommend:NO];
                [self.contentView addSubview:btn];
                [self.langBtnArray addObject:btn];
            }
            
            if (i== alllang.count) {
                viewheight = btn.bottom;
            }
            
        }
        viewheight += 40;
    }
    
    self.contentView.height = viewheight;
    [self updateHeight];
}

- (NSButton *)createBtn:(NSString *)title x:(CGFloat)x y:(CGFloat)y tag:(int)tag recommend:(BOOL)isrecom
{
    SWButton *btn =  [[SWButton alloc] initWithFrame:CGRectMake(x, y, 90, 30)];
    //[btn setBezelStyle:NSThickSquareBezelStyle];
    [btn setTitle:[NSString stringWithFormat:@"%@%d",title,tag]];
    //[btn setButtonType:NSMomentaryLightButton];
    // 设置按钮上文字的对齐方式
    btn.tag = tag;
    btn.toolTip = title;
    [[btn cell] setAlignment:NSTextAlignmentCenter];
    [[btn cell] setFont:[NSFont systemFontOfSize:30]];
    // 一般用法， 用这个就够了， 设置btn的属性，别用cell，坑人
    [btn setAlignment:NSTextAlignmentCenter];
    [btn setFont:[NSFont systemFontOfSize:13]];
    //[btn setSound:[NSSound soundNamed:@"Pop"]];
    [btn setBordered:NO];
    //[[btn cell] setBackgroundColor:[NSColor whiteColor]];
    btn.wantsLayer = YES;
    btn.layer.cornerRadius = 5;
    [self addSubview:btn];
    [btn setTarget:self];
    if (isrecom) {
        [btn setAction:@selector(recomClick:)];
    }else{
        [btn setAction:@selector(handelClick:)];
    }
    
    return btn;
}


- (void)updateHeight
{
    if (self.contentView.frame.size.height<self.bounds.size.height) {
        self.contentView.height = self.height;
    }
    
    self.bgview.height = self.contentView.height-50;
}

- (void)show
{
    //CGRect frame = self.view.frame;
    //frame.origin = CGPointMake(0, 0);
    //self.view.frame = CGRectMake(0, 0, 330, 300);
    self.hidden = NO;
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        [context setDuration:0.5];
//        float rotation = self.view.frameRotation;
//        //[[self.view animator] setFrameOrigin:CGPointMake(0, 0)];
//        //[[self.view animator] setFrameSize:CGSizeMake(330,300)];
//        [[self.view animator] setAlphaValue:1.0];
//        //[[animationView animator] setFrameRotation:rotation+360];
//    } completionHandler:^{
//        NSLog(@"All done!");
//    }];
    [self refreshBtns];
}

- (void)hide
{
    self.hidden = YES;
    
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        [context setDuration:0.5];
//        float rotation = self.view.frameRotation;
//        [[self.view animator] setFrameOrigin:CGPointMake(330, 0)];
//        [[self.view animator] setAlphaValue:0.0];
//        //[[animationView animator] setFrameRotation:rotation+360];
//    } completionHandler:^{
//        NSLog(@"All done!");
//    }];
}

#pragma mark - Action

- (IBAction)backBtnClick:(id)sender
{
    [self hide];
    if (self.finishchange) {
        self.finishchange(nil,self);
    }
}

- (void)recomClick:(id)sender
{
    int tag = ((NSButton *)sender).tag;
    NSArray *offtenUse = [[LangUtil shareInstance] getSettingForKey:@"offtenuse"];
    NSString *key = [offtenUse objectAtIndex:tag-1];
    NSDictionary *langdic = [[LangUtil shareInstance] getLangForKey:key];
    
    if (self.finishchange) {
        self.finishchange(langdic,self);
    }
    
    [self hide];
    
}

- (void)handelClick:(id)sender
{
    int tag = ((NSButton *)sender).tag;
    NSArray *langarray = [[LangUtil shareInstance] getLangArray];
    NSDictionary *langdic = [langarray objectAtIndex:tag-1];
    NSString *key = [langdic objectForKey:@"key"];
    
    if (self.finishchange) {
        self.finishchange(langdic,self);
    }
    
    [self hide];
    
}

#pragma mark - System

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    
    self.scrollView.frame = self.bounds;
    
    if (self.contentView.frame.size.height<self.bounds.size.height) {
        self.contentView.height = self.height;
    }
    
    self.bgview.height = self.contentView.height-50;
}
@end
