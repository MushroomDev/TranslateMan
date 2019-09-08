//
//  SWTextField.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/26.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "SWTextField.h"
#import "KeyCode.h"

@interface SWTextField()

@property (nonatomic,strong)NSString *lastText;

@property (nonatomic)BOOL isTranslate;

@end

@implementation SWTextField

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)keyUp:(NSEvent *)event {
    //NSLog(@"按键前 %@",self.stringValue);
    [super keyUp:event];
    
    if ([event keyCode] == kVK_Command && [event keyCode] == kVK_ANSI_V) {
        //NSLog(@"粘贴键 %d %@",[event keyCode],self.stringValue);
        if ([self.lastText isEqualToString:self.stringValue]) {
            return;
        }
        self.lastText = self.stringValue;
        if (self.swdelegate && [self.swdelegate respondsToSelector:@selector(keyDownTranslate)]) {
            [self.swdelegate keyDownTranslate];
        }
    }else if([event keyCode] == kVK_Return){
        //NSLog(@"回车键 %d",[event keyCode]);
        if ([self.lastText isEqualToString:self.stringValue]) {
            return;
        }
        self.lastText = self.stringValue;
        if (self.swdelegate && [self.swdelegate respondsToSelector:@selector(keyDownTranslate)]) {
            [self.swdelegate keyDownTranslate];
        }
    }
}

//让imageview能够相应点击方法
- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
    [NSApp sendAction:@selector(clicked:) to:self from:self];
}

- (void)clicked:(id)sender {
    if (self.clickEvent) {
        self.clickEvent();
    }
}

@end
