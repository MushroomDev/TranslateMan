//
//  Lang.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/25.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

typedef enum : NSUInteger {
    Lang_AUTO,           // 自动检测语种
    Lang_ZH,             // 中文
    Lang_EN,             // 英语
    Lang_JP,             // 日语
    Lang_JPKA,           // 日语假名
    Lang_TH,             // 泰语
    Lang_FRA,            // 法语
    Lang_SPA,            // 西班牙语
    Lang_KOR,            // 韩语
    Lang_TR,             // 土耳其语
    Lang_VIE,            // 越南语
    Lang_MS,             // 马来语
    Lang_DE,             // 德语
    Lang_RU,             // 俄语
    Lang_IR,             // 伊朗语
    Lang_ARA,            // 阿拉伯语
    Lang_PL,             // 波兰语
    Lang_DAN,            // 丹麦语
    Lang_YUE,            // 粤语
    Lang_WYW,            // 文言文
    Lang_CHT,            // 中文繁体
    Lang_IT,             // 意大利语
    Lang_KK,             // 哈萨克语
    Lang_TL              // 菲律宾语
} Lang;

#define NumKey(INDEX) [NSNumber numberWithUnsignedInteger:INDEX]
