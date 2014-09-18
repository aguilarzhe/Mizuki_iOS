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
#import "BWRMessagesToUser.h"

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
    
    //Add Rules
    for(BWRTicketViewElement *rule in rulesViewElementsArray){
        BWRRule *addRule;
        addRule = [NSEntityDescription insertNewObjectForEntityForName:@"Rule" inManagedObjectContext:managedObjectContext];
        
        addRule.idRule = [NSString stringWithFormat:@"%@-%@", idInvoice, rule.ticketField];
        addRule.idInvoice_Invoice=idInvoice;
        addRule.ticketField = rule.ticketField;
        addRule.ticketMask = rule.ticketMask;
        addRule.formField = rule.formField;
        addRule.formFieldType = rule.formFieldType;
        addRule.fieldValue = rule.selectionValue;
    }
    
    NSError *error = nil;
    if([managedObjectContext save:&error]){
        return  TRUE;
    }
    
    //If error to save
    [BWRMessagesToUser Error:error code:0 message:@"Error al agregar factura"];
    return FALSE;
    
}

-(BOOL) updateCompleteInvoiceWithRFC: (NSString *)uprfc status:(NSString *)state {
    
    //Update Object
    status = state;
    date = [self stringDateFormatterFromDate:[NSDate date]];
    
    //Get Invoice
    BWRInvoice *upInvoice;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Invoice"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"idInvoice == %@",idInvoice];
    [fetchRequest setPredicate:predicateID];
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error){
        upInvoice = [fetchedObjects objectAtIndex:0];
    }else{
        return FALSE;
    }

    //Update Invoice
    upInvoice.status = state;
    upInvoice.date = [NSDate date];
    upInvoice.idInvoice = idInvoice;
    upInvoice.rfc = uprfc;
    upInvoice.resultOCR = resultOCR;
    upInvoice.company = company;
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    upInvoice.image = imageData;
    
    //Get Rules
    BWRRule *upRule;
    NSInteger index = 0;
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Rule"];
    predicateID = [NSPredicate predicateWithFormat:@"idInvoice_Invoice == %@",idInvoice];
    [fetchRequest setPredicate:predicateID];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error){
        return FALSE;
    }
    
    //Update Rules
    for(BWRTicketViewElement *rule in rulesViewElementsArray){
        upRule = [fetchedObjects objectAtIndex:index];
        index++;
        
        upRule.idRule = [NSString stringWithFormat:@"%@-%@", idInvoice, rule.ticketField];
        upRule.idInvoice_Invoice=idInvoice;
        upRule.ticketField = rule.ticketField;
        upRule.ticketMask = rule.ticketMask;
        upRule.formField = rule.formField;
        upRule.formFieldType = rule.formFieldType;
        upRule.fieldValue = rule.selectionValue;
    }
    
    error = nil;
    if([managedObjectContext save:&error]){
        return  TRUE;
    }
    
    //If error to save
    [BWRMessagesToUser Error:error code:0 message:@"Error al actualizar factura"];
    return FALSE;
}

-(BOOL) delateCompleteInvoice{
    
    //Get Invoice
    BWRInvoice *dInvoice;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Invoice"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"idInvoice == %@",idInvoice];
    [fetchRequest setPredicate:predicateID];
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error){
        dInvoice = [fetchedObjects objectAtIndex:0];
    }else{
        return FALSE;
    }
    
    //Delate Invoice
    [managedObjectContext deleteObject:dInvoice];
    
    //Get Rules
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Rule"];
    predicateID = [NSPredicate predicateWithFormat:@"idInvoice_Invoice == %@",idInvoice];
    [fetchRequest setPredicate:predicateID];
    fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error){
        return FALSE;
    }
    
    //Delete Rules
    for(BWRRule *dRule in fetchedObjects){
        [managedObjectContext deleteObject:dRule];
    }
    
    error = nil;
    if([managedObjectContext save:&error]){
        return  TRUE;
    }
    
    //If error to save
    [BWRMessagesToUser Error:error code:0 message:@"Error al eliminar factura"];
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
            NSLog(@"ViewElement: %@", viewElement.ticketField);
        }
        
        return resultArray;
    }
    return nil;
}

-(NSString *)stringDateFormatterFromDate: (NSDate *)mDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd/HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *stringDate = [dateFormatter stringFromDate:mDate];
    
    return stringDate;
}

@end