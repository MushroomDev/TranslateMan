//
//  GoogleTransService.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/24.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "GoogleTransService.h"
#import "AFNetworking.h"
#import "Lang.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MacroDefine.h"
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    GoogleTransServiceServiceType_V1,
    GoogleTransServiceServiceType_V2,
} GoogleTransServiceServiceType;

@implementation TransObject

- (NSDictionary *)coverToDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.type?self.type:@"" forKey:@"type"];
    [dic setObject:self.sourcetext?self.sourcetext:@"" forKey:@"sourcetext"];
    [dic setObject:self.result?self.result:@"" forKey:@"result"];
    [dic setObject:self.synonymArray?self.synonymArray:@"" forKey:@"synonymArray"];
    [dic setObject:self.pinyin?self.pinyin:@"" forKey:@"pinyin"];
    [dic setObject:self.wordtype?self.wordtype:@"" forKey:@"wordtype"];
    [dic setObject:self.sourcelang?self.sourcelang:@"" forKey:@"sourcelang"];
    
    return dic;
}

//根据字典转模型V2接口
- (void)covertFromDicV1:(NSArray *)dic
{
    NSArray *temparray = dic[0];
    
    //词属性
    id obj = dic[1];
    if ([obj class]!= [NSNull class]) {
        NSString *wordtypetrans = dic[1][0][0];
        self.wordtype = wordtypetrans;
        self.type = @"Word";
        //近义词
        NSArray *synonym = dic[1][0][1];
        self.synonymArray = synonym;
    }else{
        self.type = @"Sentence";
    }
    
    //翻译
    {
        if (temparray.count>2) {
            NSString *result = @"";
            for (int i=0; i<temparray.count-1; i++) {
                NSArray *littleword = temparray[i];
                result = [result stringByAppendingString:littleword[0]];
            }
            self.result = result;
            
        }else{
            NSArray *wordtrans = dic[0][0];
            self.result = wordtrans[0];
            
        }
    }
    
    //拼音
    {
        NSArray *lastarray = [temparray lastObject];
        NSArray *pinyintrans = lastarray;
        self.pinyin = [NSString stringWithFormat:@"[%@]",[pinyintrans lastObject]];
    }
    
    //原语言
    {
        NSArray *lastparam = [dic lastObject];
        NSArray *langarray = [lastparam lastObject];
        //object.sourcelang = langarray[0];
    }
    
}

//根据字典转模型V2接口
- (void)covertFromDicV2:(NSDictionary *)dic
{
    self.type = @"Sentence";
    //获取翻译句子
    if (dic[@"sentences"]) {
        __block NSString *totalTrans = @"";
        NSArray *sentences = dic[@"sentences"];
        [sentences enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *trans = obj[@"trans"];
            totalTrans = [totalTrans stringByAppendingString:trans];
        }];
        self.result = totalTrans;
    }
    
    if (dic[@"src"]) {
        self.sourcelang = dic[@"src"];
    }
}

@end

#define GoogleURL @"https://translate.google.cn/translate_a/single"
#define GoogleTTSURL @"https://translate.google.cn/translate_tts"

@interface GoogleTransService()

@property (nonatomic,strong) JSContext *jsContext;

@property (nonatomic,strong) NSString *fromkey;
@property (nonatomic,strong) NSString *tokey;

@end

@implementation GoogleTransService

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTTK];
    }
    return self;
}

#pragma mark - Member

