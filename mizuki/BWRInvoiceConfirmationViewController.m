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
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    actualRFC = [userDefaults valueForKey:@"rfc"];
    
    //Medidas
    NSInteger anchoPantalla = self.view.frame.size.width;
    NSInteger largoPantalla = self.view.frame.size.height;
    NSInteger ALTO = 44;
    NSInteger PADING = 10;
    NSInteger espaciado = 0;
    NSInteger ANCHO_LARGO = anchoPantalla-(2*PADING);
    
    //PAGE 1 --------------------------------------------------------------------------------
    //Tabla RFC
    rfcLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADING, espaciado, ANCHO_LARGO, ALTO)];
    rfcLabel.text = @"RFC";
    
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, espaciado+=ALTO, anchoPantalla, ALTO) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    
    //TextField de la empresa
    empresaTextField = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=ALTO+10, ANCHO_LARGO, ALTO)];
    empresaTextField.borderStyle = UITextBorderStyleRoundedRect;
    empresaTextField.placeholder = @"Empresa";
    empresaTextField.delegate = self;
   
    //Tabla para autocomplete
    completeTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, espaciado+=ALTO, anchoPantalla, ALTO) style:UITableViewStylePlain];
    completeTableView.delegate = self;
    completeTableView.dataSource = self;
    completeTableView.scrollEnabled = YES;
    completeTableView.hidden = YES;
    
    //Array
    completeStringsArray = [[NSMutableArray alloc] init];
    ticketViewElementsArray = [[NSMutableArray alloc] init];
    
    //Scroll View
    ticketScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 160, anchoPantalla-10, largoPantalla-100)];
    ticketScrollView.contentSize=CGSizeMake(anchoPantalla,largoPantalla);
    ticketScrollView.hidden = NO;
    
    
    
    //PAGE 2 --------------------------------------------------------------------------------
    //Imagen del ticket
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
    
    //Resultado tesseract
    invoiceLabel.editable = NO;
    invoiceLabel.scrollEnabled = YES;
    invoiceLabel.text = @"Procesando";
    
    //CONTROL ------------------------------------------------------------------------------
    UICollectionViewFlowLayout *ticketDataLayout = [[UICollectionViewFlowLayout alloc] init];
    ticketDataLayout.minimumLineSpacing = 0.0;
    ticketDataLayout.itemSize = CGSizeMake(anchoPantalla-10, largoPantalla-100);
    ticketDataLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    ticketData = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, anchoPantalla, largoPantalla-60) collectionViewLayout:ticketDataLayout];
    ticketData.dataSource = self;
    ticketData.delegate = self;
    ticketData.backgroundColor = [UIColor whiteColor];
    ticketData.pagingEnabled = YES;
    ticketData.showsHorizontalScrollIndicator = NO;
    [ticketData registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ticketCell"];
    [self.view addSubview:ticketData];

    
    ticketDataPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, largoPantalla-70, anchoPantalla, 20)];
    ticketDataPageControl.backgroundColor = [UIColor whiteColor];
    ticketDataPageControl.userInteractionEnabled = NO;
    ticketDataPageControl.currentPageIndicatorTintColor = [UIColor redColor];
    ticketDataPageControl.numberOfPages = 2;
    ticketDataPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [self.view addSubview:ticketDataPageControl];
    
    //Boton enviar
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
    //Obtener elemento rfc del arreglo
    BWRRFCInfo *rfcActual;
    for (BWRRFCInfo *rfcInfo in fetchedResults){
        if ([actualRFC isEqualToString:rfcInfo.rfc]) {
            rfcActual = rfcInfo;
            break;
        }
    }
   
    //Colocar campo en elemento visual
    for (BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if([viewElement.dataSource isEqualToString:@"user_info"]){
            viewElement.selectionValue = [rfcActual getFormValueWhitProperty:viewElement.ticketField];
            NSLog(@"Valor de %@ es %@", viewElement.ticketField, viewElement.selectionValue);
        }
    }
}

