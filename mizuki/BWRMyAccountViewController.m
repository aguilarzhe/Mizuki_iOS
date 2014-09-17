//
//  BWRMyAccount.m
//  mizuki
//
//  Created by Efrén Aguilar on 7/2/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRMyAccountViewController.h"
#import "BWRInvoiceDataViewController.h"
#import "BWRUserPreferences.h"
#import "BWRMessagesToUser.h"
#import "AppDelegate.h"
#import "Models/BWRRFCInfo.h"

@interface BWRMyAccountViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
@property UIActionSheet *rfcActionSheet;
@property UITableView *rfcTableView;
@property UITableView *userInfoTableView;
@property UITableView *confInfoTableView;
@property NSDictionary *dummyUserInfoDictionary;
@property NSDictionary *confInfoDictionary;
@property NSManagedObjectContext *managedObjectContext;
@property NSFetchedResultsController *fetchedResultsController;
@property NSUInteger numRowsRFC;
@property BWRRFCInfo *rfcActual;

@end

@implementation BWRMyAccountViewController
@synthesize rfcActionSheet;
@synthesize rfcTableView, userInfoTableView, confInfoTableView;
@synthesize dummyUserInfoDictionary, confInfoDictionary;
@synthesize managedObjectContext, fetchedResultsController;
@synthesize numRowsRFC;
@synthesize rfcActual;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self initializeDummyDataSources];
    [self initializeConfDataSources];
    
    // Core Data
    [self loadCoreData];
    int width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?self.view.frame.size.width : 320.0f;
    // User information table
    UILabel *userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, width, 44.0f)];
    userInfoLabel.text = NSLocalizedString(@"Datos de usuario", nil);
    
    userInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, width, (44 * dummyUserInfoDictionary.count)) style:UITableViewStylePlain];
    userInfoTableView.scrollEnabled = NO;
    userInfoTableView.dataSource = self;
    userInfoTableView.delegate = self;
    
    // RFC table
    UILabel *rfcLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 135.0f, width, 44.0f)];
    rfcLabel.text = @"RFC";
    
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 170.0f, width, (44 * (numRowsRFC + 1))) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    
    //Configurations table
    UILabel *confInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 180.0f+(44 * (numRowsRFC + 1)), width, 44.0f)];
    confInfoLabel.text = NSLocalizedString(@"Configuración", nil);
    
    confInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 220.0f+(44 * (numRowsRFC + 1)), width, (44 * confInfoDictionary.count)) style:UITableViewStylePlain];
    confInfoTableView.scrollEnabled = NO;
    confInfoTableView.dataSource = self;
    confInfoTableView.delegate = self;
    
    //Scroll View
    UIScrollView *scrollView=(UIScrollView *)self.view;
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.contentSize=CGSizeMake(320,560);
    
    [scrollView addSubview:userInfoLabel];
    [scrollView addSubview:userInfoTableView];
    [scrollView addSubview:rfcLabel];
    [scrollView addSubview:rfcTableView];
    [scrollView addSubview:confInfoLabel];
    [scrollView addSubview:confInfoTableView];
    
    //Configuring view
    self.view=scrollView;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cerrar sesión" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.title = NSLocalizedString(@"Mi cuenta", nil);
}

-(void)initializeDummyDataSources{
    NSString *email, *levelAccount;
    
    //Get email an account lavel
    if(!(email = [BWRUserPreferences getStringValueForKey:@"Correo"])){
        NSLog(@"Setting email");
        [BWRUserPreferences setStringValue:@"aguilarzhe@gmail.com" forKey:@"Correo"];
        email = @"aguilarzhe@gmail.com";
    }
    if(!(levelAccount = [BWRUserPreferences getStringValueForKey:@"Tipo cuenta"])){
        [BWRUserPreferences setStringValue:@"Premium" forKey:@"Tipo cuenta"];
        levelAccount = @"Premium";
    }
    
    dummyUserInfoDictionary = [[NSDictionary alloc]initWithObjects:@[email, levelAccount] forKeys:@[@"Correo", @"Tipo cuenta"]];
}

-(void)initializeConfDataSources{
    confInfoDictionary = [[NSDictionary alloc]initWithObjects:[BWRUserPreferences getConfPreferencesArray] forKeys:@[@"Notificaciones", @"Sonido", @"Guardar Fotos", @"Solo wifi"]];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == rfcTableView){
        numberOfRows = numRowsRFC + 1;
    }else if(tableView == userInfoTableView){
        numberOfRows = [dummyUserInfoDictionary count];
    }else if(tableView == confInfoTableView){
        numberOfRows = [confInfoDictionary count];
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    NSString *key;
    
    //RFC table
    if(tableView == rfcTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RFC"];
        if (indexPath.row < numRowsRFC) {
            BWRRFCInfo *rfcInfo = [fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = rfcInfo.rfc;
            if ([[BWRUserPreferences getStringValueForKey:@"rfc"] isEqualToString:rfcInfo.rfc]) {
                cell.textLabel.textColor = [UIColor blueColor];
            }
        }else{
            cell.textLabel.text = NSLocalizedString(@"Agregar RFC", nil);
        }
    
    //User information table
    }else if(tableView == userInfoTableView){
        key = [dummyUserInfoDictionary allKeys][indexPath.row];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"USERINFO"];
        cell.textLabel.text = NSLocalizedString(key, nil);
        cell.detailTextLabel.text = dummyUserInfoDictionary[key];
        
    //Configurations table
    }else if(tableView == confInfoTableView){
        key = [confInfoDictionary allKeys][indexPath.row];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CONFIG"];
        cell.textLabel.text = NSLocalizedString(key, nil);
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        if([confInfoDictionary[key] boolValue])
            [switchView setOn:YES animated:NO];
        else
            [switchView setOn:NO animated:NO];
        cell.accessoryView = switchView;
    }
    
    return cell;
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    [switchControl setOn:!switchControl.on animated:YES];
}

