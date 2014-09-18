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

@end

static bool confirmation;

@implementation BWRMessagesToUser

+(void)Alert: (NSString *)title message:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

+(void)Error: (NSError *)error code:(NSInteger)errorCode message:(NSString *)message{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    switch (errorCode) {
        case 0://Error to save the changes in data base
            [alertView setTitle:@"Error base de datos"];
            break;
        
        case 1://Error to get information from data base
            [alertView setTitle:@"Error al recuperar"];
            break;
            
        default://Uknown error
            [alertView setTitle:@"Uknown error"];
            break;
    }
    
    [alertView show];
    NSLog(@"%@ %@ %@", message, error, [error localizedDescription]);
}

+(BOOL)Confirmation: (NSString *)question{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmacion" message:question delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
    return confirmation;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            confirmation = NO;
            break;
        case 1: //"Yes" pressed
            confirmation = YES;
            break;
    }
}

@end