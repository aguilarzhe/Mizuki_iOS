//
//  BWRInvoice.h
//  mizuki
//
//  Created by Carolina Mora on 13/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BWRInvoice : NSManagedObject

@property (nonatomic, retain) NSString *idInvoice;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSData *image;
@property (nonatomic, retain) NSString *resultOCR;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *rfc;

@end