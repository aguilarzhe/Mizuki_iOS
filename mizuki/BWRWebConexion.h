//
//  BWRWebConexion.h
//  mizuki
//
//  Created by Carolina Mora on 05/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

@interface BWRWebConexion : NSObject

+ (NSMutableArray *) companyListWithSubstring: (NSString *)substring;

+ (NSDictionary *) viewElementsWithCompany: (NSInteger)idCompany;

@end