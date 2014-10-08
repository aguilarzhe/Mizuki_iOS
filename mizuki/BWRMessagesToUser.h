//
//  BWRMessagesToUser.h
//  mizuki
//
//  Created by Carolina Mora on 04/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface BWRMessagesToUser : NSObject <UIAlertViewDelegate>

+(void)Alert: (NSString *)title message:(NSString *)message;
+(void)Error: (NSError *)error code:(NSInteger)errorCode message:(NSString *)message;
-(BOOL)Confirmation: (NSString *)question;
+ (void) Notification: (NSString *)message;

@end