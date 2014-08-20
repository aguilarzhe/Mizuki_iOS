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
//Page 1
@property UILabel *rightInvoiceLabel;
@property UITableView *rightInvoiceTableView;
@property NSMutableArray *rightInvoicesArray;
//Page 2
@property UILabel *pendingInvoiceLabel;
@property UITableView *pendingInvoiceTableView;
@property NSMutableArray *pendingInvoicesArray;
//Page 3
@property UILabel *errorInvoiceLabel;
@property UITableView *errorInvoiceTableView;
@property NSMutableArray *errorInvoicesArray;
//Controls
@property UICollectionView *invoiceData;
@property UIPageControl *invoiceDataPageControl;

@end

static BWRCompleteInvoice *actualInvoice;
static NSInteger typeActualInvoice;         //0->solo visualizacion 2->update

@implementation BWRInvoiceHistoryViewController

@synthesize imageInvoiceActionSheet;
@synthesize invoiceImage;
@synthesize settingsButton;
@synthesize rightInvoiceTableView, pendingInvoiceTableView, errorInvoiceTableView;
@synthesize rightInvoicesArray, pendingInvoicesArray, errorInvoicesArray;
@synthesize invoiceData, invoiceDataPageControl;
@synthesize rightInvoiceLabel, pendingInvoiceLabel, errorInvoiceLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load invoices from core data
    rightInvoicesArray = [[NSMutableArray alloc] init];
    pendingInvoicesArray = [[NSMutableArray alloc] init];
    errorInvoicesArray = [[NSMutableArray alloc] init];
    [self loadInvoicesFromCoreData];
    
    //Measures
    NSInteger widthScreen = self.view.frame.size.width;
    NSInteger heightScreen = self.view.frame.size.height;
    
    //PAGE1 ------------------------------------------------------------------------------
    //Right invoice label
    rightInvoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, widthScreen, 44)];
    rightInvoiceLabel.text = @"Facturas hechas";
    
    //Right invoices table
    rightInvoiceTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 64, widthScreen, heightScreen) style:UITableViewStylePlain];
    rightInvoiceTableView.delegate = self;
    rightInvoiceTableView.dataSource = self;
    rightInvoiceTableView.scrollEnabled = YES;
    
    //PAGE2 ------------------------------------------------------------------------------
    //Pending invoice label
    pendingInvoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, widthScreen, 44)];
    pendingInvoiceLabel.text = @"Facturas pendientes";
    
    //Pending invoices table
    pendingInvoiceTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 64, widthScreen, heightScreen) style:UITableViewStylePlain];
    pendingInvoiceTableView.delegate = self;
    pendingInvoiceTableView.dataSource = self;
    pendingInvoiceTableView.scrollEnabled = YES;
    
    //PAGE3 ------------------------------------------------------------------------------
    //Error invoice label
    errorInvoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, widthScreen, 44)];
    errorInvoiceLabel.text = @"Facturas con errores";
    
    //Error invoices table
    errorInvoiceTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 64, widthScreen, heightScreen) style:UITableViewStylePlain];
    errorInvoiceTableView.delegate = self;
    errorInvoiceTableView.dataSource = self;
    errorInvoiceTableView.scrollEnabled = YES;
    
    //CONTROL ------------------------------------------------------------------------------
    UICollectionViewFlowLayout *invoiceDataLayout = [[UICollectionViewFlowLayout alloc] init];
    invoiceDataLayout.minimumLineSpacing = 0.0;
    invoiceDataLayout.itemSize = CGSizeMake(widthScreen-10, heightScreen-100);
    invoiceDataLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    invoiceData= [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, widthScreen, heightScreen-60) collectionViewLayout:invoiceDataLayout];
    invoiceData.dataSource = self;
    invoiceData.delegate = self;
    invoiceData.backgroundColor = [UIColor whiteColor];
    invoiceData.pagingEnabled = YES;
    invoiceData.showsHorizontalScrollIndicator = NO;
    [invoiceData registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"invoiceCell"];
    [self.view addSubview:invoiceData];
    
    invoiceDataPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, heightScreen-70, widthScreen, 20)];
    invoiceDataPageControl.backgroundColor = [UIColor whiteColor];
    invoiceDataPageControl.userInteractionEnabled = NO;
    invoiceDataPageControl.currentPageIndicatorTintColor = [UIColor redColor];
    invoiceDataPageControl.numberOfPages = 3;
    invoiceDataPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [self.view addSubview:invoiceDataPageControl];
    

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

