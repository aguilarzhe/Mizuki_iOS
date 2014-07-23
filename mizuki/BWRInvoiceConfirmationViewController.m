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
#import "WevInvoiceViewController.h"
#import "BWRTicketViewElement.h"
#import "BWRRFCInfo.h"

@interface BWRInvoiceConfirmationViewController ()
//Page1
@property UIImageView *invoiceImageView;
//Page2
@property NSMutableArray *ticketViewElementsArray;
@property NSString *tiendaURL;
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
    ticketScrollView.hidden = YES;
    
    
    
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
    [self performSelectorInBackground:@selector(processImage) withObject:nil]; // Modificar por GCD
     
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

-(void)processImage{
    BWRProcessImage *processImage = [[BWRProcessImage alloc] initWithImage:invoiceImageView.image];
    NSString *invoiceTextAux = [processImage processRecognitionOCR];
    
    [self performSelectorOnMainThread:@selector(buildInterfaceFromText:) withObject:invoiceTextAux waitUntilDone:NO];
}

-(void)buildInterfaceFromText:(NSString *)text
{
    self.invoiceText = text;
    invoiceLabel.text = text;
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
        NSInteger index = 0;
        for(BWRTicketViewElement *ticketElement in ticketViewElementsArray){
            if(ticketElement.viewTicketElement == tableView){
                break;
            }
            index++;
        }
        BWRTicketViewElement *ticketElement = [ticketViewElementsArray objectAtIndex:index];
        numberOfRows = [ticketElement.valueCampoTicket count];
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if(tableView == rfcTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RFC"];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        cell.textLabel.text = [userDefaults valueForKey:@"rfc"];
    }else if (tableView == completeTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Complete"];
        cell.textLabel.text = [completeStringsArray objectAtIndex:indexPath.row];
    }else{
        //Buscando tableView
        NSInteger index = 0;
        for(BWRTicketViewElement *ticketElement in ticketViewElementsArray){
            if(ticketElement.viewTicketElement == tableView){
                break;
            }
            index++;
        }
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@%d",@"Combobox",index]];
        BWRTicketViewElement *ticketElement = [ticketViewElementsArray objectAtIndex:index];
        cell.textLabel.text = [ticketElement.valueCampoTicket objectAtIndex:indexPath.row];
        
        if([cell.textLabel.text isEqualToString:ticketElement.selectionValue]){
            cell.textLabel.textColor = [UIColor blueColor];
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == rfcTableView){

        rfcActionSheet = [[UIActionSheet alloc] initWithTitle:@"Seleccionar RFC" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (int index=0; index<[fetchedResults count]; index++) {
            BWRRFCInfo *rfcInfo = [fetchedResults objectAtIndex:index];
            [rfcActionSheet addButtonWithTitle:rfcInfo.rfc];
        }
            
        [rfcActionSheet showInView:self.view];
            
    }else if(tableView == completeTableView){
        empresaTextField.text = [completeStringsArray objectAtIndex:indexPath.row];
        
        completeTableView.hidden = YES;
        [self createTicketViewElemetsWhitDictionary];
        [self performSelectorInBackground:@selector(processRecognition) withObject:nil];
        
    }else{
        //Buscando tableView
        NSInteger index = 0;
        for(BWRTicketViewElement *ticketElement in ticketViewElementsArray){
            if(ticketElement.viewTicketElement == tableView){
                break;
            }
            index++;
        }
        BWRTicketViewElement *ticketElement = [ticketViewElementsArray objectAtIndex:index];
        ticketElement.selectionValue = [ticketElement.valueCampoTicket objectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}


-(void)createTicketViewElemetsWhitDictionary {
    
    //Medidas
    NSInteger anchoPantalla = self.view.frame.size.width;
    NSInteger ALTO = 44;
    NSInteger PADING = 10;
    NSInteger espaciado = 0;
    NSInteger ANCHO_LARGO = anchoPantalla-(2*PADING);
    
    //Obtener diccionario
    _tiendaURL = @"https://alsea.interfactura.com/RegistroDocumento.aspx?opc=Starbucks";
    NSDictionary *elementsDictionary = @{@"reglas": @[
                                                 @{
                                                     @"campo_ticket": @"RFC",
                                                     @"mascara_ticket": @".*",
                                                     @"campo_formulario": @"ctl00_Main_RegistroClienteTicket1_txtRFC",
                                                     @"tipo_campo_formulario": @"textbox",
                                                     @"value_campo_ticket": @[@"rfc"],
                                                      @"data_source": @"userInfo"
                                                     },
                                                 
                                                 /*@{
                                                     @"campo_ticket": @"string",
                                                     @"mascara_ticket": @"string",
                                                     @"campo_formulario": @"string",
                                                     @"tipo_campo_formulario": @"combobox",
                                                     @"value_campo_ticket": @[@"Hola",@"Adios",@"Que tal"],
                                                     @"data_source": @"ticketInfo"
                                                     },*/
                                                 
                                                 @{
                                                     @"campo_ticket": @"Ticket : \\d{9}",
                                                     @"mascara_ticket": @"\\d{9}",
                                                     @"campo_formulario": @"ctl00_Main_RegistroClienteTicket1_txtTicket",
                                                     @"tipo_campo_formulario": @"textbox",
                                                     @"value_campo_ticket": @[@"Ticket"],
                                                     @"data_source": @"ticketInfo"
                                                     },
                                                 
                                                 @{
                                                     @"campo_ticket": @"Tienda : \\d{5}",
                                                     @"mascara_ticket": @"\\d{5}",
                                                     @"campo_formulario": @"ctl00_Main_RegistroClienteTicket1_txtTienda",
                                                     @"tipo_campo_formulario": @"textbox",
                                                     @"value_campo_ticket": @[@"Tienda"],
                                                     @"data_source": @"ticketInfo"
                                                     },
                                                 
                                                 @{
                                                     @"campo_ticket": @"Fecha : \\d{2}-\\d{2}-\\d{4}",
                                                     @"mascara_ticket": @"\\d{2}-\\d{2}-\\d{4}",
                                                     @"campo_formulario": @"ctl00_Main_RegistroClienteTicket1_txtDate",
                                                     @"tipo_campo_formulario": @"textbox",
                                                     @"value_campo_ticket": @[@"Fecha"],
                                                     @"data_source": @"ticketInfo"
                                                     }
                                                 ]};
    NSArray *regrasArray = [[NSArray alloc] initWithArray:[elementsDictionary valueForKey:@"reglas"]];
    ticketScrollView.hidden=NO;
    
    for(NSDictionary *ticketElement in regrasArray){
        BWRTicketViewElement *ticketViewElement = [[BWRTicketViewElement alloc] initWithDictionary:ticketElement];
        [ticketViewElement createViewWithRect:PADING y:espaciado width:ANCHO_LARGO height:ALTO*[ticketViewElement.valueCampoTicket count] delegate:self];
        [ticketViewElementsArray addObject:ticketViewElement];
        [ticketScrollView addSubview:ticketViewElement.viewTicketElement];
        espaciado = espaciado + (ALTO * [ticketViewElement.valueCampoTicket count]) +10;
    }
    
    [self updateViewsWhitSelectedRFC];
    
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == rfcActionSheet){
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        BWRRFCInfo *rfcInfo = [fetchedResults objectAtIndex:buttonIndex];
        [userDefaults setValue:rfcInfo.rfc forKey:@"rfc"];
        [rfcTableView reloadData];
        [self updateViewsWhitSelectedRFC];
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
    [completeStringsArray removeAllObjects];
    
    //Eliminar elementos del scrollview
    NSArray *subviews = [ticketScrollView subviews];
    if(subviews){
        for (UIView *view in subviews)
            [view removeFromSuperview];
        [ticketViewElementsArray removeAllObjects];
    }
    ticketScrollView.hidden = YES;
    
    if ([substring length]==3) {
        //Solicitar arreglo de strings
        [completeStringsArray addObject:[NSString stringWithFormat:@"%@%@",substring,@"primer"]];
        [completeStringsArray addObject:[NSString stringWithFormat:@"%@%@",substring,@"segundo"]];
        [completeStringsArray addObject:[NSString stringWithFormat:@"%@%@",substring,@"segmento"]];
        
        [completeTableView setFrame:CGRectMake(0, completeTableView.frame.origin.y, completeTableView.frame.size.width, 44*[completeStringsArray count])];
        [completeTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * [completeStringsArray count]))];
    }
    
    else if ([substring length]>3){
        for(NSString *curString in temporalArray) {
            NSRange substringRange = [curString rangeOfString:substring];
            if (substringRange.location != NSNotFound) {
                [completeStringsArray addObject:curString];
            }
        }
        
        if([completeStringsArray count]!=0){
            [completeTableView setFrame:CGRectMake(0, completeTableView.frame.origin.y, completeTableView.frame.size.width, 44*[completeStringsArray count])];
            [completeTableView setContentSize:CGSizeMake(self.view.frame.size.width, (44 * [completeStringsArray count]))];
        }else{
            completeStringsArray = temporalArray;
            completeTableView.hidden =YES;
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
        
        for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
            if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]]) {
                viewElement.selectionValue = ((UITextField *)viewElement.viewTicketElement).text;
            }
        }
        
        [self performSegueWithIdentifier:@"invoiceWebViewSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceWebViewSegue"]){
        WevInvoiceViewController *webViewInvoiceData = [segue destinationViewController];
        webViewInvoiceData.ticketViewElementsArray = ticketViewElementsArray;
        webViewInvoiceData.companyURL = [NSURL URLWithString:_tiendaURL];
    }
}

