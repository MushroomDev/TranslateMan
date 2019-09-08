//
//  LangSelectVC.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/26.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface LangSelectVC : NSView

- (instancetype)initWithFrame:(NSRect)frameRect andShowAuto:(BOOL)isShow;

@property(nonatomic,copy)void (^finishchange)(NSDictionary *langdic,LangSelectVC *selectVC);

- (void)show;
- (void)hide;

@end
