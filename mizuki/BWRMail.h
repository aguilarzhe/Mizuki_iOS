//
//  BWRMail.h
//  mizuki
//
//  Created by Carolina-iOS on 25/11/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "BWRRFCInfo.h"

@interface BWRMail : NSObject <MFMailComposeViewControllerDelegate>

@property BWRRFCInfo *rfcData;

-(BWRMail*) initWithRFC: (BWRRFCInfo *)rfc image:(UIImage *)image context:(UIViewController *)controller;
- (void) showEmailWithCompany: (NSString *)company;

@end
