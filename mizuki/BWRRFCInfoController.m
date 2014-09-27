//
//  BWRRFCInfoController.m
//  mizuki
//
//  Created by Carolina Mora on 24/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRRFCInfoController.h"
#import "BWRMessagesToUser.h"
#import "AppDelegate.h"


@interface BWRRFCInfoController ()

@property NSManagedObjectContext *managedObjectContext;

@end

@implementation BWRRFCInfoController

@synthesize rfc;
@synthesize nombre;
@synthesize apellidoPaterno, apellidoMaterno;
@synthesize pais;
@synthesize estado;
@synthesize delegacion;
@synthesize colonia;
@synthesize calle;
@synthesize numInterior;
@synthesize numExterior;
@synthesize codigoPostal;
@synthesize ciudad;
@synthesize localidad;
@synthesize managedObjectContext;

-(void)createRFCwithRFCInfo: (BWRRFCInfo *)rfcInfo {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    rfc = rfcInfo.rfc;
    nombre = rfcInfo.nombre;
    apellidoPaterno = rfcInfo.apellidoPaterno;
    apellidoMaterno = rfcInfo.apellidoMaterno;
    pais = rfcInfo.pais;
    estado = rfcInfo.estado;
    delegacion = rfcInfo.delegacion;
    colonia = rfcInfo.colonia;
    calle = rfcInfo.calle;
    numInterior = rfcInfo.numInterior;
    numExterior = rfcInfo.numExterior;
    codigoPostal = rfcInfo.codigoPostal;
    ciudad = rfcInfo.ciudad;
    localidad = rfcInfo.localidad;
    
}

-(void)createRFCwithData: (NSString *)rfcData name:(NSString *)name fatherLastname:(NSString *)fatherLastname motherLastname:(NSString *)motherLastname country:(NSString *)country state:(NSString *)state delegation:(NSString *)delegation colony:(NSString *)colony street:(NSString *)street internalNum:(NSString *)internalNum externalNum:(NSString *)externalNum postCode:(NSString *)postCode city:(NSString *)city town:(NSString *)town{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    rfc = rfcData;
    nombre = name;
    apellidoPaterno = fatherLastname;
    apellidoMaterno = motherLastname;
    pais = country;
    estado = state;
    delegacion = delegation;
    colonia = colony;
    calle = street;
    numInterior = internalNum;
    numExterior = externalNum;
    codigoPostal = postCode;
    ciudad = city;
    localidad = town;
}

-(BOOL)validateRFCData{
    NSString *regexRFC = @"[a-zA-Z]{3,4}[0-9]{6,7}[a-zA-Z]{1,2}[0-9]";
    NSString *regexPostCode = @"[0-9]{5}";
    NSString *regexOnlyChar = @"[a-zA-Z áÁéÉíÍóÓúÚñÑ.]*";
    NSString *regexAnyText = @"[a-zA-Z0-9 áÁéÉíÍóÓúÚñÑ-]+";
    NSString *regexAnyTextOrEmpty = @"[a-zA-Z0-9áÁéÉíÍóÓúÚñÑ .-]*";
    
    if([self validateField:@"rfc" text:rfc regexString:regexRFC] ){
    if([self validateField:@"nombre" text:nombre regexString:regexAnyText]){
    if([self validateField:@"apellidoPaterno" text:apellidoPaterno regexString:regexOnlyChar]){
    if([self validateField:@"apellidoMaterno" text:apellidoMaterno regexString:regexOnlyChar]){
    if([self validateField:@"calle" text:calle regexString:regexAnyText]){
    if([self validateField:@"numExterior" text:numExterior regexString:regexAnyTextOrEmpty]){
    if([self validateField:@"numInterior" text:numInterior regexString:regexAnyTextOrEmpty]){
    if([self validateField:@"colonia" text:colonia regexString:regexAnyTextOrEmpty]){
    if([self validateField:@"delegacion" text:delegacion regexString:regexOnlyChar]){
    if([self validateField:@"ciudad" text:ciudad regexString:regexAnyTextOrEmpty]){
    if([self validateField:@"localidad" text:localidad regexString:regexAnyTextOrEmpty]){
    if([self validateField:@"estado" text:estado regexString:regexOnlyChar]){
    if([self validateField:@"codigoPostal" text:codigoPostal regexString:regexPostCode]){
            return TRUE;
    }}}}}}}}}}}}}
        
    return FALSE;
}

-(BOOL)validateField:(NSString *)field text:(NSString *)text regexString:(NSString *)string{
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:string options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0
                                                      range:NSMakeRange(0, [text length])];
    
    if (match) {
        return TRUE;
    }else{
        [BWRMessagesToUser Alert:@"Datos no válidos" message:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Error en el campo: ",nil), NSLocalizedString(field,nil)]];
        return FALSE;
    }
}

-(BOOL)addRFCInfo{
    
    NSError *error = nil;
    
    if([self validateRFCData]){
    
        BWRRFCInfo *addRFCInfo;
        addRFCInfo = [NSEntityDescription insertNewObjectForEntityForName:@"RFCInfo" inManagedObjectContext:managedObjectContext];
        
        addRFCInfo.rfc = rfc;
        addRFCInfo.nombre = nombre;
        addRFCInfo.apellidoPaterno = apellidoPaterno;
        addRFCInfo.apellidoMaterno = apellidoMaterno;
        addRFCInfo.calle = calle;
        addRFCInfo.numExterior = numExterior;
        addRFCInfo.numInterior = numInterior;
        addRFCInfo.delegacion = delegacion;
        addRFCInfo.colonia = colonia;
        addRFCInfo.pais = pais;
        addRFCInfo.estado = estado;
        addRFCInfo.ciudad = ciudad;
        addRFCInfo.localidad = localidad;
        addRFCInfo.codigoPostal = codigoPostal;
        
        if([managedObjectContext save:&error]){
            return  TRUE;
        }
        //If error to save
        [BWRMessagesToUser Error:error code:0 message:@"Error al agregar rfc"];
        
    }
    return FALSE;
}

-(BOOL)updateRFCInfoWithRFC: (BWRRFCInfo *)upRFCInfo{
    
    NSError *error = nil;
    
    if([self validateRFCData]){
        
        upRFCInfo.rfc = rfc;
        upRFCInfo.nombre = nombre;
        upRFCInfo.apellidoPaterno = apellidoPaterno;
        upRFCInfo.apellidoMaterno = apellidoMaterno;
        upRFCInfo.calle = calle;
        upRFCInfo.numExterior = numExterior;
        upRFCInfo.numInterior = numInterior;
        upRFCInfo.delegacion = delegacion;
        upRFCInfo.colonia = colonia;
        upRFCInfo.pais = pais;
        upRFCInfo.estado = estado;
        upRFCInfo.ciudad = ciudad;
        upRFCInfo.localidad = localidad;
        upRFCInfo.codigoPostal = codigoPostal;
        
        if([managedObjectContext save:&error]){
            return  TRUE;
        }
        //If error to save
        [BWRMessagesToUser Error:error code:0 message:@"Error al actualizar rfc"];
    }
    return FALSE;
}

/*-(BOOL)deleteRFCInfo{
    return FALSE;
}*/

@end