//Reenviar factura
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
        //Buscando tableView
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
    
    //Medidas
    NSInteger anchoPantalla = self.view.frame.size.width;
    NSInteger ALTO = 44;
    NSInteger PADING = 10;
    NSInteger espaciado = 0;
    NSInteger ANCHO_LARGO = anchoPantalla-(2*PADING);
    
    //Obtener diccionario
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
            
            //Dato de usuario
            if([ticketViewElement.dataSource isEqualToString:@"user_info"]){
                [ticketViewElementsArray addObject:ticketViewElement];
                
            //Dato de ticket
            }else if([ticketViewElement.dataSource isEqualToString:@"ticket_info"]){
                [ticketViewElement createViewWithRect:PADING y:espaciado width:ANCHO_LARGO height:ALTO/**[ticketViewElement.valueCampoTicket count]*/ delegate:self];
                [ticketViewElementsArray addObject:ticketViewElement];
                [ticketScrollView addSubview:ticketViewElement.viewTicketElement];
                espaciado = espaciado + (ALTO /** [ticketViewElement.valueCampoTicket count]*/) +10;
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
    if([completeStringsArray count]!=0) {
        NSLog(@"JUSTO ANTES DEL ERROR elementos: %d arreglo: %@", [completeStringsArray count], completeStringsArray);
        [completeStringsArray removeAllObjects];
    }
    
    //Eliminar elementos del scrollview
    NSArray *subviews = [ticketScrollView subviews];
    if(subviews!=nil){
        for (UIView *view in subviews)
            [view removeFromSuperview];
        [ticketViewElementsArray removeAllObjects];
    }
    ticketScrollView.hidden = YES;

    if ([substring length]==3) {
        //Solicitar arreglo de strings
        completeStringsArray = [BWRWebConnection companyListWithSubstring:substring];
    
        if([completeStringsArray count]!=0){
            [completeTableView setFrame:CGRectMake(0, completeTableView.frame.origin.y, completeTableView.frame.size.width, 44*[completeStringsArray count])];
            [completeTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * [completeStringsArray count]))];
        }
    }
    
    else if ([substring length]>3){
        for(NSDictionary *curDictionary in temporalArray) {
            NSString *curString = [curDictionary valueForKey:@"name"];
            NSRange substringRange = [curString rangeOfString:substring];
            if (substringRange.location != NSNotFound) {
                [completeStringsArray addObject:curDictionary];
            }
        }
        
        if([completeStringsArray count]!=0){
            [completeTableView setFrame:CGRectMake(0, completeTableView.frame.origin.y, completeTableView.frame.size.width, 44*[completeStringsArray count])];
            [completeTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * [completeStringsArray count]))];
        }else{
            completeStringsArray = temporalArray;
            //completeTableView.hidden =YES;
        }
    }
    
    else{
        completeTableView.hidden = YES;
    }
    
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
    
    if(indexPath.row==0){
        [cell.contentView addSubview:rfcLabel];
        [cell.contentView addSubview:rfcTableView];
        [cell.contentView addSubview:empresaTextField];
        [cell.contentView addSubview:completeTableView];
        [cell.contentView addSubview:ticketScrollView];
    }else{
        [cell.contentView addSubview:invoiceImageView];
        [cell.contentView addSubview:invoiceLabel];
    }
    
    return cell;
}

#pragma mark - Navegation
- (void)goToWebview{
    
    if([self validationInvoiceData] && !([invoiceLabel.text isEqualToString:@"Procesando"])){
        
        //If no resending invoice
        if(!invoiceResending){
            
            //Colocar el texto del text field en el campo selectionValue
            for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
                if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]] && [viewElement.dataSource isEqualToString:@"ticket_info"]) {
                    
                    viewElement.selectionValue = ((UITextField *)viewElement.viewTicketElement).text;
                    
                }
            }
        }
        
        //Colocar los campos del rfc user_info
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
        
        if(invoiceResending){
            webViewInvoiceData.completeInvoice=completeInvoice;
        }else{
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
            NSString *rfc = [userDefaults valueForKey:@"rfc"];
            NSMutableArray *viewsArray= [[NSMutableArray alloc] init];
            for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
                if ([viewElement.dataSource isEqualToString:@"ticket_info"]) {
                    [viewsArray addObject:viewElement];
                }
            }
            NSLog (@"ARRAY %@", viewsArray);
            
            webViewInvoiceData.completeInvoice=[[BWRCompleteInvoice alloc] initWithData:viewsArray rfc:rfc ticketImage:invoiceImage stringOCR:invoiceLabel.text company:empresaTextField.text];
        }
        
    }
}



@end
