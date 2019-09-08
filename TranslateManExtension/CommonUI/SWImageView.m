//
//  SWImageView.m
//  AirPlayer
//
//  Created by wangshiwen on 2019/5/12.
//  Copyright © 2019 swain. All rights reserved.
//

#import "SWImageView.h"

@implementation SWImageView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
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
