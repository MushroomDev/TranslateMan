//
//  SWButton.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/30.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWButton : NSButton

- (void)viewDidMoveToWindow;
- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;

@property (nonatomic) BOOL isShowAnimation;

@end

NS_ASSUME_NONNULL_END
