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

+(BOOL)Confirmation: (NSString *)question{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmacion",nil) message:NSLocalizedString(question,nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"Si",nil), nil];
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