//
//  BWRUserPreferences.h
//  mizuki
//
//  Created by Carolina Mora on 02/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

@interface BWRUserPreferences : NSObject

+ (NSString *)getStringValueForKey: (NSString *)key;
+ (void)setStringValue: (NSString *)value forKey:(NSString *)key;
+ (BOOL)getBoolValueForKey: (NSString *)key;
+ (void)setBoolValue: (BOOL)value forKey:(NSString *)key;
+ (NSArray *)getConfPreferencesArray;
+ (void) setDefaultsWithEmail: (NSString *)email;
+ (BOOL) applicationConfigured;
//+ (void) loadUserNotificationSettingsWithApplication: (UIApplication*) application;

@end