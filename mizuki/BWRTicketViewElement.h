//
//  BWRTicketViewElement.h
//  mizuki
//
//  Created by Carolina Mora on 16/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//


@interface BWRTicketViewElement : NSObject

@property NSString *campoTicket;
@property NSString *mascaraTicket;
@property NSString *campoFormulario;
@property NSString *tipoCampoFormulario;
@property NSArray *valueCampoTicket;
@property NSString *seleccionValue;
@property UIView *viewTicketElement;

-(BWRTicketViewElement *)initWithDictionary: (NSDictionary *) ticketElement;
-(void)createViewWithRect: (CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height delegate:(UIViewController *)viewDelegate;

@end