//
//  SWTextView.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/30.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "SWTextView.h"
#import "KeyCode.h"

static NSAttributedString *placeHolderString;

@interface SWTextView()

@property (nonatomic,strong)NSString *lastText;

@property (nonatomic)BOOL isTranslate;

@end

@implementation SWTextView

+(void)initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        NSColor *txtColor = [NSColor grayColor];
        NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtColor, NSForegroundColorAttributeName, nil];
        placeHolderString = [[NSAttributedString alloc] initWithString:@"请输入单词或句子" attributes:txtDict];
    }
}

- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super becomeFirstResponder];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if ([[self string] isEqualToString:@""] && self != [[self window] firstResponder])
        [placeHolderString drawAtPoint:NSMakePoint(0,0)];
}

- (BOOL)resignFirstResponder
{
    [self setNeedsDisplay:YES];
    return [super resignFirstResponder];
}

-(void)keyUp:(NSEvent *)event {
    //NSLog(@"按键前 %@",self.stringValue);
    
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
    }else{
        [super keyUp:event];
    }
}

- (NSString *)stringValue
{
    NSMutableString *string = [self string];
    return [NSString stringWithString:string];
}

@end
