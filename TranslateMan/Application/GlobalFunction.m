//
//  GlobalFunction.m
//  SQLiteMaster
//
//  Created by wangshiwen on 2018/7/24.
//  Copyright © 2018年 http://www.macdev.io. All rights reserved.
//

#import "GlobalFunction.h"
#import <AVFoundation/AVFoundation.h>

@implementation GlobalFunction

+ (void)waringAlert:(NSString *)title :(NSString *)content window:(NSWindow *)win
{
    NSAlert *alert = [[NSAlert alloc] init];
    //增加一个按钮
    [alert addButtonWithTitle:@"Ok"];
    //增加一个按钮
    //[alert addButtonWithTitle:@"Cancel"];
    //提示的标题
    [alert setMessageText:title];
    //提示的详细内容
    [alert setInformativeText:content];
    //设置告警风格
    [alert setAlertStyle:NSCriticalAlertStyle];
    //开始显示告警
    [alert beginSheetModalForWindow:win
                  completionHandler:^(NSModalResponse returnCode){
                      
                      NSLog(@"returnCode %ld",returnCode);
                      
                      if(returnCode==NSAlertFirstButtonReturn){
                          
                      }
                      //用户点击告警上面的按钮后的回调
                  }
     ];
    return;
}

+ (NSDictionary *)getVideoInfoWithSourcePath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:opts];
    CMTime   time = [asset duration];
    float seconds = CMTimeGetSeconds(time);
    
    NSInteger fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    
    return @{@"size" : @(fileSize),
             @"duration" : @(seconds)};
}

+ (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

+ (void)runTask:(NSString *)cmdstr
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    NSString *commandStr = cmdstr;
    NSArray *arguments = [NSArray arrayWithObjects:@"-c",commandStr,nil];
    NSLog(@"arguments : %@",arguments);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
    
    NSLog (@"got\n %@", string);
}

+ (NSString *)getSupportDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appGroupName = @"F4KDKTF5YA.com.instrument.PowerMenu"; /* For example */
    
    NSURL *groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
    
    NSError* theError = nil;
    
    if (![fm fileExistsAtPath:groupContainerURL.path]) {
        if (![fm createDirectoryAtURL: groupContainerURL withIntermediateDirectories:YES attributes:nil error:&theError]) {
            // Handle the error.
        }
    }
    
    return groupContainerURL.path;
}


+(void)copyFileFromPath:(NSString *)sourcePath toPath:(NSString *)toPath
{
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory = NO;
    BOOL isExit = [fileManager fileExistsAtPath:sourcePath isDirectory:&isDirectory];
    
    if (isExit && !isDirectory) {
        NSError *err = nil;
        
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:toPath error:&err];
        
        NSLog(@"single file :%@",err);
        return;
    }
    

    NSArray* array = [fileManager contentsOfDirectoryAtPath:sourcePath error:nil];
    
    for(int i = 0; i<[array count]; i++)
        
    {
        
        NSString *fullPath = [sourcePath stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        NSString *fullToPath = [toPath stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        NSLog(@"%@",fullPath);
        
        NSLog(@"%@",fullToPath);
        
        //判断是不是文件夹
        
        BOOL isFolder = NO;
        
        //判断是不是存在路径 并且是不是文件夹
        
        BOOL isExist = [fileManager fileExistsAtPath:fullPath isDirectory:&isFolder];
        
        if (isExist)
            
        {
            
            NSError *err = nil;
            
            [[NSFileManager defaultManager] copyItemAtPath:fullPath toPath:fullToPath error:&err];
            
            NSLog(@"%@",err);
            
            if (isFolder)
            {
                
                [self copyFileFromPath:fullPath toPath:fullToPath];
                
            }
            
        }
        
    }
    
}


@end
