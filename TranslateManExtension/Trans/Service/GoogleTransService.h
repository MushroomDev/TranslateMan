//
//  GoogleTransService.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/24.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransObject : NSObject
/** 类型 **/
@property (nonatomic,strong)NSString* type;
/** 源文字 **/
@property (nonatomic,strong) NSString *sourcetext;
/** 翻译结果 **/
@property (nonatomic,strong) NSString *result;
/** tts发音 **/
@property (nonatomic,strong) NSData *voiceData;
/** 近义词 **/
@property (nonatomic,strong) NSArray *synonymArray;
/** 拼音 **/
@property (nonatomic,strong) NSString *pinyin;
/** 词属性 **/
@property (nonatomic,strong) NSString *wordtype;
/** 源文字语言 **/
@property (nonatomic,strong) NSString *sourcelang;
/** 结果文字语言 **/
@property (nonatomic,strong) NSString *tolang;

- (NSDictionary *)coverToDic;

//根据字典转模型V2接口
- (void)covertFromDicV1:(NSArray *)dic;
//根据字典转模型V2接口
- (void)covertFromDicV2:(NSDictionary *)dic;
@end

@interface GoogleTransService : NSObject

//执行翻译操作
- (void)translateWorld:(NSString *)word from:(NSString *)fromlang to:(NSString *)tolang source:(NSInteger)source  result:(typeof(void(^)(TransObject *)))resultblock;

//获取tts发音
- (void)wordTTS:(NSString *)word lang:(NSString *)lang  result:(typeof(void(^)(NSData *)))resultblock;
@end

