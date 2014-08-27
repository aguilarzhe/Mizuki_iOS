//
//  BWRTicketViewElement.h
//  mizuki
//
//  Created by Carolina Mora on 16/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//


@interface BWRTicketViewElement : NSObject

@property NSString *ticketField;
@property NSString *ticketSearchRegex;
@property NSString *ticketMask;
@property NSString *formField;
@property NSString *formFieldType;
@property NSArray *ticketFieldValue;
@property NSString *selectionValue;
@property NSString *dataSource;
@property UIView *viewTicketElement;

-(BWRTicketViewElement *)initWithDictionary: (NSDictionary *) ticketElement;
-(BWRTicketViewElement *)initTicketInfoWithElements: (NSString *)ticketField mask:(NSString *)ticketMask form:(NSString *)formField type:(NSString *)formFieldType value:(NSString *)fieldValue;
-(void)createViewWithRect: (CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height delegate:(UIViewController *)viewDelegate;
-(void)findTicketFieldInOCR: (NSString *)resultOCR;
-(BOOL)validateFieldValueWithTicketMask;

@end