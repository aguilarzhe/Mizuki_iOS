//
//  InvoiceTicketPage.m
//  mizuki
//
//  Created by Carolina Mora on 30/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRInvoiceTicketPage.h"

@interface BWRInvoiceTicketPage()

@end

@implementation BWRInvoiceTicketPage

-(BWRInvoiceTicketPage *)initWithData:(NSString *)name pageNumber:(NSString *)page{
    
    self = [super init];
    
    self.name = name;
    self.pageNumber = page;
    self.rules = [[NSMutableArray alloc] init];
    
    return self;
}

@end

