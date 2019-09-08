//
//  LangUtil.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/26.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "LangUtil.h"

@interface LangUtil()

@property NSString *rootPath;
@property NSString *settingPlistPath;
@property NSString *googlePlistPath;

@property NSMutableDictionary *settingDic;
@property NSMutableArray *langArray;
@property NSMutableDictionary *langDic;

/** 是否是简体中文 */
@property (nonatomic,assign) BOOL isZHHans;

@end

@implementation LangUtil

+(LangUtil *)shareInstance
{
    static LangUtil *sharedManageInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        sharedManageInstance = [[LangUtil alloc] init];
        [sharedManageInstance customInit];
    });
    return sharedManageInstance;
}

-(void)customInit
{
    NSString *documentsDirectory = [self getSupportDirectory];
    self.rootPath = documentsDirectory;
    NSString *settingToPath = [documentsDirectory stringByAppendingPathComponent:@"Setting.plist"];
    NSString *googleToPath = [documentsDirectory stringByAppendingPathComponent:@"GoogleLang.plist"];
    
    self.settingPlistPath = settingToPath;
    self.googlePlistPath = googleToPath;
    
    self.settingDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.settingPlistPath];
    self.langArray = [NSMutableArray arrayWithContentsOfFile:self.googlePlistPath];
    
    self.langDic = [NSMutableDictionary dictionary];
    [self.langArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.langDic setObject:obj forKey:[obj objectForKey:@"key"]];
    }];
    
    //获取当前的系统语言
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage containsString:@"zh-Hans"]) {
        self.isZHHans = YES;
    }else{
        self.isZHHans = NO;
    }
}

- (NSString *)getSupportDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appGroupName = @"F4KDKTF5YA.com.instrument.TranslateMac"; /* For example */
    
    NSURL *groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
    
    NSError* theError = nil;
    
    return groupContainerURL.path;
}

//当前是否是中文系统
- (BOOL)isCurrentLanguageZH
{
    return self.isZHHans;
}

- (void)insertNewSettingForKey:(NSString *)key
{
    if ([key isEqualToString:@"webTransLang"]) {
        //网页翻译语言-默认中文
        [self setSettingForKey:@"webTransLang" andValue:@"zh-CN"];
    }else{
        NSLog(@"没找到默认值的设置");
    }
}

#pragma mark - Setting

- (id)getSettingForKey:(NSString *)key
{
    if (![self.settingDic objectForKey:key]) {
        [self insertNewSettingForKey:key];
    }
    return [self.settingDic objectForKey:key];
}

- (void)setSettingForKey:(NSString *)key andValue:(id)value
{
    [self.settingDic setObject:value forKey:key];
    //保存
    [self.settingDic writeToFile:self.settingPlistPath atomically:YES];
}

//点击了语言
- (void)useLang:(NSString *)key
{
    NSMutableArray *offenarray = [self.settingDic objectForKey:@"offtenuse"];
    if ([offenarray containsObject:key]) {
        [offenarray removeObject:key];
        [offenarray insertObject:key atIndex:0];
    }else{
        [offenarray insertObject:key atIndex:0];
    }
    //保存
    [self.settingDic writeToFile:self.settingPlistPath atomically:YES];
}

//设置翻译语言
- (void)setLang:(NSString *)key type:(int)type
{
    if (type == 0) {
        [self.settingDic setObject:key forKey:@"fromlang"];
    }else if(type == 1){
        [self.settingDic setObject:key forKey:@"tolang"];
    }
    //保存
    [self.settingDic writeToFile:self.settingPlistPath atomically:YES];
}

#pragma mark - Lang

- (id)getLangForKey:(NSString *)key
{
    return [self.langDic objectForKey:key];
}

- (NSArray *)getLangArray
{
    return self.langArray;
}

@end