- (void)translateWorld:(NSString *)word from:(NSString *)fromlang to:(NSString *)tolang source:(NSInteger)source result:(typeof(void(^)(TransObject *)))resultblock
{
    
    if (word == nil || word.length == 0) {
        return;
    }

    if (fromlang == nil || tolang == nil) {
        fromlang = @"auto";
        tolang = @"zh-CN";
    }else{
        
    }

    self.fromkey = fromlang;
    self.tokey = tolang;
    
    GoogleTransServiceServiceType serviceType;
    
    NSString *ttk = [self token:word];
    
    if ([ttk isEqualToString:@"undefined"]) {
        NSLog(@"ttk 计算不出来");
        serviceType = GoogleTransServiceServiceType_V2;
    }else{
        serviceType = GoogleTransServiceServiceType_V1;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.requestSerializer.timeoutInterval = 8;

    NSString *url = GoogleURL;
    
    NSArray *paramDic = [self connectALLParam:fromlang to:tolang text:word ttk:ttk serviceType:serviceType];

    WS(weakSelf);
    [manager GET:url parameters:paramDic progress:^(NSProgress * downloadProgress){
        NSLog(@"projress: %f",downloadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [self logWithFinishRequest:task.originalRequest responseObject:responseObject error:nil];
        //数据处理
        NSData *responseData = (NSData*)responseObject;
        NSString *responseStr  = [[NSString alloc] initWithBytes:responseData.bytes length:responseData.length encoding:NSUTF8StringEncoding];
        NSLog(@"url  %@   responce %@",url,responseStr);
        TransObject *obj = [weakSelf analysisResponseObject:word:responseStr tolang:tolang serviceType:serviceType];
        if (source == 1) {//网页的自动翻译
            if ([obj.result isEqualToString:word]) {
                //[self translateWorld:word from:fromlang to:@"zh-CN" source:source result:resultblock];
                return;
            }
        }
        //返回
        resultblock(obj);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error.description);
    }];
    
}

- (TransObject *)analysisResponseObject:(NSString *)sourcetext :(NSString *)responseObject tolang:(NSString *)tolang serviceType:(GoogleTransServiceServiceType) type
{
    NSData *data=[responseObject dataUsingEncoding:NSUTF8StringEncoding];
    TransObject *object = [[TransObject alloc] init];
    object.sourcetext = sourcetext;
    object.tolang = tolang;
    
    if (type == GoogleTransServiceServiceType_V1) {
        NSArray *dic= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [object covertFromDicV1:dic];
    }else if(type == GoogleTransServiceServiceType_V2){
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [object covertFromDicV2:dic];
    }
    return object;
}

//拼接所有的翻译参数
- (NSDictionary *)connectALLParam:(NSString *)from to:(NSString *)to text:(NSString *)text ttk:(NSString *)ttk serviceType:(GoogleTransServiceServiceType) type
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (type == GoogleTransServiceServiceType_V1) {
        /** v1.0 原版 **/
        [dic setObject:@"gtx" forKey:@"client"];
        [dic setObject:from forKey:@"sl"];
        [dic setObject:to forKey:@"tl"];
        [dic setObject:@"zh-CN" forKey:@"hl"];
        
        NSSet *dtarr = [NSSet setWithObjects:@"at",@"bd",@"ex",@"ld",@"md",@"qca",@"rw",@"rm",@"ss",@"t",@"gt",nil];
        [dic setObject:dtarr forKey:@"dt"];
        
        [dic setObject:@"1" forKey:@"otf"];
        [dic setObject:@"UTF-8" forKey:@"ie"];
        [dic setObject:@"UTF-8" forKey:@"oe"];
        [dic setObject:@"bh" forKey:@"source"];
        [dic setObject:@"0" forKey:@"ssel"];
        [dic setObject:@"0" forKey:@"tsel"];
        [dic setObject:@"2" forKey:@"kc"];
        [dic setObject:ttk forKey:@"tk"];
        [dic setObject:text forKey:@"q"];
    }else if(type == GoogleTransServiceServiceType_V2){
        /** v2.0 **/
        [dic setObject:@"gtx" forKey:@"client"];
        [dic setObject:from forKey:@"sl"];
        [dic setObject:to forKey:@"tl"];
        [dic setObject:@"t" forKey:@"dt"];
        [dic setObject:@"UTF-8" forKey:@"ie"];
        [dic setObject:@"1" forKey:@"dj"];
        [dic setObject:text forKey:@"q"];
    }
    
    return dic;
}

#pragma mark - TTK

