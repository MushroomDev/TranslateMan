//
//  GlobalFunction.h
//  SQLiteMaster
//
//  Created by wangshiwen on 2018/7/24.
//  Copyright © 2018年 http://www.macdev.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface GlobalFunction : NSObject

+ (void)waringAlert:(NSString *)title :(NSString *)content window:(NSWindow *)win;

+ (NSDictionary *)getVideoInfoWithSourcePath:(NSString *)path;
//秒转 分:秒
+ (NSString *)timeFormatted:(int)totalSeconds;

//执行控制台命令
+ (void)runTask:(NSString *)cmdstr;

//获取程序可读写路径
+ (NSString *)getSupportDirectory;

//拷贝文件
+(void)copyFileFromPath:(NSString *)sourcePath toPath:(NSString *)toPath;
@end
