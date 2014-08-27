//
//  ViewController.m
//  mizuki
//
//  Created by Efrén Aguilar on 6/11/14.
//  Copyright (c) 2014 Baware S.A. de C.V. All rights reserved.
//

#import "BWRInvoiceHistoryViewController.h"
#import "BWRInvoiceConfirmationViewController.h"
#import "BWREditInvoiceViewController.h"
#import "BWRMyAccountViewController.h"
#import "BWRCompleteInvoice.h"
#import "AppDelegate.h"

@interface BWRInvoiceHistoryViewController ()

@property UIActionSheet *imageInvoiceActionSheet;
@property UIImage *invoiceImage;
@property UIBarButtonItem *settingsButton;
@property NSMutableArray *actualInvoicesArray;
@property UITableView *invoiceTableView;
@property UISegmentedControl *invoiceSegmentedControl;

@end

static BWRCompleteInvoice *actualInvoice;
static NSInteger typeActualInvoice;         //0->solo visualizacion 2->update

@implementation BWRInvoiceHistoryViewController

@synthesize imageInvoiceActionSheet;
@synthesize invoiceImage;
@synthesize settingsButton;
@synthesize invoiceTableView;
@synthesize actualInvoicesArray;
@synthesize invoiceSegmentedControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load invoices from core data
    actualInvoicesArray = [[NSMutableArray alloc] init];
    [self loadInvoicesFromCoreData: @"Todas"];
    
    //Measures
    NSInteger widthScreen = self.view.frame.size.width;
    NSInteger heightScreen = self.view.frame.size.height;
    
    //Invoice Table View
    invoiceTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 55, widthScreen, heightScreen) style:UITableViewStylePlain];
    invoiceTableView.delegate = self;
    invoiceTableView.dataSource = self;
    invoiceTableView.scrollEnabled = YES;
    invoiceTableView.hidden = NO;
    [self.view addSubview:invoiceTableView];
    
    //Segmented control
    invoiceSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Todas", @"Listas", @"Pendientes", @"Error", nil]];
    invoiceSegmentedControl.frame = CGRectMake(10, 70, widthScreen-20, 30);
    invoiceSegmentedControl.selectedSegmentIndex = 0;
    invoiceSegmentedControl.tintColor = [UIColor blueColor];
    [invoiceSegmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview:invoiceSegmentedControl];

    //Navegation buttons
    UIBarButtonItem *imageInvoiceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showImageInvoceActionSheet:)];
    
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

#pragma mark - BWRInvoiceHistorySources
-(void)showImageInvoceActionSheet:(id)sender{
    imageInvoiceActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Agregar factura", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancelar", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Cámara", nil), NSLocalizedString(@"Galeria", nil), NSLocalizedString(@"Capturar datos", nil), nil];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [imageInvoiceActionSheet showInView:self.view];
    }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [imageInvoiceActionSheet showFromBarButtonItem:sender animated:NO];
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

- (void) loadInvoicesFromCoreData: (NSString *)invoiceType{
    
    //Get invoices from data base
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Invoice"];
    NSSortDescriptor *ordenacionPorFecha = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    fetchRequest.sortDescriptors = @[ordenacionPorFecha];
    
    NSError *error;
    NSArray *invoicesResult = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [actualInvoicesArray removeAllObjects];
    if(!error){
        NSLog(@"Recuperación satisfactoria. %d", [invoicesResult count]);
        
        for(BWRInvoice *invoice in invoicesResult){
            BWRCompleteInvoice *completeInvoice = [[BWRCompleteInvoice alloc] initFromCoreDataWithInvoice:invoice];
            if([invoiceType isEqualToString:completeInvoice.status]){
                [actualInvoicesArray addObject:completeInvoice];
            }else if([invoiceType isEqualToString:@"Todas"]){
                [actualInvoicesArray addObject:completeInvoice];
            }
        }
        
    } else {
        NSLog(@"Error al recuperar.");
    }
}

-(void) sendAllPendingInvoices { //Do in background
    
    //Recorrer pending invoices
    
        //Get id company
    
        //Get rules of company
    
        //Get url
    
        //Recorrer rules to actualizar ticket elements
    
        //Eliminar factura
    
        //Facturar
}

#pragma mark - Segmented control sources
- (void)valueChanged:(UISegmentedControl *)segment {
    
    if(segment.selectedSegmentIndex == 0) {
        [self loadInvoicesFromCoreData:@"Todas"];
    }else if(segment.selectedSegmentIndex == 1){
        [self loadInvoicesFromCoreData:@"Facturada"];
    }else if(segment.selectedSegmentIndex == 2){
        [self loadInvoicesFromCoreData:@"Pendiente"];
    }else if(segment.selectedSegmentIndex==3){
        [self loadInvoicesFromCoreData:@"Error"];
    }
    [invoiceTableView reloadData];
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

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == invoiceTableView){
        numberOfRows = [actualInvoicesArray count];
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if(tableView == invoiceTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InvoiceCell"];
        
        BWRCompleteInvoice *completeInvoice = [actualInvoicesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@", completeInvoice.company, completeInvoice.date];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(tableView == invoiceTableView){
        actualInvoice = [actualInvoicesArray objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"EditInvoiceSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if(tableView == invoiceTableView){
            BWRCompleteInvoice *cInvoice = [actualInvoicesArray objectAtIndex:indexPath.row];
            [actualInvoicesArray removeObject:cInvoice];
            [invoiceTableView reloadData];
            if(![cInvoice delateCompleteInvoice]){
                NSLog(@"Error al eliminar");
            }
        }
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

#pragma mark - Navegation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceConfirmationSegue"]){
        BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [segue destinationViewController];
        confirmInvoiceViewController.invoiceResending = NO;
        confirmInvoiceViewController.invoiceImage = invoiceImage;
    }else if([[segue identifier] isEqualToString:@"EditInvoiceSegue"]){
        BWREditInvoiceViewController *editIvoiceViewController = [segue destinationViewController];
        editIvoiceViewController.completeInvoice = actualInvoice;
        editIvoiceViewController.typeInvoice = typeActualInvoice;
    }
}


@end
