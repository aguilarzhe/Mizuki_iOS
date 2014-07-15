//
//  BWRRFCInfo.h
//  mizuki
//
//  Created by Efrén Aguilar on 7/7/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BWRRFCInfo : NSManagedObject
@property (nonatomic, retain) NSString *rfc;
@property (nonatomic, retain) NSString *nombre;
@property (nonatomic, retain) NSString *apellidoPaterno;
@property (nonatomic, retain) NSString *apellidoMaterno;
@property (nonatomic, retain) NSString *pais;
@property (nonatomic, retain) NSString *estado;
@property (nonatomic, retain) NSString *delegacion;
@property (nonatomic, retain) NSString *colonia;
@property (nonatomic, retain) NSString *calle;
@property (nonatomic, retain) NSString *numInterior;
@property (nonatomic, retain) NSString *numExterior;
@property (nonatomic, retain) NSString *codigoPostal;
@property (nonatomic, retain) NSString *ciudad;
@property (nonatomic, retain) NSString *localidad;
@end