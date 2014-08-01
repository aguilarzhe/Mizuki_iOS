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
/***********TEMPORAL*/
@property UITextField *textField;

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
    // Tabla de información de usuario
    UILabel *userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, width, 44.0f)];
    userInfoLabel.text = NSLocalizedString(@"Datos de usuario", nil);
    
    userInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, width, (44 * dummyUserInfoDictionary.count)) style:UITableViewStylePlain];
    userInfoTableView.scrollEnabled = NO;
    userInfoTableView.dataSource = self;
    userInfoTableView.delegate = self;
    
    // Tabla de RFC
    UILabel *rfcLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 135.0f, width, 44.0f)];
    rfcLabel.text = @"RFC";
    
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 170.0f, width, (44 * (numRowsRFC + 1))) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    
    //Tabla de Configuraciones
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
    
    /********************* TEMPORAL*/
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 310.0f+(44 * [confInfoDictionary count]), width, 44 )];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.delegate = self;
    _textField.text = [userDefaults valueForKey:@"ipServidor"];
    [scrollView addSubview:_textField];
    /********************/
    
    // Configuración de vista
    self.view=scrollView;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cerrar sesión" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.title = NSLocalizedString(@"Mi cuenta", nil);
}

/************************* TEMPORAL********/
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setValue:textField.text forKey:@"ipServidor"];
    NSLog(@"IP SERVIDOR: %@", textField.text);
    [textField resignFirstResponder];
    return YES;
}
/***********************/

-(void)initializeDummyDataSources{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSString *email, *levelAccount;
    if(!(email = [userDefaults valueForKey:@"Correo"])){
        NSLog(@"Setting email");
        [userDefaults setValue:@"aguilarzhe@gmail.com" forKey:@"Correo"];
        email = [userDefaults valueForKey:@"Correo"];
    }
    if(!(levelAccount = [userDefaults valueForKey:@"Tipo cuenta"])){
        [userDefaults setValue:@"Premium" forKey:@"Tipo cuenta"];
        levelAccount = [userDefaults valueForKey:@"Tipo cuenta"];
    }
    
    
    dummyUserInfoDictionary = [[NSDictionary alloc]initWithObjects:@[email, levelAccount] forKeys:@[@"Correo", @"Tipo cuenta"]];
}

-(void)initializeConfDataSources{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    NSNumber *notificaciones = [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Notificaciones"]];
    NSNumber *sonido = [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Sonido"]];
    NSNumber *guardarFoto = [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Guardar Fotos"]];
    NSNumber *conexion = [[NSNumber alloc] initWithBool:[userDefaults boolForKey:@"Solo wifi"]];
    
    confInfoDictionary = [[NSDictionary alloc]initWithObjects:@[notificaciones, sonido, guardarFoto, conexion] forKeys:@[@"Notificaciones", @"Sonido", @"Guardar Fotos", @"Solo wifi"]];
}

#pragma mark - UITableViewDelegate


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
    
    if(tableView == rfcTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RFC"];
        if (indexPath.row < numRowsRFC) {
            BWRRFCInfo *rfcInfo = [fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = rfcInfo.rfc;
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
            if ([[userDefaults valueForKey:@"rfc"] isEqualToString:rfcInfo.rfc]) {
                cell.textLabel.textColor = [UIColor blueColor];
            }
        }else{
            cell.textLabel.text = NSLocalizedString(@"Agregar RFC", nil);
        }
    }else if(tableView == userInfoTableView){
        key = [dummyUserInfoDictionary allKeys][indexPath.row];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"USERINFO"];
        cell.textLabel.text = NSLocalizedString(key, nil);
        cell.detailTextLabel.text = dummyUserInfoDictionary[key];
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
    if(tableView == rfcTableView){
        //Mostrar opciones para RFC
        if (indexPath.row < numRowsRFC) {
            rfcActual = [fetchedResultsController objectAtIndexPath:indexPath];
            
            rfcActionSheet = [[UIActionSheet alloc] initWithTitle:@"Opciones RFC" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:@"Eliminar" otherButtonTitles:@"Seleccionar",@"Editar", nil];
            
            [rfcActionSheet showInView:self.view];
            //Agregar un nuevo rfc
        }else{
            if(numRowsRFC<5){
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
    else if(tableView == confInfoTableView){
        [confInfoTableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell* cell = [confInfoTableView cellForRowAtIndexPath:indexPath];
        UISwitch* switcher = (UISwitch*)cell.accessoryView;
        [switcher setOn:!switcher.on animated:YES];
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        [userDefaults setBool:switcher.on forKey:[confInfoDictionary allKeys][indexPath.row]];
        NSLog(@"La configuración %@ ahora tiene el valor %hhd", [confInfoDictionary allKeys][indexPath.row], switcher.on);
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    switch (buttonIndex) {
        case 0://Eliminar un RFC
            [self delateRFC];
            break;
        case 1://Establecer un RFC para facturación
            [userDefaults setValue:rfcActual.rfc forKey:@"rfc"];
            NSLog(@"RFC Seleccionado para facturación: %@", [userDefaults valueForKey:@"rfc"]);
            [rfcTableView reloadData];
            break;
        case 2://Editar un RFC
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error RFC" message:@"Verifique los datos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    if(numRowsRFC>1){
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        if (![[userDefaults valueForKey:@"rfc"] isEqualToString:rfcActual.rfc]) {
            
            [managedObjectContext deleteObject:rfcActual];
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                [alertView setMessage:[NSString stringWithFormat:@"Can't Delete! %@ %@", error, [error localizedDescription]]];
                return;
            }
        
            [self loadCoreData];
            //[rfcTableView setFrame:CGRectMake(0, rfcTableView.frame.origin.y, rfcTableView.frame.size.width, (44*numRowsRFC))];
            [rfcTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * numRowsRFC))];
            [rfcTableView reloadData];
            
        }else{
            [alertView setMessage:@"El rfc a eliminar es el seleccionado para facturar. Seleccione otro para poder eliminarlo"];
            return;
        }
    }else{
        NSLog(@"Can't Delete. Debe de haber al menos un RFC");
        [alertView setMessage:@"Can't Delete. Debe de haber al menos un RFC"];
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
        NSLog(@"Error al recuperar.");
    }
    
}

@end