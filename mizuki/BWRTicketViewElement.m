//
//  BWRTicketViewElement.m
//  mizuki
//
//  Created by Carolina Mora on 16/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BWRTicketViewElement.h"

@interface BWRTicketViewElement()

@end

@implementation BWRTicketViewElement

@synthesize campoFormulario, campoTicket, mascaraTicket, tipoCampoFormulario, dataSource;
@synthesize valueCampoTicket;
@synthesize selectionValue;
@synthesize viewTicketElement;

-(BWRTicketViewElement *)initWithDictionary: (NSDictionary *) ticketElement{
    
    self = [super init];
    
    campoTicket = [ticketElement valueForKey:@"campo_ticket"];
    mascaraTicket = [ticketElement valueForKey:@"mascara_ticket"];
    campoFormulario = [ticketElement valueForKey:@"campo_formulario"];
    tipoCampoFormulario = [ticketElement valueForKey:@"tipo_campo_formulario"];
    valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
    dataSource = [ticketElement valueForKey:@"data_source"];
    selectionValue = [valueCampoTicket objectAtIndex:0];
    
    return self;
}

-(void)createViewWithRect: (CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height delegate:(UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> *)viewDelegate{
    
    //Si es textbox
    if ([tipoCampoFormulario isEqualToString:@"textbox"]) {
        UITextField *campoTextField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        campoTextField.placeholder = selectionValue;
        campoTextField.borderStyle = UITextBorderStyleRoundedRect;
        campoTextField.delegate = viewDelegate;
        viewTicketElement = campoTextField;
    }
    //Si es combobox
    else if ([tipoCampoFormulario isEqualToString:@"combobox"]){
        UITableView *campoTableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, width, height) style:UITableViewStylePlain];
        campoTableView.scrollEnabled = NO;
        campoTableView.delegate = viewDelegate;
        campoTableView.dataSource = viewDelegate;
        viewTicketElement = campoTableView;
    }
}

@end