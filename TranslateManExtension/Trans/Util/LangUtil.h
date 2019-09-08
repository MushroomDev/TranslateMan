//
//  LangUtil.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/26.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LangUtil : NSObject

+(LangUtil *)shareInstance;

- (id)getSettingForKey:(NSString *)key;

- (void)setSettingForKey:(NSString *)key andValue:(id)value;

- (id)getLangForKey:(NSString *)key;

- (NSArray *)getLangArray;

//设置翻译语言 0 from 1 to
- (void)setLang:(NSString *)key type:(int)type;

//点击了语言
- (void)useLang:(NSString *)key;

//当前系统语言是不是中文
- (BOOL)isCurrentLanguageZH;

@end

