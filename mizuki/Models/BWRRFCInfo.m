//
//  BWRRFCInfo.m
//  mizuki
//
//  Created by Efrén Aguilar on 7/7/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BWRRFCInfo.h"


@implementation BWRRFCInfo
@dynamic rfc;
@dynamic nombre;
@dynamic apellidoPaterno, apellidoMaterno;
@dynamic pais;
@dynamic estado;
@dynamic delegacion;
@dynamic colonia;
@dynamic calle;
@dynamic numInterior;
@dynamic numExterior;
@dynamic codigoPostal;
@dynamic ciudad;
@dynamic localidad;

-(NSString *)getFormValueWhitProperty: (NSString *)property{
    NSString *value;
    
    if([property isEqualToString:@"nombres"]){
        value=self.nombre;
    }
    else if([property isEqualToString:@"apellidos"]){
        value = [NSString stringWithFormat:@"%@ %@",self.apellidoPaterno, self.apellidoMaterno];
    }
    else if([property isEqualToString:@"razonsocial"]){
        value = [NSString stringWithFormat:@"%@ %@ %@", self.nombre, self.apellidoPaterno, self.apellidoMaterno];
    }
    else if ([property isEqualToString:@"homoclave"]){
        
    }else if ([property isEqualToString:@"email"]){
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        value = [userDefaults valueForKey:@"Correo"];
    }
    else if ([property isEqualToString:@"clavePais"]){
        value = @"MX";
    }
    else {
        value=[self valueForKey:property];
    }
    
    return value;
}

@end