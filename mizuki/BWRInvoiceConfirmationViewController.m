//
//  BWRInvoiceConfirmationViewController.m
//  mizuki
//
//  Created by Efrén Aguilar on 6/11/14.
//  Copyright (c) 2014 Baware S.A. de C.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "BWRInvoiceConfirmationViewController.h"
#import "WebInvoiceViewController.h"
#import "BWRTicketViewElement.h"
#import "BWRInvoiceTicketPage.h"
#import "BWRRFCInfo.h"
#import "BWRWebConnection.h"
#import "BWRCompleteInvoice.h"
#import "BWRUserPreferences.h"

@interface BWRInvoiceConfirmationViewController ()
@property NSString *tiendaURL;
@property NSMutableArray *invoicePagesArray;
@property NSString *actualRFC;
//Page1
@property UIImageView *invoiceImageView;
//Page2
@property NSMutableArray *ticketViewElementsArray;
@property NSArray *fetchedResults;
@property NSMutableArray *completeStringsArray;
@property UIActionSheet *rfcActionSheet;
@property UITableView *rfcTableView;
@property UITableView *completeTableView;
@property UITextField *empresaTextField;
@property UIScrollView *ticketScrollView;
@property UILabel *rfcLabel;
//Controls
@property UICollectionView *ticketData;
@property UIPageControl *ticketDataPageControl;
@end

