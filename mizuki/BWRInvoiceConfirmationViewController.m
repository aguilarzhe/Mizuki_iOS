//
//  BWRInvoiceConfirmationViewController.m
//  mizuki
//
//  Created by Efrén Aguilar on 6/11/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRInvoiceConfirmationViewController.h"

@interface BWRInvoiceConfirmationViewController ()


@end

@implementation BWRInvoiceConfirmationViewController
@synthesize invoiceLabel;
@synthesize invoiceText;

- (void)viewDidLoad {
    [super viewDidLoad];
    invoiceLabel.text = invoiceText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end