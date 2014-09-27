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
#import "BWRMessagesToUser.h"
#import "AppDelegate.h"

@interface BWRInvoiceHistoryViewController ()
@property (nonatomic, retain) UIActionSheet *imageInvoiceActionSheet;
@property UIImage *invoiceImage;
@property UIBarButtonItem *settingsButton;
@property NSMutableArray *allInvoicesArray;
@property NSMutableArray *pendingInvoicesArray;
@property NSMutableArray *actualInvoicesArray;
@property UITableView *invoiceTableView;
@property NSMutableArray *invoices;
@property UIImagePickerController *myImagePickerController;
@property UISegmentedControl *invoiceSegmentedControl;

@end

static BWRCompleteInvoice *actualInvoice;

@implementation BWRInvoiceHistoryViewController

@synthesize imageInvoiceActionSheet;
@synthesize invoiceImage;
@synthesize settingsButton;
@synthesize invoiceTableView;
@synthesize allInvoicesArray;
@synthesize pendingInvoicesArray;
@synthesize actualInvoicesArray;
@synthesize invoiceSegmentedControl;
@synthesize myImagePickerController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load invoices from core data
    allInvoicesArray = [[NSMutableArray alloc] init];
    pendingInvoicesArray = [[NSMutableArray alloc] init];
    //[self loadInvoicesFromCoreData];
    [self performSelectorInBackground:@selector(loadInvoices) withObject:nil];
    actualInvoicesArray = allInvoicesArray;
    
    //Measures
    NSInteger widthScreen = self.view.frame.size.width;
    NSInteger heightScreen = self.view.frame.size.height;
    
    //Segmented control
    invoiceSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Todas", nil), NSLocalizedString(@"Pendientes", nil), nil]];
    invoiceSegmentedControl.frame = CGRectMake(10, 75, widthScreen-20, 30);
    invoiceSegmentedControl.selectedSegmentIndex = 0;
    invoiceSegmentedControl.tintColor = [UIColor blueColor];
    [invoiceSegmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview:invoiceSegmentedControl];
    
    //Invoice Table View
    invoiceTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 115, widthScreen, heightScreen-115) style:UITableViewStylePlain];
    invoiceTableView.delegate = self;
    invoiceTableView.dataSource = self;
    invoiceTableView.scrollEnabled = YES;
    invoiceTableView.hidden = NO;
    [self.view addSubview:invoiceTableView];

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

-(void)viewWillAppear:(BOOL)animated{
    [self performSelectorInBackground:@selector(loadInvoices) withObject:nil];
}

#pragma mark - BWRInvoiceHistorySources
/** Show the options to invoice the ticket.
 */
-(void)showImageInvoceActionSheet:(id)sender{
    imageInvoiceActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Agregar factura", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancelar", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Cámara", nil), NSLocalizedString(@"Galeria", nil), NSLocalizedString(@"Capturar datos", nil), nil];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [imageInvoiceActionSheet showInView:self.view];
    }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [imageInvoiceActionSheet showFromBarButtonItem:sender animated:NO];
    }
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

-(void)loadInvoices{
    while (1){
        [self performSelectorOnMainThread:@selector(loadNewInvoices) withObject:nil waitUntilDone:YES];
        [NSThread sleepForTimeInterval:10];
    }
}

-(void)loadNewInvoices{
    [pendingInvoicesArray removeAllObjects];
    [allInvoicesArray removeAllObjects];
    [self loadInvoicesFromCoreData];
    [invoiceTableView reloadData];
}

/** Get the invoices in array according to type.
 
 Put all invoices that match with the type (rigth, pending or error) in array actualInvoicesArray.
 
 @param invoiceType String invoice type ("Todas", "Facturada", "Pendiente", "Error").
 */
- (void) loadInvoicesFromCoreData{
    
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
        
        for(BWRInvoice *invoice in invoicesResult){
            BWRCompleteInvoice *completeInvoice = [[BWRCompleteInvoice alloc] initFromCoreDataWithInvoice:invoice];
            [allInvoicesArray addObject:completeInvoice];
            if([@"Pendiente" isEqualToString:completeInvoice.status]){
                [pendingInvoicesArray addObject:completeInvoice];
            }
        }
        
    } else {
        NSLog(@"Error al recuperar.");
        [BWRMessagesToUser Error:error code:1 message:@"Error al recuperar facturas"];
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
/** Get the actual invoices according to type selected in UISegmentedControl.
 
 According to type selected, load actualInvoicesArray data to reload invoiceTableView data.
 */
- (void)valueChanged:(UISegmentedControl *)segment {
    
    if(segment.selectedSegmentIndex == 0) {
        actualInvoicesArray = allInvoicesArray;
    }else if(segment.selectedSegmentIndex == 1){
        actualInvoicesArray = pendingInvoicesArray;
    }
    [invoiceTableView reloadData];
}

#pragma mark - Capture of invoice
/** Method to capture ticket from camara.
 
 Prepare the camara to take the ticket photo
 */
-(void)captureInvoiceFromCamera{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        myImagePickerController = [[UIImagePickerController alloc] init];
        myImagePickerController.delegate = self;
        myImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        myImagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
        myImagePickerController.allowsEditing = NO;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:myImagePickerController animated:YES completion:nil];
            }];
        }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            [self presentViewController:myImagePickerController animated:YES completion:nil];
        }
    }
}

