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

-(void)setRFCwithRFCInfo: (BWRRFCInfo *)rfcInfo {
    
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

-(BOOL)validateRFCData{
    NSString *regexRFC = @"[a-zA-Z]{3,4}[0-9]{6,7}[a-zA-Z]{1,2}[0-9]";
    NSString *regexPostCode = @"[0-9]{5}";
    NSString *regexOnlyChar = @"[a-zA-Z Ã¡Ã�Ã©Ã‰Ã­Ã�Ã³Ã“ÃºÃšÃ±Ã‘.]*";
    NSString *regexAnyText = @"[a-zA-Z0-9 Ã¡Ã�Ã©Ã‰Ã­Ã�Ã³Ã“ÃºÃšÃ±Ã‘.-]+";
    NSString *regexAnyTextOrEmpty = @"[a-zA-Z0-9Ã¡Ã�Ã©Ã‰Ã­Ã�Ã³Ã“ÃºÃšÃ±Ã‘ .-]*";
    
    if ([self validateField:rfc regexString:regexRFC] &&
        [self validateField:nombre regexString:regexAnyText] &&
        [self validateField:apellidoPaterno regexString:regexOnlyChar] &&
        [self validateField:apellidoMaterno regexString:regexOnlyChar] &&
        [self validateField:calle regexString:regexAnyText] &&
        [self validateField:numExterior regexString:regexAnyTextOrEmpty] &&
        [self validateField:numInterior regexString:regexAnyTextOrEmpty] &&
        [self validateField:colonia regexString:regexAnyTextOrEmpty] &&
        [self validateField:delegacion regexString:regexOnlyChar] &&
        [self validateField:ciudad regexString:regexAnyTextOrEmpty] &&
        [self validateField:localidad regexString:regexAnyTextOrEmpty] &&
        [self validateField:estado regexString:regexOnlyChar] &&
        [self validateField:codigoPostal regexString:regexPostCode]){
        return TRUE;
    }else{
        return FALSE;
    }
}

-(BOOL)validateField:(NSString *)field regexString:(NSString *)string{
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:string options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:field options:0
                                                      range:NSMakeRange(0, [field length])];
    
    if (match) {
        return TRUE;
    }else{
        [BWRMessagesToUser Alert:@"Datos no válidos" message:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Error en el campo: ",nil), field]];
        return FALSE;
    }
}

@end