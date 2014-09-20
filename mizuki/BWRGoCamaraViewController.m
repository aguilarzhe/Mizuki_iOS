//
//  BWRGoCamaraViewController.m
//  mizuki
//
//  Created by Carolina Mora on 11/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "BWRGoCamaraViewController.h"
#import "BWRInvoiceConfirmationViewController.h"

@interface BWRGoCamaraViewController ()

@property UIImage *invoiceImage;

@end

@implementation BWRGoCamaraViewController

@synthesize invoiceImage;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self captureInvoiceFromCamera];
}

-(void)viewDidAppear:(BOOL)animated {
    //[self.navigationController pushViewController:self animated:YES];
    //[self viewDidLoad];
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
    [self captureInvoiceFromCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Captura de imagen
-(void)captureInvoiceFromCamera{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
        myImagePickerController.delegate = self;
        myImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        myImagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
        myImagePickerController.allowsEditing = NO;
        [self presentViewController:myImagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info [UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        invoiceImage = info[UIImagePickerControllerOriginalImage];
        [self confirmInvoice];
    }
}

-(void)confirmInvoice{
    NSLog(@"NavegationController: %@", self.navigationController);
    [self.navigationController performSegueWithIdentifier:@"invoiceCamaraConfirmationSegue" sender:self];
    /*BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [[BWRInvoiceConfirmationViewController alloc] init];
    confirmInvoiceViewController.invoiceAction = 0;
    confirmInvoiceViewController.invoiceImage = invoiceImage;
    [self.navigationController pushViewController:confirmInvoiceViewController animated:YES];*/
}

#pragma mark - Navegation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceCamaraConfirmationSegue"]){
        BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [segue destinationViewController];
        confirmInvoiceViewController.invoiceAction = 0;
        confirmInvoiceViewController.invoiceImage = invoiceImage;
    }
}

@end
