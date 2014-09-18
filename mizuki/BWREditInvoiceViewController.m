//
//  BWREditInvoiceViewController.m
//  mizuki
//
//  Created by Carolina Mora on 16/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWREditInvoiceViewController.h"
#import "AppDelegate.h"
#import "BWRRFCInfo.h"
#import "BWRTicketViewElement.h"
#import "BWRWebConnection.h"
#import "BWRInvoiceTicketPage.h"
#import "BWRInvoiceConfirmationViewController.h"

@interface BWREditInvoiceViewController ()

@property UITableView *rfcTableView;
@property UITextField *companyTextField;
@property UIImageView *ticketImage;
@property UIScrollView *ticketScrollView;
@property UIActionSheet *rfcActionSheet;
@property NSArray *fetchedResults;
@property NSString *rfcSelected;
//Send invoice
@property NSURL *tiendaURL;
@property NSMutableArray *invoicePagesArray;

@end

@implementation BWREditInvoiceViewController

@synthesize completeInvoice;
@synthesize rfcTableView;
@synthesize companyTextField;
@synthesize ticketImage;
@synthesize ticketScrollView;
@synthesize rfcActionSheet;
@synthesize fetchedResults;
@synthesize rfcSelected;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get rfc from data base
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RFCInfo"];
    NSSortDescriptor *ordenacionPorNombre = [[NSSortDescriptor alloc] initWithKey:@"rfc" ascending:YES];
    fetchRequest.sortDescriptors = @[ordenacionPorNombre];
    
    NSError *fetchingError = nil;
    fetchedResults = [managedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
    
    //Medidas
    NSInteger widthScreen = self.view.frame.size.width;
    NSInteger heightScreen = self.view.frame.size.height;
    NSInteger height = 44;
    NSInteger padding = 10;
    NSInteger depth = 15;
    NSInteger width = widthScreen-(2*padding);
    
    //TEMPORAL*************************************
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton addTarget:self action:@selector(sendInvoice) forControlEvents:UIControlEventTouchDown];
    [sendButton setTitle:@"Reenviar" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(0, depth+=height+10, widthScreen, height);
    [self.view addSubview:sendButton];
    //*********************************************
    
    //RFC table
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, depth+=height+10, widthScreen, height) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    rfcSelected = completeInvoice.rfc;
    [self.view addSubview:rfcTableView];
    
    //Company TextView
    companyTextField = [[UITextField alloc] initWithFrame:CGRectMake(padding, depth+=height+10, width, height)];
    companyTextField.enabled = NO;
    companyTextField.text = [NSString stringWithFormat:@"Empresa: %@", completeInvoice.company];
    //companyTextField.scrollEnabled = NO;
    [self.view addSubview:companyTextField];
    
    //Image view
    ticketImage = [[UIImageView alloc] initWithFrame:CGRectMake(padding, depth+=height+10, 100, 100.0f)];
    [ticketImage setContentMode:UIViewContentModeScaleToFill];
    ticketImage.image = completeInvoice.image;
    [self.view addSubview:ticketImage];
    
    //Scroll View
    ticketScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, depth+=100+10, widthScreen-10, heightScreen-100)];
    ticketScrollView.contentSize=CGSizeMake(widthScreen,heightScreen);
    ticketScrollView.hidden = NO;
    [self inicializeViewTicketElementsArray];
    [self.view addSubview:ticketScrollView];
    
    //If invoice is not right
    if(![completeInvoice.status isEqualToString:@"Facturada"]){
        //Save Button
        UIBarButtonItem *bt_save = [[UIBarButtonItem alloc] initWithTitle:@"Guardar" style:UIBarButtonItemStylePlain target:self action:@selector(saveInvoiceChanges)];
        self.navigationItem.rightBarButtonItem = bt_save;
    }
    
    self.title = @"Editar Factura";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BWREditInvoiceViewController Sources
-(void)updateInvoice{
    
    for(BWRTicketViewElement *viewElement in completeInvoice.rulesViewElementsArray){
        if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]]){
            viewElement.selectionValue = ((UITextField *)viewElement.viewTicketElement).text;
        }
    }
    
    if([completeInvoice.status isEqualToString:@"Error"]){
        completeInvoice.status = @"Pendiente";
    }
    
    [completeInvoice updateCompleteInvoiceWithRFC:rfcSelected status:completeInvoice.status];
}

-(void)inicializeViewTicketElementsArray{
    
    //Medidas
    NSInteger screenWidth = self.view.frame.size.width;
    NSInteger height = 44;
    NSInteger padding = 10;
    NSInteger depth = 0;
    NSInteger width = screenWidth-(2*padding);
    
    for(BWRTicketViewElement *viewElement in completeInvoice.rulesViewElementsArray){
        [viewElement createViewWithRect:padding y:depth width:width height:height/**[ticketViewElement.valueCampoTicket count]*/ delegate:self];
        ((UITextField *)viewElement.viewTicketElement).text = viewElement.selectionValue;
        
        //Disable editing if invoice is right
        if([completeInvoice.status isEqualToString:@"Facturada"]){
            ((UITextField *)viewElement.viewTicketElement).enabled = NO;
        }
        
        [ticketScrollView addSubview:viewElement.viewTicketElement];
        depth = depth + (height /** [ticketViewElement.valueCampoTicket count]*/) +10;
    }
}

-(void) sendInvoice {
    
    //Update invoice
    [self updateInvoice];
    
    //Go to BWRInvoiceConfirmation
    [self performSegueWithIdentifier:@"ResendingInvoiceSegue" sender:self];
}

-(void) saveInvoiceChanges {
    
    //Update invoice
    [self updateInvoice];
    
    //Go to History
    [self performSegueWithIdentifier:@"returnToHistorySegue" sender:self];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == rfcTableView){
        numberOfRows = 1;
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    //RFC table
    if(tableView == rfcTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RFC"];
        cell.textLabel.text = rfcSelected;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //RFC table
    if(tableView == rfcTableView){
        
        rfcActionSheet = [[UIActionSheet alloc] initWithTitle:@"Seleccionar RFC" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        //Add rfc's like buttons if invoice is not right
        if(![completeInvoice.status isEqualToString:@"Facturada"]){
            for (int index=0; index<[fetchedResults count]; index++) {
                BWRRFCInfo *rfcInfo = [fetchedResults objectAtIndex:index];
                [rfcActionSheet addButtonWithTitle:rfcInfo.rfc];
            }
        }else{
            [rfcActionSheet addButtonWithTitle:completeInvoice.rfc];
        }
        
        [rfcActionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == rfcActionSheet){
        BWRRFCInfo *rfcInfo = [fetchedResults objectAtIndex:buttonIndex];
        rfcSelected = rfcInfo.rfc;
        [rfcTableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"ResendingInvoiceSegue"]){
        BWRInvoiceConfirmationViewController *confirmInvoiceViewController = [segue destinationViewController];
        confirmInvoiceViewController.invoiceAction = 1;
        confirmInvoiceViewController.invoiceImage = completeInvoice.image;
        confirmInvoiceViewController.completeInvoice = completeInvoice;
    }
}

@end
