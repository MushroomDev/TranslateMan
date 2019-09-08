//
//  SWImageView.h
//  AirPlayer
//
//  Created by wangshiwen on 2019/5/12.
//  Copyright © 2019 swain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWImageView : NSImageView

@property(nonatomic,copy)void (^clickEvent)();

@end

NS_ASSUME_NONNULL_END
