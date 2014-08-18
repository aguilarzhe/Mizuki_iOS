//
//  BWRCompleteInvoice.m
//  mizuki
//
//  Created by Carolina Mora on 13/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "AppDelegate.h"
#import "BWRCompleteInvoice.h"
#import "BWRRule.h"
#import "BWRTicketViewElement.h"

@interface BWRCompleteInvoice ()

@property NSManagedObjectContext *managedObjectContext;

@end


@implementation BWRCompleteInvoice

//Invoice
@synthesize rfc;
@synthesize idInvoice;
@synthesize date;
@synthesize status;
@synthesize image;
@synthesize resultOCR;
@synthesize company;

@synthesize rulesViewElementsArray;
@synthesize managedObjectContext;


-(BWRCompleteInvoice *) initWithData:(NSMutableArray *)rules rfc:(NSString *)rfcTicket ticketImage:(UIImage *)invoiceImage stringOCR:(NSString *)OCRresult company:(NSString *)organitation{
    
    self = [super init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    //rulesviewarray
    rulesViewElementsArray = [[NSMutableArray alloc] initWithArray:rules];
    
    //Init Invoice
    NSString *dateFormat = [self stringDateFormatterFromDate:[NSDate date]];
    
    idInvoice = dateFormat;
    rfc = rfcTicket;
    image = invoiceImage;
    date = dateFormat;
    status = @"Pendiente";
    resultOCR = OCRresult;
    company = organitation;
    
    return self;
}

-(BWRCompleteInvoice *) initFromCoreDataWithInvoice:(BWRInvoice *) invoice{
    
    self = [super init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    //Init Invoice
    idInvoice = invoice.idInvoice;
    rfc = invoice.rfc;
    image = [UIImage imageWithData:invoice.image];
    date = [self stringDateFormatterFromDate:invoice.date];
    status = invoice.status;
    resultOCR = invoice.resultOCR;
    company = invoice.company;
    
    //rulesviewarray
    rulesViewElementsArray = [[NSMutableArray alloc] initWithArray:[self getRulesViewElementsOfInvoice]];
    
    return self;
}

-(BOOL) addCompleteInvoiceWithStatus:(NSString *)state {
    
    //Update object
    status = state;
    date = [self stringDateFormatterFromDate:[NSDate date]];
    
    //Add Invoice
    BWRInvoice *addInvoice;
    addInvoice = [NSEntityDescription insertNewObjectForEntityForName:@"Invoice" inManagedObjectContext:managedObjectContext];
    
    addInvoice.status = status;
    addInvoice.date = [NSDate date];
    addInvoice.idInvoice = idInvoice;
    addInvoice.rfc = rfc;
    addInvoice.resultOCR = resultOCR;
    addInvoice.company = company;
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    addInvoice.image = imageData;
    NSLog(@"Agregada Invoice: %@", addInvoice.idInvoice);
    //Add Rules
    for(BWRTicketViewElement *rule in rulesViewElementsArray){
        BWRRule *addRule;
        addRule = [NSEntityDescription insertNewObjectForEntityForName:@"Rule" inManagedObjectContext:managedObjectContext];
        
        addRule.idRule = [NSString stringWithFormat:@"%@-%@", idInvoice, rule.campoTicket];
        addRule.idInvoice_Invoice=idInvoice;
        addRule.ticketField = rule.campoTicket;
        addRule.ticketMask = rule.mascaraTicket;
        addRule.formField = rule.campoFormulario;
        addRule.formFieldType = rule.tipoCampoFormulario;
        addRule.fieldValue = rule.selectionValue;
        NSLog(@"Agregada Rule: %@", addRule.idInvoice_Invoice);
    }
    
    NSError *error = nil;
    if([managedObjectContext save:&error]){
        return  TRUE;
    }
    
    return FALSE;
    
}

-(BOOL) updateCompleteInvoiceWithRFC: (NSString *)uprfc status:(NSString *)state {
    
    //Update Object
    status = state;
    date = [self stringDateFormatterFromDate:[NSDate date]];
    
    //Update Invoice
    BWRInvoice *upInvoice;
    upInvoice.status = state;
    upInvoice.date = [NSDate date];
    upInvoice.idInvoice = idInvoice;
    upInvoice.rfc = uprfc;
    upInvoice.resultOCR = resultOCR;
    upInvoice.company = company;
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    upInvoice.image = imageData;
    
    //Update Rules
    for(BWRTicketViewElement *rule in rulesViewElementsArray){
        BWRRule *upRule;
        upRule.idRule = [NSString stringWithFormat:@"%@-%@", idInvoice, rule.campoTicket];
        upRule.idInvoice_Invoice=idInvoice;
        upRule.ticketField = rule.campoTicket;
        upRule.ticketMask = rule.mascaraTicket;
        upRule.formField = rule.campoFormulario;
        upRule.formFieldType = rule.tipoCampoFormulario;
        upRule.fieldValue = rule.selectionValue;
    }
    
    NSError *error = nil;
    if([managedObjectContext save:&error]){
        return  TRUE;
    }
    
    return FALSE;
}

-(BOOL) ADUCompleteInvoiceWithAction:(NSInteger)action status:(NSString *)state {
    
    //Update object if action is update or add
    if(action==0 || action==2){
        status = state;
        date = [self stringDateFormatterFromDate:[NSDate date]];;
    }
    
    //INVOICE
    BWRInvoice *Invoice;
    //If action add
    if(action==0){
        Invoice = [NSEntityDescription insertNewObjectForEntityForName:@"Invoice" inManagedObjectContext:managedObjectContext];
    }
    //Asing data
    Invoice.status = status;
    Invoice.date = [NSDate date];
    Invoice.idInvoice = idInvoice;
    Invoice.rfc = rfc;
    Invoice.resultOCR = resultOCR;
    Invoice.company = company;
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    Invoice.image = imageData;
    //If action delete
    if(action ==1){
        [managedObjectContext deleteObject:Invoice];
    }
    
    //RULES
    for(BWRTicketViewElement *rule in rulesViewElementsArray){
        BWRRule *Rule;
        
        //If action add
        if(action==0){
            Rule = [NSEntityDescription insertNewObjectForEntityForName:@"Rule" inManagedObjectContext:managedObjectContext];
        }
        //Asing data
        Rule.idRule = [NSString stringWithFormat:@"%@-%@", idInvoice, rule.campoTicket];
        Rule.idInvoice_Invoice=idInvoice;
        Rule.ticketField = rule.campoTicket;
        Rule.ticketMask = rule.mascaraTicket;
        Rule.formField = rule.campoFormulario;
        Rule.formFieldType = rule.tipoCampoFormulario;
        Rule.fieldValue = rule.selectionValue;
        //If action delete
        if(action ==1){
            [managedObjectContext deleteObject:Rule];
        }
    }
    
    NSError *error = nil;
    if([managedObjectContext save:&error]){
        return  TRUE;
    }
    
    return FALSE;
    
}

-(NSMutableArray *) getRulesViewElementsOfInvoice{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Rule"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"idInvoice_Invoice == %@",idInvoice];
    [fetchRequest setPredicate:predicateID];
    
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error){
        
        //Do array of viewElements from rule array - core data
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        
        for(BWRRule *rule in fetchedObjects){
            BWRTicketViewElement *viewElement = [[BWRTicketViewElement alloc] initTicketInfoWithElements:rule.ticketField mask:rule.ticketMask form:rule.formField type:rule.formFieldType value:rule.fieldValue];
            [resultArray addObject:viewElement];
        }
        
        return resultArray;
    }
    return nil;
}

-(NSString *)stringDateFormatterFromDate: (NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd/HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *stringDate = [dateFormatter stringFromDate:date];
    
    return stringDate;
}

@end