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
    
    formField = [ticketElement valueForKey:@"form_field"];
    formFieldType = [ticketElement valueForKey:@"form_field_type"];
    
    //If is textbox
    if([[ticketElement valueForKey:@"form_field_type"] isEqualToString:@"textbox"]){
        ticketField = [ticketElement valueForKey:@"ticket_field"];
        ticketSearchRegex = [ticketElement valueForKey:@"ticket_search_regex"];
        ticketMask = [ticketElement valueForKey:@"ticket_mask"];
        //valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
        dataSource = [ticketElement valueForKey:@"data_source"];
    }
    
    //If is button, javascript code, captcha
    else{
        ticketField = @"Indefinido";
        ticketMask = @"Ninguno";
        //valueCampoTicket = [[NSArray alloc] initWithArray:[ticketElement valueForKey:@"value_campo_ticket"]];
        dataSource = @"Ninguno";
    }
    
    selectionValue = ticketField;//[valueCampoTicket objectAtIndex:0];
    
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
    
    //If is textbox
    if ([formFieldType isEqualToString:@"textbox"]) {
        UITextField *campoTextField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        campoTextField.placeholder = selectionValue;
        campoTextField.borderStyle = UITextBorderStyleRoundedRect;
        campoTextField.delegate = viewDelegate;
        viewTicketElement = campoTextField;
    }
    
    //If is combobox
    else if ([formFieldType isEqualToString:@"combobox"]){
        UITableView *campoTableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, width, height) style:UITableViewStylePlain];
        campoTableView.scrollEnabled = YES;
        campoTableView.delegate = viewDelegate;
        campoTableView.dataSource = viewDelegate;
        viewTicketElement = campoTableView;
    }
    
    //If is button
    else if ([formFieldType isEqualToString:@"submit"]){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:NSLocalizedString(@"Enviar",nil) forState:UIControlStateNormal];
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
        ((UITextField *)viewTicketElement).text = [NSString stringWithFormat:@"%@ %@", selectionValue, NSLocalizedString(@"no reconocido",nil)];
    }
    
}

-(BOOL)validateFieldValueWithTicketMask{
    
    if ([self validateWithTicketMask]){
        return TRUE;
    }else{
        [self editValueFieldAccordingToTicketMask];
        
        if ([self validateWithTicketMask]){
            return TRUE;
        }else{
            [BWRMessagesToUser Alert:@"Datos no válidos" message:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Error en el campo: ",nil), ticketField]];
            return FALSE;
        }
    }
}

-(BOOL) validateWithTicketMask{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ticketMask options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:((UITextField *)viewTicketElement).text  options:0 range:NSMakeRange(0, [((UITextField *)viewTicketElement).text length])];
    
    if (match){
        ((UITextField *)viewTicketElement).text = [((UITextField *)viewTicketElement).text substringWithRange:match.range];
        return TRUE;
    }else{
        return FALSE;
    }
}

-(void)editValueFieldAccordingToTicketMask{
    
    NSCharacterSet *invalidChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890[]{},?:* "];
    
    NSArray *componentsMask = [ticketMask componentsSeparatedByCharactersInSet:invalidChars];
    NSArray *componentsRegex = [ticketSearchRegex componentsSeparatedByCharactersInSet:invalidChars];
    
    //Depuring
    NSString *resultMask = [componentsMask componentsJoinedByString:@""];
    NSString *resultRegex = [componentsRegex componentsJoinedByString:@""];
    NSLog(@"resultado: %@  regex: %@", resultMask, resultRegex);
    
    NSString *rightString = ((UITextField *)viewTicketElement).text;
    for(int index=0; index<resultMask.length; index++){
        if([resultMask characterAtIndex:index] != [resultRegex characterAtIndex:index]){
            rightString = [rightString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c", [resultRegex characterAtIndex:index]] withString:[NSString stringWithFormat:@"%c", [resultMask characterAtIndex:index]]];
            NSLog(@"mask: %c regex:%c", [resultMask characterAtIndex:index], [resultRegex characterAtIndex:index]);
        }
    }
    NSLog(@"rightString: %@", rightString);
    ((UITextField *)viewTicketElement).text = rightString;
}

@end