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
#import "BWRMessagesToUser.h"

@interface BWRTicketViewElement()

@end

@implementation BWRTicketViewElement

@synthesize formField, formFieldType, ticketField, ticketMask, ticketSearchRegex, selectionValue, dataSource;
@synthesize ticketFieldValue;
@synthesize viewTicketElement;

-(BWRTicketViewElement *)initWithDictionary: (NSDictionary *) ticketElement{
    
    self = [super init];
    
    //Si es textbox
    if(![[ticketElement valueForKey:@"form_field_type"] isEqualToString:@"submit"]){
        ticketField = [ticketElement valueForKey:@"ticket_field"];
        ticketSearchRegex = [ticketElement valueForKey:@"ticket_search_regex"];
        ticketMask = [ticketElement valueForKey:@"ticket_mask"];
        formField = [ticketElement valueForKey:@"form_field"];
        formFieldType = [ticketElement valueForKey:@"form_field_type"];
        //valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
        dataSource = [ticketElement valueForKey:@"data_source"];
        selectionValue = ticketField;//[valueCampoTicket objectAtIndex:0];
    
    //Si es boton
    }else{
        ticketField = @"Enviar";
        ticketMask = @"Ninguno";
        formField = [ticketElement valueForKey:@"form_field"];
        formFieldType = [ticketElement valueForKey:@"form_field_type"];
        //valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
        dataSource = @"Ninguno";
        selectionValue = ticketField;//[valueCampoTicket objectAtIndex:0];
    }
    
    return self;
}

-(BWRTicketViewElement *)initTicketInfoWithElements: (NSString *)field mask:(NSString *)mask form:(NSString *)form type:(NSString *)type value:(NSString *)value{
    
    self = [super init];
    
    ticketField = field;
    ticketSearchRegex = @"";
    ticketMask = mask;
    formField = form;
    formFieldType = type;
    //valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
    dataSource = @"ticketInfo";
    selectionValue = value;//[valueCampoTicket objectAtIndex:0];
    
    return self;
}

-(void)createViewWithRect: (CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height delegate:(UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> *)viewDelegate{
    
    //Si es textbox
    if ([formFieldType isEqualToString:@"textbox"]) {
        UITextField *campoTextField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        campoTextField.placeholder = selectionValue;
        campoTextField.borderStyle = UITextBorderStyleRoundedRect;
        campoTextField.delegate = viewDelegate;
        viewTicketElement = campoTextField;
    }
    
    //Si es combobox
    else if ([formFieldType isEqualToString:@"combobox"]){
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

-(void)findTicketFieldInOCR: (NSString *)resultOCR{
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ticketSearchRegex options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:resultOCR options:0
                                                      range:NSMakeRange(0, [resultOCR length])];
    
    if (match) {
        ((UITextField *)viewTicketElement).text = [resultOCR substringWithRange:match.range];
    }else{
        ((UITextField *)viewTicketElement).text = [NSString stringWithFormat:@"%@ no reconocido",selectionValue];
    }
    
}

-(BOOL)validateFieldValueWithTicketMask{
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ticketMask options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:((UITextField *)viewTicketElement).text  options:0 range:NSMakeRange(0, [((UITextField *)viewTicketElement).text length])];
    
    if (match){
        ((UITextField *)viewTicketElement).text = [((UITextField *)viewTicketElement).text substringWithRange:match.range];
        return TRUE;
    }else{
        [BWRMessagesToUser Alert:@"Datos no válidos" message:[NSString stringWithFormat:@"Error en el campo: %@", ticketField]];
        return FALSE;
    }
}

@end