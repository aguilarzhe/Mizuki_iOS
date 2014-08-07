//
//  BWRWebConexion.m
//  mizuki
//
//  Created by Carolina Mora on 05/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRWebConexion.h"


@interface BWRWebConexion ()

@end

static NSData *dataCompany;

@implementation BWRWebConexion

+ (NSMutableArray *) companyListWithSubstring: (NSString *)substring{
    
    //********************* TEMPORAL
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    //******************************
    
    NSData *dataCompany = [self downloadDataOfURL:[NSString stringWithFormat:@"http://%@:3000/company?indicio=%@",[userDefaults valueForKey:@"ipServidor"],substring]];
    if (dataCompany != nil)
    {
        NSMutableArray *companyList =[[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:dataCompany options:0 error:NULL]];
        return companyList;
    }
    return nil;
}

+ (NSDictionary *) viewElementsWithCompany: (NSInteger)idCompany{
    
    //********************* TEMPORAL
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    //******************************
    
    NSData *dataCompany = [self downloadDataOfURL:[NSString stringWithFormat:@"http://%@:3000/company/%d",[userDefaults valueForKey:@"ipServidor"], idCompany]];
    
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