@implementation BWRInvoiceConfirmationViewController
@synthesize actualRFC;
@synthesize completeInvoice;
@synthesize invoiceResending;
//Page1
@synthesize invoiceLabel;
@synthesize invoiceText;
@synthesize invoiceImage;
@synthesize invoiceImageView;
//Page2
@synthesize ticketViewElementsArray;
@synthesize rfcActionSheet;
@synthesize rfcTableView;
@synthesize empresaTextField;
@synthesize fetchedResults;
@synthesize completeTableView;
@synthesize completeStringsArray;
@synthesize ticketScrollView;
@synthesize rfcLabel;
//Controls
@synthesize ticketData;
@synthesize ticketDataPageControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Core Data
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RFCInfo"];
    NSSortDescriptor *ordenacionPorNombre = [[NSSortDescriptor alloc] initWithKey:@"rfc" ascending:YES];
    fetchRequest.sortDescriptors = @[ordenacionPorNombre];
    
    NSError *fetchingError = nil;
    fetchedResults = [managedObjectContext executeFetchRequest:fetchRequest error:&fetchingError];
    
    if (!fetchingError) {
        NSLog(@"Recuperación satisfactoria.");
    } else {
        NSLog(@"Error al recuperar.");
    }
    
    //User Defaults
    actualRFC = [BWRUserPreferences getStringValueForKey:@"rfc"];
    
    //Measures
    NSInteger screenWidth = self.view.frame.size.width;
    NSInteger screenHeight = self.view.frame.size.height;
    NSInteger height = 44;
    NSInteger padding = 10;
    NSInteger depth = 0;
    NSInteger width = screenWidth-(2*padding);
    
    //PAGE 1 --------------------------------------------------------------------------------
    //RFC table
    rfcLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, depth, width, height)];
    rfcLabel.text = @"RFC";
    
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, depth+=height, screenWidth, height) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    
    //Company TextField
    empresaTextField = [[UITextField alloc] initWithFrame:CGRectMake(padding, depth+=height+10, width, height)];
    empresaTextField.borderStyle = UITextBorderStyleRoundedRect;
    empresaTextField.placeholder = @"Empresa";
    empresaTextField.delegate = self;
   
    //Autocomplete table
    completeTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, depth+=height, screenWidth, height) style:UITableViewStylePlain];
    completeTableView.delegate = self;
    completeTableView.dataSource = self;
    completeTableView.scrollEnabled = YES;
    completeTableView.hidden = YES;
    
    //Arrays
    completeStringsArray = [[NSMutableArray alloc] init];
    ticketViewElementsArray = [[NSMutableArray alloc] init];
    
    //Scroll View
    ticketScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 160, screenWidth-10, screenHeight-100)];
    ticketScrollView.contentSize=CGSizeMake(screenWidth,screenHeight);
    ticketScrollView.hidden = NO;
    
    
    
    //PAGE 2 --------------------------------------------------------------------------------
    //Ticket image
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        invoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, self.view.frame.size.width, 200.0f)];
        invoiceLabel = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 260.0f, self.view.frame.size.width - 20, self.view.frame.size.height - 260)];
        [invoiceImageView setContentMode:UIViewContentModeScaleToFill];
    }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
            invoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(500.0f, 60.0f, 480.0f, self.view.frame.size.height - 80.0f) ];
            invoiceLabel = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 480.0f, self.view.frame.size.height - 80.0f)];
            [invoiceImageView setContentMode:UIViewContentModeScaleAspectFit];
        }else{
            invoiceLabel = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 210.0f, 480.0f, 400.0f)];
            invoiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 50.0f, 480.0f, 200.0f)];
            [invoiceImageView setContentMode:UIViewContentModeScaleToFill];
        }
        
    }
    invoiceImageView.image = invoiceImage;
    
    //Tesseract result
    invoiceLabel.editable = NO;
    invoiceLabel.scrollEnabled = YES;
    invoiceLabel.text = @"Procesando";
    
    //CONTROL ------------------------------------------------------------------------------
    UICollectionViewFlowLayout *ticketDataLayout = [[UICollectionViewFlowLayout alloc] init];
    ticketDataLayout.minimumLineSpacing = 0.0;
    ticketDataLayout.itemSize = CGSizeMake(screenWidth-10, screenHeight-100);
    ticketDataLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    ticketData = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-60) collectionViewLayout:ticketDataLayout];
    ticketData.dataSource = self;
    ticketData.delegate = self;
    ticketData.backgroundColor = [UIColor whiteColor];
    ticketData.pagingEnabled = YES;
    ticketData.showsHorizontalScrollIndicator = NO;
    [ticketData registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ticketCell"];
    [self.view addSubview:ticketData];

    
    ticketDataPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, screenHeight-70, screenWidth, 20)];
    ticketDataPageControl.backgroundColor = [UIColor whiteColor];
    ticketDataPageControl.userInteractionEnabled = NO;
    ticketDataPageControl.currentPageIndicatorTintColor = [UIColor redColor];
    ticketDataPageControl.numberOfPages = 2;
    ticketDataPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [self.view addSubview:ticketDataPageControl];
    
    //Send Button
    UIBarButtonItem *bt_enviar = [[UIBarButtonItem alloc] initWithTitle:@"Enviar" style:UIBarButtonItemStylePlain target:self action:@selector(goToWebview)];
    self.navigationItem.rightBarButtonItem = bt_enviar;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"Confirmación de factura";
    
    //If resending invoice
    if(invoiceResending){
        [self sendInvoiceDirectly];
    }else{
        [self performSelectorInBackground:@selector(processImage) withObject:nil]; // Modificar por GCD
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"Enter in viewWillTransitionToSize");

}

#pragma mark - ConfirmationViewControllerSources

- (void) processRecognition{
    while ([invoiceLabel.text isEqualToString:@"Procesando"]);
    
    [self performSelectorOnMainThread:@selector(invoiceDataRecognition) withObject:nil waitUntilDone:YES];
}


- (void) invoiceDataRecognition {
    
    for (BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]]) {
            if([viewElement.dataSource isEqualToString:@"ticket_info"]){
                [viewElement findTicketFieldInOCR:invoiceLabel.text];
            }
        }
    }
}

-(void)processImage{
    BWRProcessImage *processImage = [[BWRProcessImage alloc] initWithImage:invoiceImageView.image];
    NSString *invoiceTextAux = [processImage processRecognitionOCR];
    invoiceImageView.image = processImage.processImage;
    
    [self performSelectorOnMainThread:@selector(buildInterfaceFromText:) withObject:invoiceTextAux waitUntilDone:NO];
}

