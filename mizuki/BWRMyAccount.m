//
//  BWRMyAccount.m
//  mizuki
//
//  Created by Efrén Aguilar on 7/2/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRMyAccount.h"
#import "BWRInvoiceDataViewController.h"
#import "AppDelegate.h"
#import "Models/BWRRFCInfo.h"

@interface BWRMyAccount () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
@property UIActionSheet *rfcActionSheet;
@property UITableView *rfcTableView;
@property UITableView *userInfoTableView;
@property NSDictionary *dummyUserInfoDictionary;
@property NSManagedObjectContext *managedObjectContext;
@property NSFetchedResultsController *fetchedResultsController;
@property NSUInteger numRowsRFC;
@property BWRRFCInfo *rfcActual;

@end

@implementation BWRMyAccount
@synthesize rfcActionSheet;
@synthesize rfcTableView, userInfoTableView;
@synthesize dummyUserInfoDictionary;
@synthesize managedObjectContext, fetchedResultsController;
@synthesize numRowsRFC;
@synthesize rfcActual;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self initializeDummyDataSources];
    
    // Core Data
    [self loadCoreData];
    
    
    // Tabla de información de usuario
    UILabel *userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 60.0f, self.view.frame.size.width, 44.0f)];
    userInfoLabel.text = @"Datos de usuario";
    [self.view addSubview:userInfoLabel];
    
    userInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, self.view.frame.size.width, (44 * dummyUserInfoDictionary.count)) style:UITableViewStylePlain];
    userInfoTableView.scrollEnabled = NO;
    userInfoTableView.dataSource = self;
    userInfoTableView.delegate = self;
    [self.view addSubview:userInfoTableView];
    
    // Tabla de RFC
    UILabel *rfcLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 195.0f, 100.0f, 44.0f)];
    rfcLabel.text = @"RFC";
    [self.view addSubview:rfcLabel];
    
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 230.0f, self.view.frame.size.width, (44 * (numRowsRFC + 1))) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    [self.view addSubview:rfcTableView];
    
    // Configuración de vista
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"Mi cuenta";
}

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

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == rfcTableView){
        numberOfRows = numRowsRFC + 1;
    }else if(tableView == userInfoTableView){
        numberOfRows = [dummyUserInfoDictionary count];
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if(tableView == rfcTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RFC"];
        if (indexPath.row < numRowsRFC) {
            BWRRFCInfo *rfcInfo = [fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = rfcInfo.rfc;
        }else{
            cell.textLabel.text = @"Agregar RFC";
        }
    }else if(tableView == userInfoTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"USERINFO"];
        cell.textLabel.text = [dummyUserInfoDictionary allKeys][indexPath.row];
        cell.detailTextLabel.text = dummyUserInfoDictionary[cell.textLabel.text];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == rfcTableView){
        //Mostrar opciones para RFC
        if (indexPath.row < numRowsRFC) {
            rfcActual = [fetchedResultsController objectAtIndexPath:indexPath];
            
            rfcActionSheet = [[UIActionSheet alloc] initWithTitle:@"Opciones RFC" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Seleccionar",@"Editar", nil];
            
            [rfcActionSheet showInView:self.view];
            //Agregar un nuevo rfc
        }else{
            if(numRowsRFC<5){
                [self performSegueWithIdentifier:@"createInvoiceDataSegue" sender:self];
            }else{
                NSLog(@"No se pueden tener más de 5 rfc");
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == rfcTableView){
        if(numRowsRFC>1 && indexPath.row!=numRowsRFC){
            BWRRFCInfo *rfcInfo = [fetchedResultsController objectAtIndexPath:indexPath];
            
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
            if ([[userDefaults valueForKey:@"rfc"] isEqualToString:rfcInfo.rfc]) {
                [userDefaults setValue:@"Sin asignar" forKey:@"rfc"];
            }
            
            [managedObjectContext deleteObject:rfcInfo];
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            [self loadCoreData];
            [rfcTableView reloadData];
            
        }else{
            NSLog(@"Can't Delete. Debe de haber al menos un RFC");
        }
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    switch (buttonIndex) {
        case 0:
            //Establecer un RFC para facturación
            [userDefaults setValue:rfcActual.rfc forKey:@"rfc"];
            NSLog(@"RFC Seleccionado para facturación: %@", [userDefaults valueForKey:@"rfc"]);
            break;
        case 1:
            //Editar un RFC
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