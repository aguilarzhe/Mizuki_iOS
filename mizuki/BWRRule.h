//
//  BWRRule.h
//  mizuki
//
//  Created by Carolina Mora on 13/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BWRRule : NSManagedObject

@property (nonatomic, retain) NSString *idRule;
@property (nonatomic, retain) NSString *idInvoice_Invoice;
@property (nonatomic, retain) NSString *ticketField;
@property (nonatomic, retain) NSString *ticketMask;
@property (nonatomic, retain) NSString *formField;
@property (nonatomic, retain) NSString *formFieldType;
@property (nonatomic, retain) NSString *fieldValue;

@end