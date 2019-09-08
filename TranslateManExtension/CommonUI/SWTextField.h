//
//  SWTextField.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/26.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SWTextFieldDelegate <NSObject>

- (void)keyDownTranslate;

@end

@interface SWTextField : NSTextField <NSTextFieldDelegate>

@property (nonatomic,weak) id<SWTextFieldDelegate> swdelegate;

@property(nonatomic,copy)void (^clickEvent)();

@end
