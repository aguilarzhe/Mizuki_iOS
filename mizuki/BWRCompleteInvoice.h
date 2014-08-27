//
//  BWRCompleteInvoice.h
//  mizuki
//
//  Created by Carolina Mora on 13/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BWRInvoice.h"

@interface BWRCompleteInvoice: NSObject

//Invoice
@property  NSString *idInvoice;
@property  NSString *date;
@property  NSString *status;
@property  UIImage *image;
@property  NSString *resultOCR;
@property  NSString *company;
@property  NSString *rfc;

//Rules
@property NSMutableArray *rulesViewElementsArray;

-(BWRCompleteInvoice *) initWithData:(NSArray *)rules rfc:(NSString *)rfc ticketImage:(UIImage *)image stringOCR:(NSString *)OCRresult company:(NSString *)company;
-(BWRCompleteInvoice *) initFromCoreDataWithInvoice:(BWRInvoice *) invoice;
-(BOOL) addCompleteInvoiceWithStatus:(NSString *)status;
-(BOOL) updateCompleteInvoiceWithRFC: (NSString *)rfc status:(NSString *)status;
-(BOOL) delateCompleteInvoice;
-(NSMutableArray *) getRulesViewElementsOfInvoice;


@end