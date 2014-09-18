//
//  BWRUserPreferences.m
//  mizuki
//
//  Created by Carolina Mora on 02/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BWRUserPreferences.h"

@interface BWRUserPreferences ()

@end

@implementation BWRUserPreferences

+ (NSString *)getStringValueForKey: (NSString *)key{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    return [userDefaults valueForKey:key];
}

+ (void)setStringValue: (NSString *)value forKey:(NSString *)key{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setValue:value forKey:key];
    userDefaults = nil;
}

+ (BOOL)getBoolValueForKey: (NSString *)key{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    return [userDefaults boolForKey:key];
}

+ (void)setBoolValue: (BOOL)value forKey:(NSString *)key{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setBool:value forKey:key];
    userDefaults = nil;
}

+ (NSArray *)getConfPreferencesArray{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    NSArray *preferencesArray = @[
                                [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Notificaciones"]],
                                [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Sonido"]],
                                [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Guardar Fotos"]],
                                [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Solo wifi"]]];
    userDefaults = nil;
    return preferencesArray;
}

+ (void) setDefaultsWithEmail:(NSString *)email{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setValue:email forKey:@"Correo"];
    [userDefaults setBool:TRUE forKey:@"Notificaciones"];
    [userDefaults setBool:TRUE forKey:@"Sonido"];
    [userDefaults setBool:TRUE forKey:@"Guardar Fotos"];
    [userDefaults setBool:TRUE forKey:@"Solo wifi"];
    userDefaults = nil;
}

+ (BOOL) applicationConfigured{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    if([userDefaults valueForKey:@"Correo"] && [userDefaults valueForKey:@"rfc"]){
        userDefaults = nil;
        return TRUE;
    }else{
        userDefaults = nil;
        return FALSE;
    }
}


@end