//
//  ViewController.m
//  mizuki
//
//  Created by Efrén Aguilar on 6/11/14.
//  Copyright (c) 2014 Baware S.A. de C.V. All rights reserved.
//

#import "BWRInvoiceHistoryViewController.h"
#import "BWRInvoiceConfirmationViewController.h"
#import "BWRProcessImage.h"
#import "BWRMyAccountViewController.h"

@interface BWRInvoiceHistoryViewController ()
@property UIActionSheet *imageInvoiceActionSheet;
@property UIImage *invoiceImage;
@property UITableView *invoiceTableView;
@property NSMutableArray *invoices;
@property UIBarButtonItem *settingsButton;
@end

@implementation BWRInvoiceHistoryViewController
@synthesize imageInvoiceActionSheet;
@synthesize invoiceImage;
@synthesize invoiceTableView;
@synthesize invoices;
@synthesize settingsButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *imageInvoiceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showImageInvoceActionSheet)];
    
    self.navigationItem.rightBarButtonItem = imageInvoiceButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.navigationController.toolbarHidden = NO;
    settingsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Mi cuenta", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsMenu)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[flexibleItem, settingsButton];
    
    self.title = NSLocalizedString(@"Mis facturas", nil);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)showImageInvoceActionSheet{
    imageInvoiceActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Agregar factura", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancelar", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Cámara", nil), NSLocalizedString(@"Galeria", nil), NSLocalizedString(@"Capturar datos", nil), nil];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [imageInvoiceActionSheet showInView:self.view];
    }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [imageInvoiceActionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }
}

-(void)confirmInvoice{
    [self performSegueWithIdentifier:@"invoiceConfirmationSegue" sender:self];
}

-(void)showSettingsMenu{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self performSegueWithIdentifier:@"showMyAccountSegue" sender:self];
    }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        BWRMyAccountViewController *myAccountViewController = [[BWRMyAccountViewController alloc] init];
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:myAccountViewController];
        [popoverController presentPopoverFromBarButtonItem:settingsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"invoiceConfirmationSegue"]){
        BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [segue destinationViewController];
        confirmInvoiceViewController.invoiceImage = invoiceImage;
    }
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

-(void)captureInvoiceFromPhotoLibrary{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
        myImagePickerController.delegate = self;
        myImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        myImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        myImagePickerController.allowsEditing = NO;
        [self presentViewController:myImagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self captureInvoiceFromCamera];
            break;
        case 1:
            [self captureInvoiceFromPhotoLibrary];
            break;
        default:
            break;
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

@end
