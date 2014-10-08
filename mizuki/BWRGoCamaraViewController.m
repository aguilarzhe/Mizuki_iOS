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

/*-(void)viewDidAppear:(BOOL)animated {
    //[self.navigationController pushViewController:self animated:YES];
    //[self viewDidLoad];
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
    [self captureInvoiceFromCamera];
}*/

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

#pragma mark - Navigation
-(void)confirmInvoice{
    NSLog(@"NavigationController: %@", self.navigationController);
    
    //Get view controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"BWRInvoiceConfirmation"];
    
    //Prepare for segue
    ((BWRInvoiceConfirmationViewController *)vc).invoiceAction = 0;
    ((BWRInvoiceConfirmationViewController *)vc).invoiceImage = invoiceImage;
    
    //Show next view controller
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
