//
//  SWTextView.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/30.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SWTextViewDelegate <NSObject>

- (void)keyDownTranslate;

@end


@interface SWTextView : NSTextView

@property (nonatomic,weak) id<SWTextViewDelegate> swdelegate;

- (NSString *)stringValue;
@end

