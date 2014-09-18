//
//  BWRWebConexion.m
//  mizuki
//
//  Created by Carolina Mora on 05/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BWRWebConnection.h"
#import "BWRUserPreferences.h"

@interface BWRWebConnection ()

@end

static NSData *dataCompany;

@implementation BWRWebConnection

+ (NSMutableArray *) companyListWithSubstring: (NSString *)substring{
    //Validate Connection
    if([self getConnection]){
        NSData *dataCompany = [self downloadDataOfURL:[NSString stringWithFormat:@"http://bawaremobile.com/company?indicio=%@", substring]];
        if (dataCompany != nil)
        {
            NSMutableArray *companyList =[[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:dataCompany options:0 error:NULL]];
            return companyList;
        }
    }
    return nil;
}

+ (NSDictionary *) viewElementsWithCompany: (NSInteger)idCompany{
    //Validate Connection
    if([self getConnection]){
        NSData *dataCompany = [self downloadDataOfURL:[NSString stringWithFormat:@"http://bawaremobile.com/company/%ld", (long) (long)idCompany]];
        
        if (dataCompany != nil)
        {
            NSDictionary *companyDataDictionary = [NSJSONSerialization JSONObjectWithData:dataCompany options:0 error:NULL];
            return companyDataDictionary;
        }
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

+(BOOL)getConnection
{
    NSString* connectionType = [self getConnectionTypeFromStatusBar];
    
    //WIFI
    if([connectionType isEqualToString:@"Wifi"]){
        if([BWRUserPreferences getBoolValueForKey:@"Solo wifi"]){
            return TRUE;
        }
    }
    //NONE
    if ([connectionType isEqualToString:@"None"]) {
        NSLog(@"ERROR NO HAY CONECCION A INTERNET");
    }
    //OTHER
    else {
        NSLog(@"SOLO WIFI ESTÁ ACTIVADO");
        if(!([BWRUserPreferences getBoolValueForKey:@"Solo wifi"])){
            return TRUE;
        }
    }
    
    return FALSE;
    
}

+ (NSString *) getConnectionTypeFromStatusBar {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    int type = [[dataNetworkItemView valueForKey:@"dataNetworkType"] intValue];
    NSLog(@"[INFO] %d log", type);
    switch(type) {
        case 0: return @"None";
        case 1: return @"2G or earlier";
        case 2: return @"3G";
        case 3: return @"4G";
        case 4: return @"LTE";
        case 5: return @"Wifi";
        default: return @"Unknown";
    }
}

@end