/** Get the ticket from galery.
 
 Prapare the photo library to select the ticket photo
 */
-(void)captureInvoiceFromPhotoLibrary{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        myImagePickerController = [[UIImagePickerController alloc] init];
        myImagePickerController.delegate = self;
        myImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        myImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        myImagePickerController.allowsEditing = NO;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:myImagePickerController animated:YES completion:nil];
            }];
        }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            [self presentViewController:myImagePickerController animated:YES completion:nil];
        }
    }
}

/** Get the ticket from data
 
 Invoke BWRConfirmationViewController view to fill ticket data.
 */
-(void)captureInvoiceFromData{
    [self performSegueWithIdentifier:@"InvoiceConfirmationDataSegue" sender:self];
}

#pragma mark - UIActionSheetDelegate
/** Invoke the method according to the selected option in action sheet.
 
 @param actionSheet UIActionSheet that show invoice options.
 @param buttonIndex NSInteger that indicate the selected option.
 */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self captureInvoiceFromCamera];
            break;
        case 1:
            [self captureInvoiceFromPhotoLibrary];
            break;
        case 2:
            [self captureInvoiceFromData];
            break;
        default:
            break;
    }
}


#pragma mark - UIImagePickerControllerDelegate
/** Get the image that was selected or taken.
 
 Actualize the image invoiceImage with the photo
 */
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
/** Get table view number of rows.
 
 If the tableView is invoiceTableView return the number of items in array actualInvoiceArray.
 
 @return numberOfRows NSInteger with the tableview number of rows.
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == invoiceTableView){
        numberOfRows = [actualInvoicesArray count];
    }
    
    return numberOfRows;
}

/** Get the cell content of the tableview.
 
 If the tableView is invoiceTableView, the cell will content company and date invoice at index in array actualInvoicesArray.
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if(tableView == invoiceTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InvoiceCell"];
        
        BWRCompleteInvoice *completeInvoice = [actualInvoicesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@", completeInvoice.company, completeInvoice.date];
    }
    
    return cell;
}

/** Action if a tableview row was clicked.
 
 If tableView is invoiceTableView actualize BWRCompleteInvoice actualInvoice with the invoice selected and go to BWREditInvoiceViewController view to show or chage data invoice.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(tableView == invoiceTableView){
        actualInvoice = [actualInvoicesArray objectAtIndex:indexPath.row];
        [self editInvoice];
    }
}

/** Select the tableview row to edit.
 
 If editingStyle is delete and the tableview is invoiceTableView, it will delete invoice from core data and array actualInvoicesArray, and reload invoiceTableView data.
 */
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

/** Allow the edit options for tableview rows
 */
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    if (editing){
        [invoiceTableView setEditing:YES animated:YES];
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];
        self.navigationItem.leftBarButtonItem = doneButtonItem;
    }
}

-(void)Done{
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [invoiceTableView setEditing:NO animated:NO];
}

#pragma mark - Navegation
/** Go to BWRInvoiceConfirmationViewController.
 
 Use segue to continue the ticket invoice in other view.
 */
-(void)confirmInvoice{
    [self performSegueWithIdentifier:@"invoiceConfirmationSegue" sender:self];
}

/** Go to BWREditInvoiceViewController.
 
 Use segue to edit the ticket invoice information.
 */
-(void)editInvoice{
    [self performSegueWithIdentifier:@"EditInvoiceSegue" sender:self];
}

/** Prepare the reciver class before the segue.
 
 If the segue identifier is invoiceConfirmationSegue, send invoiceImage and indication of don't resend invoice.
 If the segue identifier is EditInvoiceSegue, send actualInvoice and the type inovice.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceConfirmationSegue"]){
        BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [segue destinationViewController];
        confirmInvoiceViewController.invoiceAction = 0;
        confirmInvoiceViewController.invoiceImage = invoiceImage;
    }else if([[segue identifier] isEqualToString:@"EditInvoiceSegue"]){
        BWREditInvoiceViewController *editIvoiceViewController = [segue destinationViewController];
        editIvoiceViewController.completeInvoice = actualInvoice;
    }else if([[segue identifier] isEqualToString:@"InvoiceConfirmationDataSegue"]){
        BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [segue destinationViewController];
        confirmInvoiceViewController.invoiceAction = 2;
    }
}


@end