-(void)buildInterfaceFromText:(NSString *)text
{
    self.invoiceText = text;
    invoiceLabel.text = text;
}

- (BOOL) validationInvoiceData{
    
    for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]]) {
            if([viewElement.dataSource isEqualToString:@"ticket_info"]){
                if(![viewElement validateFieldValueWithTicketMask]){
                    return FALSE;
                }
            }
        }
    }
    return TRUE;
}

- (void) updateViewsWhitSelectedRFC {
    //Get rfc element from arreglo
    BWRRFCInfo *rfcActual;
    for (BWRRFCInfo *rfcInfo in fetchedResults){
        if ([actualRFC isEqualToString:rfcInfo.rfc]) {
            rfcActual = rfcInfo;
            break;
        }
    }
   
    //Put field in visual element
    for (BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if([viewElement.dataSource isEqualToString:@"user_info"]){
            viewElement.selectionValue = [rfcActual getFormValueWhitProperty:viewElement.ticketField];
            NSLog(@"Valor de %@ es %@", viewElement.ticketField, viewElement.selectionValue);
        }
    }
}

-(void)sendInvoiceDirectly{
    
    //Get id company
    NSArray *stringCompanyArray = [BWRWebConnection companyListWithSubstring:completeInvoice.company];
    NSDictionary *companyDictionary = [stringCompanyArray objectAtIndex:0];
    int idCompany = [[companyDictionary valueForKey:@"id"] integerValue];
    
    //Get url, pagesArray and ticketViewElementsArray
    [self createTicketViewElemetsWithId:idCompany];
    
    //Change actual rfc and invoice Label
    actualRFC = completeInvoice.rfc;
    invoiceLabel.text = completeInvoice.resultOCR;
    
    //
    for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]] && [viewElement.dataSource isEqualToString:@"ticket_info"]) {
            
            //Find ticket field
            for(BWRTicketViewElement *rule in completeInvoice.rulesViewElementsArray){
                if([viewElement.ticketField isEqualToString:rule.ticketField]){
                    ((UITextField *)viewElement.viewTicketElement).text = rule.selectionValue;
                    viewElement.selectionValue = rule.selectionValue;
                    break;
                }
            }
            
        }
    }
    
    //Resend invoice
    [self goToWebview];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == rfcTableView){
        numberOfRows = 1;
    }else if(tableView == completeTableView){
        numberOfRows = [completeStringsArray count];
    }else{
        //find tableView
        BWRTicketViewElement *ticketElement = [ticketViewElementsArray objectAtIndex:[self findTableViewTicket:tableView]];
        numberOfRows = [ticketElement.ticketFieldValue count];
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    //RFC table
    if(tableView == rfcTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RFC"];
        cell.textLabel.text = actualRFC;
        
    //Autocomplete table
    }else if (tableView == completeTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Complete"];
        cell.textLabel.text = [[completeStringsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
    //ViewElement table
    }else{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Combobox"];
        BWRTicketViewElement *ticketElement = [ticketViewElementsArray objectAtIndex:[self findTableViewTicket:tableView]];
        cell.textLabel.text = [ticketElement.ticketFieldValue objectAtIndex:indexPath.row];
        
        if([cell.textLabel.text isEqualToString:ticketElement.selectionValue]){
            cell.textLabel.textColor = [UIColor blueColor];
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //RFC table
    if(tableView == rfcTableView){

        rfcActionSheet = [[UIActionSheet alloc] initWithTitle:@"Seleccionar RFC" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (int index=0; index<[fetchedResults count]; index++) {
            BWRRFCInfo *rfcInfo = [fetchedResults objectAtIndex:index];
            [rfcActionSheet addButtonWithTitle:rfcInfo.rfc];
        }
            
        [rfcActionSheet showInView:self.view];
    
    //Autocomplete table
    }else if(tableView == completeTableView){
        empresaTextField.text = [[completeStringsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        completeTableView.hidden = YES;
        [self createTicketViewElemetsWithId: [[[completeStringsArray objectAtIndex:indexPath.row] valueForKey:@"id"] intValue]];
        [self performSelectorInBackground:@selector(processRecognition) withObject:nil];
    
    //ViewElement table
    }else{
        BWRTicketViewElement *ticketElement = [ticketViewElementsArray objectAtIndex:[self findTableViewTicket:tableView]];
        ticketElement.selectionValue = [ticketElement.ticketFieldValue objectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

-(NSInteger) findTableViewTicket: (UITableView *)tableView {
    NSInteger index = 0;
    for(BWRTicketViewElement *ticketElement in ticketViewElementsArray){
        if(ticketElement.viewTicketElement == tableView){
            break;
        }
        index++;
    }
    return index;
}


-(void)createTicketViewElemetsWithId: (NSInteger)identificador {
    
    //Measures
    NSInteger heigth = 44;
    NSInteger padding = 10;
    NSInteger depth = 0;
    NSInteger width = self.view.frame.size.width-(2*padding);
    
    //Get company dictionary
    NSDictionary *companyDataDictionary = [BWRWebConnection viewElementsWithCompany:identificador];
    NSArray *rulesBlockArray = [companyDataDictionary valueForKey:@"rules_block"];
    _tiendaURL = [companyDataDictionary valueForKey:@"url"];
    
    _invoicePagesArray = [[NSMutableArray alloc] init];
    ticketScrollView.hidden=NO;
    
    //Recorrer rules_block
    for(NSDictionary *pageDictionary in rulesBlockArray){
        
        BWRInvoiceTicketPage *invoicePage = [[BWRInvoiceTicketPage alloc] initWithData:[pageDictionary valueForKey:@"name"] pageNumber:[pageDictionary valueForKey:@"page_num"]];
        NSArray *rulesArray = [pageDictionary valueForKey:@"rules"];
            
        //Recorrer rules
        for(NSDictionary *ticketElement in rulesArray){
            BWRTicketViewElement *ticketViewElement = [[BWRTicketViewElement alloc] initWithDictionary:ticketElement];
            
            //User data
            if([ticketViewElement.dataSource isEqualToString:@"user_info"]){
                [ticketViewElementsArray addObject:ticketViewElement];
                
            //Ticket data
            }else if([ticketViewElement.dataSource isEqualToString:@"ticket_info"]){
                [ticketViewElement createViewWithRect:padding y:depth width:width height:heigth/**[ticketViewElement.valueCampoTicket count]*/ delegate:self];
                [ticketViewElementsArray addObject:ticketViewElement];
                [ticketScrollView addSubview:ticketViewElement.viewTicketElement];
                depth = depth + (heigth /** [ticketViewElement.valueCampoTicket count]*/) +10;
            }
            
            [invoicePage.rules addObject:ticketViewElement];
            
        }
        [_invoicePagesArray addObject:invoicePage];
        
    }
    
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == rfcActionSheet){
        //show all rfc's
        BWRRFCInfo *rfcInfo = [fetchedResults objectAtIndex:buttonIndex];
        actualRFC = rfcInfo.rfc;
        [rfcTableView reloadData];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == empresaTextField){
        completeTableView.hidden = NO;
    
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
    }
    return YES;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {

    NSMutableArray *temporalArray = [[NSMutableArray alloc] initWithArray:completeStringsArray];
    //If there are elements in array
    if([completeStringsArray count]!=0) {
        [completeStringsArray removeAllObjects];
    }
    
    //Delate elements from scrollview
    NSArray *subviews = [ticketScrollView subviews];
    if(subviews!=nil){
        for (UIView *view in subviews)
            [view removeFromSuperview];
        [ticketViewElementsArray removeAllObjects];
    }
    ticketScrollView.hidden = YES;

    //If substring length is equals to 3
    if ([substring length]==3) {
        //Get strings array to complete
        completeStringsArray = [BWRWebConnection companyListWithSubstring:substring];
        //Resize array
        if([completeStringsArray count]!=0){
            [completeTableView setFrame:CGRectMake(0, completeTableView.frame.origin.y, completeTableView.frame.size.width, 44*[completeStringsArray count])];
            [completeTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * [completeStringsArray count]))];
        }
    }
    
    //If substring length is higher than 3
    else if ([substring length]>3){
        for(NSDictionary *curDictionary in temporalArray) {
            NSString *curString = [curDictionary valueForKey:@"name"];
            NSRange substringRange = [curString rangeOfString:substring];
            if (substringRange.location != NSNotFound) {
                [completeStringsArray addObject:curDictionary];
            }
        }
        //Resize array
        if([completeStringsArray count]!=0){
            [completeTableView setFrame:CGRectMake(0, completeTableView.frame.origin.y, completeTableView.frame.size.width, 44*[completeStringsArray count])];
            [completeTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * [completeStringsArray count]))];
        //Save previous strings
        }else{
            completeStringsArray = temporalArray;
            //completeTableView.hidden =YES;
        }
    }
    
    //If substring length is less than 3
    else{
        completeTableView.hidden = YES;
    }
    //Reload table data
    [completeTableView reloadData];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Collection view data source
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = nil;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ticketCell" forIndexPath:indexPath];
    
    //Page 1
    if(indexPath.row==0){
        [cell.contentView addSubview:rfcLabel];
        [cell.contentView addSubview:rfcTableView];
        [cell.contentView addSubview:empresaTextField];
        [cell.contentView addSubview:completeTableView];
        [cell.contentView addSubview:ticketScrollView];
    //Page 2
    }else{
        [cell.contentView addSubview:invoiceImageView];
        [cell.contentView addSubview:invoiceLabel];
    }
    
    return cell;
}

#pragma mark - Navegation
- (void)goToWebview{
    
    if([self validationInvoiceData] && !([invoiceLabel.text isEqualToString:@"Procesando"])){
        
        //If don't resend invoice
        if(!invoiceResending){
            
            //Put TextField text in selectionValue
            for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
                if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]] && [viewElement.dataSource isEqualToString:@"ticket_info"]) {
                    
                    viewElement.selectionValue = ((UITextField *)viewElement.viewTicketElement).text;
                    
                }
            }
            
            //update completeInvoice with new invoice
            completeInvoice = [self getNewCompleteInvoice];
            if(completeInvoice==nil){
                return;
            }
        }
        
        //Put rfc user_info fields
        [self updateViewsWhitSelectedRFC];
        
        [self performSegueWithIdentifier:@"invoiceWebViewSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceWebViewSegue"]){
        WebInvoiceViewController *webViewInvoiceData = [segue destinationViewController];
        webViewInvoiceData.invoicePagesArray = _invoicePagesArray;
        webViewInvoiceData.companyURL = [NSURL URLWithString:_tiendaURL];
        webViewInvoiceData.actualPage = 0;
        webViewInvoiceData.completeInvoice=completeInvoice;
    }
}

-(BWRCompleteInvoice *) getNewCompleteInvoice{
    
    //Get view elements array
    NSMutableArray *viewsArray= [[NSMutableArray alloc] init];
    for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if ([viewElement.dataSource isEqualToString:@"ticket_info"]) {
            [viewsArray addObject:viewElement];
        }
    }
    
    //Create new invoice
    BWRCompleteInvoice *newCompleteInvoice=[[BWRCompleteInvoice alloc] initWithData:viewsArray rfc:actualRFC ticketImage:invoiceImage stringOCR:invoiceLabel.text company:empresaTextField.text];
    
    //Add invoice to data base
    if([newCompleteInvoice addCompleteInvoiceWithStatus:@"Pendiente"]){
        NSLog(@"SE REALIZO EL ADD CORRECTAMENTE: %@", completeInvoice.idInvoice);
        return newCompleteInvoice;
    }else{
        NSLog(@"ERROR EN EL ADD");
        return nil;
    }
}

@end
