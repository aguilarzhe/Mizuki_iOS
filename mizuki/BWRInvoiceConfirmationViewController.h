//
//  BWRInvoiceConfirmationViewController.h
//  mizuki
//
//  Created by Efrén Aguilar on 6/11/14.
//  Copyright (c) 2014 Baware S.A. de C.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWRProcessImage.h"

@interface BWRInvoiceConfirmationViewController : UIViewController
@property NSString *invoiceText;
@property UIImage *invoiceImage;

//Temporal
@property UITextView *invoiceLabel;

@end