- (void) loadInvoicesFromCoreData {
    
    //Get invoices from data base
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Invoice"];
    NSSortDescriptor *ordenacionPorFecha = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    fetchRequest.sortDescriptors = @[ordenacionPorFecha];
    
    NSError *error;
    NSArray *invoicesResult = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error){
        NSLog(@"Recuperación satisfactoria. %d", [invoicesResult count]);
        
        for(BWRInvoice *invoice in invoicesResult){
            BWRCompleteInvoice *completeInvoice = [[BWRCompleteInvoice alloc] initFromCoreDataWithInvoice:invoice];
            
            if([completeInvoice.status isEqualToString:@"Facturada"]){
                [rightInvoicesArray addObject:completeInvoice];
            }else if([completeInvoice.status isEqualToString:@"Pendiente"]){
                [pendingInvoicesArray addObject:completeInvoice];
            }else{
                [errorInvoicesArray addObject:completeInvoice];
            }
        }
        
    } else {
        NSLog(@"Error al recuperar.");
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

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == rightInvoiceTableView){
        numberOfRows = [rightInvoicesArray count];
    }else if(tableView == pendingInvoiceTableView){
        numberOfRows = [pendingInvoicesArray count];
    }else{
        numberOfRows = [errorInvoicesArray count];
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    //Right invoices table
    if(tableView == rightInvoiceTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RightInvoiceCell"];
        
        BWRCompleteInvoice *completeInvoice = [rightInvoicesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@", completeInvoice.company, completeInvoice.date];
    }
    //Pending invoices table
    else if(tableView == pendingInvoiceTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PendingInvoiceCell"];
        
        BWRCompleteInvoice *completeInvoice = [pendingInvoicesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@", completeInvoice.company, completeInvoice.date];
    }
    //Error invoices table
    else{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ErrorInvoiceCell"];
        
        BWRCompleteInvoice *completeInvoice = [errorInvoicesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@", completeInvoice.company, completeInvoice.date];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    //Right invoices table
    if(tableView == rightInvoiceTableView){
        typeActualInvoice = 0;
        actualInvoice = [rightInvoicesArray objectAtIndex:indexPath.row];
    }
    //Pending invoices table
    else if(tableView == pendingInvoiceTableView){
        typeActualInvoice = 2;
        actualInvoice = [pendingInvoicesArray objectAtIndex:indexPath.row];
    }
    //Error invoices table
    else{
        typeActualInvoice = 2;
        actualInvoice = [errorInvoicesArray objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"EditInvoiceSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //Right invoices table
        if(tableView == rightInvoiceTableView){
            BWRCompleteInvoice *cInvoice = [rightInvoicesArray objectAtIndex:indexPath.row];
            if([cInvoice delateCompleteInvoice]){
                [rightInvoicesArray removeObjectAtIndex:indexPath.row];
                [rightInvoiceTableView reloadData];
            }else{
                NSLog(@"Error al eliminar");
            }
        }
        //Pending invoices table
        else if(tableView == pendingInvoiceTableView){
            BWRCompleteInvoice *cInvoice = [pendingInvoicesArray objectAtIndex:indexPath.row];
            if([cInvoice delateCompleteInvoice]){
                [pendingInvoicesArray removeObjectAtIndex:indexPath.row];
                [pendingInvoiceTableView reloadData];
            }else{
                NSLog(@"Error al eliminar");
            }
        }
        //Error invoices table
        else{
            BWRCompleteInvoice *cInvoice = [errorInvoicesArray objectAtIndex:indexPath.row];
            if([cInvoice delateCompleteInvoice]){
                [errorInvoicesArray removeObjectAtIndex:indexPath.row];
                [errorInvoiceTableView reloadData];
            }else{
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

#pragma mark - Collection view data source
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = nil;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"invoiceCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            [cell.contentView addSubview:rightInvoiceLabel];
            [cell.contentView addSubview:rightInvoiceTableView];
            break;
        
        case 1:
            [cell.contentView addSubview:pendingInvoiceLabel];
            [cell.contentView addSubview:pendingInvoiceTableView];
            break;
            
        default:
            [cell.contentView addSubview:errorInvoiceLabel];
            [cell.contentView addSubview:errorInvoiceTableView];
            break;
    }
    
    return cell;
}

#pragma mark - Navegation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceConfirmationSegue"]){
        BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [segue destinationViewController];
        confirmInvoiceViewController.invoiceImage = invoiceImage;
    }else if([[segue identifier] isEqualToString:@"EditInvoiceSegue"]){
        BWREditInvoiceViewController *editIvoiceViewController = [segue destinationViewController];
        editIvoiceViewController.completeInvoice = actualInvoice;
        editIvoiceViewController.typeInvoice = typeActualInvoice;
    }
}


@end
