//
//  SafariExtensionViewController.h
//  TranslateManExtension
//
//  Created by wangshiwen on 2018/10/24.
//  Copyright © 2018 wangshiwen. All rights reserved.
//

#import <SafariServices/SafariServices.h>

@interface SafariExtensionViewController : SFSafariExtensionViewController

+ (SafariExtensionViewController *)sharedController;

@end
