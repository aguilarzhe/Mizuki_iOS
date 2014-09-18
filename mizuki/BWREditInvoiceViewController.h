//
//  BWREditInvoiceViewController.h
//  mizuki
//
//  Created by Carolina Mora on 16/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWRCompleteInvoice.h"

@interface BWREditInvoiceViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property BWRCompleteInvoice *completeInvoice;

@end