#pragma mark - ConfirmationViewControllerSources
- (BOOL) validationInvoiceData{
    
    for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]]) {
            if(![viewElement.dataSource isEqualToString:@"userInfo"]){
            
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:viewElement.mascaraTicket options:NSRegularExpressionCaseInsensitive error:&error];
                NSTextCheckingResult *match = [regex firstMatchInString:((UITextField *)viewElement.viewTicketElement).text  options:0 range:NSMakeRange(0, [((UITextField *)viewElement.viewTicketElement).text length])];
            
                if (match){
                    ((UITextField *)viewElement.viewTicketElement).text = [((UITextField *)viewElement.viewTicketElement).text substringWithRange:match.range];
                }else{
                    NSLog(@"Error en el campo: %@", [viewElement.valueCampoTicket objectAtIndex:0]);
                    return FALSE;
                }
            }
        }
    }
    return TRUE;
}

- (void) updateViewsWhitSelectedRFC {
    
    //Obtener elemento rfc del arreglo
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    BWRRFCInfo *rfcActual;
    for (BWRRFCInfo *rfcInfo in fetchedResults){
        if ([[userDefaults valueForKey:@"rfc"] isEqualToString:rfcInfo.rfc]) {
            rfcActual = rfcInfo;
        }else{
            return;
        }
    }
    
    //Colocar campo en elemento visual
    for (BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if([viewElement.dataSource isEqualToString:@"userInfo"]){
            ((UITextField *)viewElement.viewTicketElement).text = [rfcActual valueForKey:[viewElement.valueCampoTicket objectAtIndex:0]];
            NSLog(@"Valor de %@ es %@", viewElement.dataSource, ((UITextField *)viewElement.viewTicketElement).text);
        }
    }
}

- (void) invoiceDataRecognition {
    
    for (BWRTicketViewElement *viewElement in ticketViewElementsArray){
        if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]]) {
            if(![viewElement.dataSource isEqualToString:@"userInfo"]){
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:viewElement.campoTicket options:NSRegularExpressionCaseInsensitive error:&error];
                NSTextCheckingResult *match = [regex firstMatchInString:invoiceLabel.text options:0
                                                              range:NSMakeRange(0, [invoiceLabel.text length])];
            
                if (match) {
                    ((UITextField *)viewElement.viewTicketElement).text = [invoiceLabel.text substringWithRange:match.range];
                }else{
                    ((UITextField *)viewElement.viewTicketElement).text = [NSString stringWithFormat:@"%@ no reconocido", viewElement.selectionValue];
                }
            }
        }
    }
}

- (void) processRecognition{
    while ([invoiceLabel.text isEqualToString:@"Procesando"]);
    
    [self performSelectorOnMainThread:@selector(invoiceDataRecognition) withObject:nil waitUntilDone:YES];
}

#pragma mark - Jason Messages
- (void) companyListWithSubstring: (NSString *)substring{
  //return NSArray
}

- (void) viewElementsWithCompany: (NSString *)company{
    //return NSDictionary
}



@end