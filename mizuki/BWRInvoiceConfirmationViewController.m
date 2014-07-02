//
//  BWRInvoiceConfirmationViewController.m
//  mizuki
//
//  Created by Efrén Aguilar on 6/11/14.
//  Copyright (c) 2014 Baware S.A. de C.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRInvoiceConfirmationViewController.h"

@interface BWRInvoiceConfirmationViewController ()
@property UIImageView *invoiceImageView;
@end

@implementation BWRInvoiceConfirmationViewController
@synthesize invoiceLabel;
@synthesize invoiceText;
@synthesize invoiceImage;
@synthesize invoiceImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        invoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, self.view.frame.size.width, 200.0f)];
        invoiceLabel = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 260.0f, self.view.frame.size.width - 20, self.view.frame.size.height - 260)];
        [invoiceImageView setContentMode:UIViewContentModeScaleToFill];
    }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
            invoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(500.0f, 60.0f, 480.0f, self.view.frame.size.height - 80.0f) ];
            invoiceLabel = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 480.0f, self.view.frame.size.height - 80.0f)];
            [invoiceImageView setContentMode:UIViewContentModeScaleAspectFit];
        }else{
            invoiceLabel = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 210.0f, 480.0f, 400.0f)];
            invoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 50.0f, 480.0f, 200.0f)];
            [invoiceImageView setContentMode:UIViewContentModeScaleToFill];
        }
        
    }
    
    invoiceImageView.image = invoiceImage;
    [self.view addSubview:invoiceImageView];
    
    
    invoiceLabel.editable = NO;
    invoiceLabel.scrollEnabled = YES;
    invoiceLabel.text = @"Procesando";
    [self.view addSubview:invoiceLabel];


    self.title = @"Confirmación de factura";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:nil];
    
    [self performSelectorInBackground:@selector(processImage) withObject:nil]; // Modificar por GCD
     
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"Enter in viewWillTransitionToSize");

}

-(void)processImage{
    BWRProcessImage *processImage = [[BWRProcessImage alloc] initWithImage:invoiceImageView.image];
    NSString *invoiceTextAux = [processImage processRecognitionOCR];
    
    [self performSelectorOnMainThread:@selector(buildInterfaceFromText:) withObject:invoiceTextAux waitUntilDone:NO];
}

-(void)buildInterfaceFromText:(NSString *)text
{
    self.invoiceText = text;
    invoiceLabel.text = text;
}


@end