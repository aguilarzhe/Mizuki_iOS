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

@interface BWRMail : NSObject

@property BWRRFCInfo *rfcData;

-(BWRMail*) initWithRFC: (BWRRFCInfo *)rfc image:(UIImage *)image context:(UIViewController<MFMailComposeViewControllerDelegate> *)controller;
- (void) showEmailWithCompany: (NSString *)company;
- (void) didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;

@end
