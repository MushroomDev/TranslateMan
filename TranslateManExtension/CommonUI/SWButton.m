//
//  SWButton.m
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/30.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import "SWButton.h"
#import "NSView+Category.h"
#import <QuartzCore/QuartzCore.h>

@interface SWButton()

@property (nonatomic) NSPoint initRollPoint;
@end

@implementation SWButton

//Set the tracking rect for the button(NSView Class).
//If it is set, Event 'MouseEntered' and 'MouseExited' will be caught.
- (void)viewDidMoveToWindow {
    [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
}

//[cursor set] make the current cursor change
- (void)mouseEntered:(NSEvent *)theEvent
{
    NSCursor *cursor = [NSCursor pointingHandCursor];
    [cursor set];
    
    if (self.isShowAnimation) {
        //self.wantsLayer  = YES;
        [self rotation:M_PI/3];
    }
}
//[cursor set] make the current cursor change
- (void)mouseExited:(NSEvent *)theEvent
{
    NSCursor *cursor = [NSCursor arrowCursor];
    [cursor set];
    
    if (self.isShowAnimation) {
        //[self rotation:-M_PI/3];
    }
}

- (void)rotation:(CGFloat) angle{
    
    self.layer.position = self.initRollPoint;
    
    [self setAnchorPoint:CGPointMake(0.5, 0.5)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle , 0, 0, 1)];
    animation.duration = 0.3;
    //animation.cumulative = YES;
    animation.fillMode = kCAFillModeForwards;
    //animation.repeatCount = 0;
    [self.layer addAnimation:animation forKey:@"animation"];
}

-(void)stopAllAnimations{
    [self.layer removeAllAnimations];
}

- (void)layout
{
    [super layout];
    
    self.initRollPoint = self.layer.position; //记住最初的位置
}

@end
