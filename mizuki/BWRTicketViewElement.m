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

@synthesize campoFormulario, campoTicket, mascaraTicket, tipoCampoFormulario, dataSource, campoRegex;
@synthesize valueCampoTicket;
@synthesize selectionValue;
@synthesize viewTicketElement;

-(BWRTicketViewElement *)initWithDictionary: (NSDictionary *) ticketElement{
    
    self = [super init];
    
    //Si es textbox
    if(![[ticketElement valueForKey:@"form_field_type"] isEqualToString:@"submit"]){
        campoTicket = [ticketElement valueForKey:@"ticket_field"];
        campoRegex = [ticketElement valueForKey:@"ticket_search_regex"];
        mascaraTicket = [ticketElement valueForKey:@"ticket_mask"];
        campoFormulario = [ticketElement valueForKey:@"form_field"];
        tipoCampoFormulario = [ticketElement valueForKey:@"form_field_type"];
        //valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
        dataSource = [ticketElement valueForKey:@"data_source"];
        selectionValue = campoTicket;//[valueCampoTicket objectAtIndex:0];
    
    //Si es boton
    }else{
        campoTicket = @"Enviar";
        mascaraTicket = @"Ninguno";
        campoFormulario = [ticketElement valueForKey:@"form_field"];
        tipoCampoFormulario = [ticketElement valueForKey:@"form_field_type"];
        //valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
        dataSource = @"Ninguno";
        selectionValue = campoTicket;//[valueCampoTicket objectAtIndex:0];
    }
    
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
        campoTableView.scrollEnabled = YES;
        campoTableView.delegate = viewDelegate;
        campoTableView.dataSource = viewDelegate;
        viewTicketElement = campoTableView;
    }
    
    //Si es boton
    else{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Enviar" forState:UIControlStateNormal];
        button.frame = CGRectMake(x, y, width, height);
        viewTicketElement = button;
    }
}

@end