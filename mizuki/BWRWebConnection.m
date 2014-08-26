//
//  BWRWebConexion.m
//  mizuki
//
//  Created by Carolina Mora on 05/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRWebConnection.h"


@interface BWRWebConnection ()

@end

static NSData *dataCompany;

@implementation BWRWebConnection

+ (NSMutableArray *) companyListWithSubstring: (NSString *)substring{
    
    NSData *dataCompany = [self downloadDataOfURL:[NSString stringWithFormat:@"http://bawaremobile.com/company?indicio=%@", substring]];
    if (dataCompany != nil)
    {
        NSMutableArray *companyList =[[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:dataCompany options:0 error:NULL]];
        return companyList;
    }
    return nil;
}

+ (NSDictionary *) viewElementsWithCompany: (NSInteger)idCompany{
    
    NSData *dataCompany = [self downloadDataOfURL:[NSString stringWithFormat:@"http://bawaremobile.com/company/%d", idCompany]];
    
    if (dataCompany != nil)
    {
        NSDictionary *companyDataDictionary = [NSJSONSerialization JSONObjectWithData:dataCompany options:0
                                                                                error:NULL];
        return companyDataDictionary;
    }
    return nil;
}

+ (NSData *)downloadDataOfURL:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    
    return data;
}

@end