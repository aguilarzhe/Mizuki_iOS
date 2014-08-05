//
//  BWRInvoiceTicketPage.h
//  mizuki
//
//  Created by Carolina Mora on 30/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

@interface BWRInvoiceTicketPage : NSObject

@property NSString *name;
@property NSString *pageNumber;
@property NSMutableArray *rules;

-(BWRInvoiceTicketPage *)initWithData: (NSString *)name pageNumber:(NSString *)page;

@end