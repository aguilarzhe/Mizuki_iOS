//
//  BWRMessagesToUser.m
//  mizuki
//
//  Created by Carolina Mora on 04/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BWRMessagesToUser.h"

@interface BWRMessagesToUser ()

@property UIAlertView *alertView;

@end

static bool confirmation;

@implementation BWRMessagesToUser

@synthesize alertView;

+(void)Alert: (NSString *)title message:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title,nil) message:NSLocalizedString(message,nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

+(void)Error: (NSError *)error code:(NSInteger)errorCode message:(NSString *)message{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(message,nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    switch (errorCode) {
        case 0://Error to save the changes in data base
            [alertView setTitle:NSLocalizedString(@"Error base de datos",nil)];
            break;
        
        case 1://Error to get information from data base
            [alertView setTitle:NSLocalizedString(@"Error al recuperar",nil)];
            break;
            
        case 2://Error to get information from server
            [alertView setTitle:NSLocalizedString(@"Error en el servidor",nil)];
            break;
            
        default://Uknown error
            [alertView setTitle:NSLocalizedString(@"Error desconocido",nil)];
            break;
    }
    
    [alertView show];
    NSLog(@"%@ %@ %@", message, error, [error localizedDescription]);
}

-(BOOL)Confirmation: (NSString *)question{
    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmacion",nil) message:NSLocalizedString(question,nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"Si",nil), nil];
    [alertView show];
    
    return confirmation;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        confirmation = TRUE;
    }
    else{
        confirmation = FALSE;
    }
}

+ (void) Notification: (NSString *)message{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"MyNotification" object:nil];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = message;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertAction = @"userActionButton1";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification]; //presentLocalNotificationNow:localNotification];
}

@end