-(void) logout{
    // TODO: Implement logout
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //RFC table
    if(tableView == rfcTableView){
        //Show RFC options
        if (indexPath.row < numRowsRFC) {
            rfcActual = [fetchedResultsController objectAtIndexPath:indexPath];
            
            rfcActionSheet = [[UIActionSheet alloc] initWithTitle:@"Opciones RFC" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:@"Eliminar" otherButtonTitles:@"Seleccionar",@"Editar", nil];
            
            [rfcActionSheet showInView:self.view];
        
        //Add new rfc
        }else{
            
            //Get maximus number of rfc's acording to acount type
            NSInteger maxNumRFC = 0;
            if([[BWRUserPreferences getStringValueForKey:@"Tipo cuenta"] isEqualToString:@"Premium"]){
                maxNumRFC = 5;
            }else{
                maxNumRFC = 2;
            }
            
            //Evaluate maxismus number of rfc's
            if(numRowsRFC<maxNumRFC){
                if (self.modalPresentationStyle == UIModalPresentationPopover){
                    BWRInvoiceDataViewController *createInvoiceData = [[BWRInvoiceDataViewController alloc] init];
                    [createInvoiceData initWithDefault:@"Datos de Facturación"];
                    createInvoiceData.modalPresentationStyle=UIModalPresentationOverCurrentContext;

                    [self presentViewController:createInvoiceData animated:YES completion:nil];
                }else{
                    [self performSegueWithIdentifier:@"createInvoiceDataSegue" sender:self];
                }
            }else{
                NSLog(@"No se pueden tener más de 5 rfc");
            }
        }
    }
    
    //Configurations table
    else if(tableView == confInfoTableView){
        [confInfoTableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell* cell = [confInfoTableView cellForRowAtIndexPath:indexPath];
        UISwitch* switcher = (UISwitch*)cell.accessoryView;
        [switcher setOn:!switcher.on animated:YES];
        
        [BWRUserPreferences setBoolValue:switcher.on forKey:[confInfoDictionary allKeys][indexPath.row]];
        NSLog(@"La configuración %@ ahora tiene el valor %hhd", [confInfoDictionary allKeys][indexPath.row], switcher.on);
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://Delate a RFC
            [self delateRFC];
            break;
            
        case 1://Select a RFC to invoicing
            [BWRUserPreferences setStringValue:rfcActual.rfc forKey:@"rfc"];
            //NSLog(@"RFC Seleccionado para facturación: %@", [userDefaults valueForKey:@"rfc"]);
            [rfcTableView reloadData];
            break;
            
        case 2://Edit a RFC
            [self performSegueWithIdentifier:@"editInvoiceDataSegue" sender:self];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"editInvoiceDataSegue"]){
        BWRInvoiceDataViewController *editInvoiceData = [segue destinationViewController];
        [editInvoiceData initWithBWRRFCInfo:rfcActual title:@"Datos de Facturación"];
    }else{
        BWRInvoiceDataViewController *createInvoiceData = [segue destinationViewController];
        [createInvoiceData initWithDefault:@"Datos de Facturación"];
    }
}

#pragma mark - EditData

- (void)delateRFC
{
    //Validate that there is at least one RFC
    if(numRowsRFC>1){
        
        //Validate selected RFC
        if (![[BWRUserPreferences getStringValueForKey:@"rfc"] isEqualToString:rfcActual.rfc]) {
            
            [managedObjectContext deleteObject:rfcActual];
            NSError *error = nil;
            
            //Save changes in data base
            if (![managedObjectContext save:&error]) {
                [BWRMessagesToUser Error:error code:0 message:@"Can't Delate!"];
                
                return;
            }
        
            [self loadCoreData];
            //[rfcTableView setFrame:CGRectMake(0, rfcTableView.frame.origin.y, rfcTableView.frame.size.width, (44*numRowsRFC))];
            [rfcTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * numRowsRFC))];
            [rfcTableView reloadData];
            
        }else{
            [BWRMessagesToUser Alert:@"Error RFC" message:@"El rfc a eliminar es el seleccionado para facturar. Seleccione otro para poder eliminarlo"];
            return;
        }
    
    }else{
        [BWRMessagesToUser Alert:@"Error RFC" message:@"Can't Delete. Debe de haber al menos un RFC"];
        NSLog(@"Can't Delete. Debe de haber al menos un RFC");
    }
    
}

- (void)loadCoreData
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RFCInfo"];
    NSSortDescriptor *ordenacionPorNombre = [[NSSortDescriptor alloc] initWithKey:@"rfc" ascending:YES];
    fetchRequest.sortDescriptors = @[ordenacionPorNombre];
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;
    
    NSError *fetchingError = nil;
    if ([fetchedResultsController performFetch:&fetchingError]) {
        NSLog(@"Recuperación satisfactoria.");
        id <NSFetchedResultsSectionInfo> sectionInfo = fetchedResultsController.sections[0];
        numRowsRFC = [sectionInfo numberOfObjects];
    } else {
        [BWRMessagesToUser Error:fetchingError code:1 message:@"No se pudieron obtener rfc's de la base"];
    }
    
}

@end