//
//  BWRRFCInfoController.h
//  mizuki
//
//  Created by Carolina Mora on 24/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRRFCInfo.h"

@interface BWRRFCInfoController: NSObject

@property  NSString *rfc;
@property  NSString *nombre;
@property  NSString *apellidoPaterno;
@property  NSString *apellidoMaterno;
@property  NSString *pais;
@property  NSString *estado;
@property  NSString *delegacion;
@property  NSString *colonia;
@property  NSString *calle;
@property  NSString *numInterior;
@property  NSString *numExterior;
@property  NSString *codigoPostal;
@property  NSString *ciudad;
@property  NSString *localidad;

-(void)createRFCwithData: (NSString *)rfcData name:(NSString *)name fatherLastname:(NSString *)fatherLastname motherLastname:(NSString *)motherLastname country:(NSString *)country state:(NSString *)state delegation:(NSString *)delegation colony:(NSString *)colony street:(NSString *)street internalNum:(NSString *)internalNum externalNum:(NSString *)externalNum postCode:(NSString *)postCode city:(NSString *)city town:(NSString *)town;
-(BOOL)validateRFCData;
-(BOOL)addRFCInfo;
-(BOOL)updateRFCInfoWithRFC: (BWRRFCInfo *)upRFCInfo;


@end