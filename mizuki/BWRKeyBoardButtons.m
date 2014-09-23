//
//  BWRKeyBoardButtons.m
//  mizuki
//
//  Created by Carolina Mora on 21/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BWRKeyBoardButtons.h"

@interface BWRKeyBoardButtons ()

@end


@implementation BWRKeyBoardButtons

+(UIToolbar *)getUIToolBarToKeyboard: (CGFloat)width{
    
    UIToolbar *keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sigueinte" style:UIBarButtonItemStylePlain target:self action:@selector(nextField)];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
    
    [keyboardToolBar setItems:[[NSArray alloc] initWithObjects:extraSpace, nextBarButton, doneBarButton, nil]];
    
    return keyboardToolBar;
}

+(void)nextField{
    
}

+(void)resignKeyboard{
    
}

@end