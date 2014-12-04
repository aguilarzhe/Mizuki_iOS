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
#import "WebInvoiceViewController.h"

@interface BWREditInvoiceViewController ()

@property UITableView *rfcTableView;
@property UITextField *companyTextField;
@property UIImageView *ticketImage;
@property UIScrollView *ticketScrollView;
@property UIActionSheet *rfcActionSheet;
@property NSArray *fetchedResults;
@property NSString *rfcSelected;
//Send invoice
@property NSString *tiendaURL;
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
    [sendButton setTitle:NSLocalizedString(@"Reenviar",nil) forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(0, depth+=height+10, widthScreen, height);
    [self.view addSubview:sendButton];
    //*********************************************
    
    //If invoice is not right
    if(![completeInvoice.status isEqualToString:@"Facturada"]){
        //Get rfc from data base
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RFCInfo"];
        NSSortDescriptor *ordenacionPorNombre = [[NSSortDescriptor alloc] initWithKey:@"rfc" ascending:YES];
        fetchRequest.sortDescriptors = @[ordenacionPorNombre];
        
        NSError *fetchingError = nil;
        fetchedResults = [managedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
        
        //Save Button
        UIBarButtonItem *bt_save = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Guardar",nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveInvoiceChanges)];
        self.navigationItem.rightBarButtonItem = bt_save;
    }
    
    //If invoce is right
    else{
        sendButton.enabled = NO;
    }
    
    //RFC table
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, depth+=height+10, widthScreen, height*2) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    rfcSelected = completeInvoice.rfc;
    [self.view addSubview:rfcTableView];
    
    //Company TextView
    companyTextField = [[UITextField alloc] initWithFrame:CGRectMake(padding, depth+=height+10, width, height)];
    companyTextField.enabled = NO;
    companyTextField.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Empresa",nil), completeInvoice.company];
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
    
    self.title = NSLocalizedString(@"Editar Factura",nil);
    
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

-(bool) prepareForResendInvoice {
    
    //Get id company
    NSArray *stringCompanyArray = [BWRWebConnection companyListWithSubstring:completeInvoice.company];
    int idCompany;
    if(stringCompanyArray!=nil){
        //Get data company
        NSDictionary *companyDictionary = [stringCompanyArray objectAtIndex:0];
        idCompany = [[companyDictionary valueForKey:@"id"] integerValue];
    }
    
    //If can't get company identifier
    else{
        NSLog(@"No se pudo obtener el id de la compañia");
        return FALSE;
    }
    
    //Get RFC data
    BWRRFCInfo *rfcData = [self getRFCInfo];
    
    //Get company dictionary
    NSDictionary *companyDataDictionary = [BWRWebConnection viewElementsWithCompany:idCompany];
    if(companyDataDictionary!=nil){
        
        NSArray *rulesBlockArray = [companyDataDictionary valueForKey:@"rules_block"];
        _tiendaURL = [companyDataDictionary valueForKey:@"url"];
        _invoicePagesArray = [[NSMutableArray alloc] init];
        
        //Recorrer rules_block
        int index = 0;
        for(NSDictionary *pageDictionary in rulesBlockArray){
            
            BWRInvoiceTicketPage *invoicePage = [[BWRInvoiceTicketPage alloc] initWithData:[pageDictionary valueForKey:@"name"] pageNumber:[pageDictionary valueForKey:@"page_num"]];
            NSArray *rulesArray = [pageDictionary valueForKey:@"rules"];
            
            //Recorrer rules
            for(NSDictionary *ticketElement in rulesArray){
                BWRTicketViewElement *ticketViewElement = [[BWRTicketViewElement alloc] initWithDictionary:ticketElement];
                
                //User data
                if([ticketViewElement.dataSource isEqualToString:@"user_info"]){
                    ticketViewElement.selectionValue = [rfcData getFormValueWhitProperty:ticketViewElement.ticketField];
                    
                //Ticket data
                }else if([ticketViewElement.dataSource isEqualToString:@"ticket_info"]){
                    ticketViewElement.selectionValue = ((BWRTicketViewElement *)[completeInvoice.rulesViewElementsArray objectAtIndex:index]).selectionValue;
                    ticketViewElement.viewTicketElement = ((BWRTicketViewElement *)[completeInvoice.rulesViewElementsArray objectAtIndex:index]).viewTicketElement;
                    index++;
                    
                    //Validate ticketView
                    if(![ticketViewElement validateFieldValueWithTicketMask]){
                        return FALSE;
                    }
                }
                
                [invoicePage.rules addObject:ticketViewElement];
                
            }
            [_invoicePagesArray addObject:invoicePage];
            
        }
        
    }
    
    //If can't get company dictionary
    else{
        NSLog(@"No se pudo obtener los dostos de la compañia");
        return FALSE;
    }
    
    return TRUE;
    
}

-(BWRRFCInfo *) getRFCInfo{
    
    //Get rfc element from array
    BWRRFCInfo *rfcActual;
    for (BWRRFCInfo *rfcInfo in fetchedResults){
        if ([completeInvoice.rfc isEqualToString:rfcInfo.rfc]) {
            rfcActual = rfcInfo;
            break;
        }
    }
    
    return rfcActual;
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
            [rfcActionSheet showInView:self.view];
        }
        
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

#pragma mark - Navigation

-(void) sendInvoice {
    
    //Update invoice
    completeInvoice.status = @"Process";
    [self updateInvoice];
    
    //Prepare data for resend
    if([self prepareForResendInvoice]){
        //Resend invoice
        [self performSegueWithIdentifier:@"ResendInvoiceSegue" sender:self];
    }
    //Error ocurred in prepare data for resend
    else{
        completeInvoice.status = @"Pendiente";
        [self updateInvoice];
    }
}

-(void) saveInvoiceChanges {
    
    //Update invoice
    [self updateInvoice];
    
    //Go to History
    [self performSegueWithIdentifier:@"returnToHistorySegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"ResendInvoiceSegue"]){
        WebInvoiceViewController *webViewInvoiceData = [segue destinationViewController];
        webViewInvoiceData.invoicePagesArray = _invoicePagesArray;
        webViewInvoiceData.companyURL = [NSURL URLWithString: _tiendaURL];
        webViewInvoiceData.actualPage = 0;
        webViewInvoiceData.completeInvoice=completeInvoice;
    }
}

@end