- (void)setTTK
{
    //获取脚本路径
    NSString *playPath = [[NSBundle mainBundle] pathForResource:@"Google" ofType:@"js"];
    //根据路径加载为NSString
    NSString *playtool = [NSString stringWithContentsOfFile:playPath encoding:NSUTF8StringEncoding error:nil];
    //增加sourceURL 你可以在Safari-开发-Simulator里面进行给play.js打断点，不设置sourceURL只能使用控制台，没法打断点
    NSURL *playURL = [NSURL URLWithString:playPath];
    
    [self.jsContext evaluateScript:playtool withSourceURL:playURL];
}

- (NSString *)token:(NSString *)text
{
    //已经加载了脚本，开始测试
    NSString *jsValueStr1 = [NSString stringWithFormat:@"token(%@%@%@)",@"'",text,@"'"];
    JSValue *value = [self.jsContext evaluateScript:jsValueStr1];
    NSLog(@"%@ ttk:%@",text,value);
    NSString *tk = [value toString];
    
    return tk;
}

#pragma mark - TTS

- (void)wordTTS:(NSString *)word lang:(NSString *)lang  result:(typeof(void(^)(NSData *)))resultblock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
    NSString *url = GoogleTTSURL;
    NSArray *paramDic = [self paramForTTS:lang text:word];
    
    WS(weakSelf);
    [manager GET:url parameters:paramDic progress:^(NSProgress * downloadProgress){
   
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *responseData = (NSData*)responseObject;
        resultblock(responseData);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error.description);
    }];
}

- (NSDictionary *)paramForTTS:(NSString *)lang text:(NSString *)text
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"UTF-8" forKey:@"ie"];
    [dic setObject:lang forKey:@"tl"];
    [dic setObject:@"1" forKey:@"total"];
    [dic setObject:@"0" forKey:@"idx"];
    [dic setObject:@"11" forKey:@"textlen"];
    [dic setObject:[self token:text] forKey:@"tk"];
    [dic setObject:text forKey:@"q"];
    [dic setObject:@"t" forKey:@"client"];
    return dic;
}

- (void)analysisTTSObject:(NSData *)data{
    
}

#pragma mark - Getter

- (JSContext *)jsContext
{
    if (_jsContext == nil) {
        JSContext *jsContext = [[JSContext alloc] init];
        _jsContext = jsContext;
    }
    return _jsContext;
}

#pragma mark - work

-(void)logWithFinishRequest:(NSURLRequest *)request responseObject:(id)responseObject error:(NSError *)error
{
    NSString *host=request.URL.host;
    NSString *path=request.URL.path;
    NSString *method=request.HTTPMethod;
    NSString *url;
    NSString *query;
    
    NSMutableString *log=[[NSMutableString alloc]initWithString:@"\n\n"];
    [log appendString:@"**************************************************\n"];
    [log appendString:@"*                                                *\n"];
    [log appendString:@"*                 REQUEST  FINISH                *\n"];
    [log appendString:@"*                                                *\n"];
    [log appendString:@"**************************************************\n"];
    
    
    if ([method isEqualToString:@"GET"]) {
        query=request.URL.query;
        url=[request URL].absoluteString;
    }else if([method isEqualToString:@"POST"])
    {
        query=[[NSString alloc]initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        url=[NSString stringWithFormat:@"%@?%@",[request URL].absoluteString,query];
    }
    
    
    [log appendFormat:@"HOST          : %@\n",host];
    [log appendFormat:@"PATH          : %@\n",path];
    [log appendFormat:@"QUERY         : %@\n",query];
    [log appendFormat:@"METHOD        : %@\n",method];
    [log appendFormat:@"RESULT        : %@\n",error?@"FAILED":@"SUCCESS"];
    [log appendFormat:@"URL           : %@\n",url];
    
    if (error==nil) {
        [log appendFormat:@"RESPONSE_DATE :\n%@\n",responseObject];
    }else
    {
        [log appendFormat:@"ERROR_CODE    : %ld\n",error.code];
        [log appendFormat:@"ERROR_MESSAGE : %@\n",error.domain];
    }
    NSLog(@"%@",log);
}

@end
