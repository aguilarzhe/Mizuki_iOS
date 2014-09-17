//
//  BWRInvoiceDataViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRInvoiceDataViewController.h"
#import "BWRInvoiceHistoryViewController.h"
#import "BWRUserPreferences.h"
#import "AppDelegate.h"

@interface BWRInvoiceDataViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate>
@property NSManagedObjectContext *managedObjectContext;
@property BOOL opcion;
@property BWRRFCInfo *updateRFC;
@property BOOL firstRFC;
@end

@implementation BWRInvoiceDataViewController

@synthesize managedObjectContext;
@synthesize opcion;
@synthesize updateRFC;
@synthesize tf_rfc;
@synthesize tf_nombre;
@synthesize tf_apaterno;
@synthesize tf_amaterno;
@synthesize tf_calle;
@synthesize tf_noint;
@synthesize tf_noext;
@synthesize tf_colonia;
@synthesize tf_delegacion;
@synthesize tf_estado;
@synthesize tf_ciudad;
@synthesize tf_localidad;
@synthesize tf_cp;
@synthesize lb_direccion;
@synthesize bt_listo;
@synthesize firstRFC;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Measures
    NSInteger screenWidth = self.view.frame.size.width;
    NSInteger height = 31;
    NSInteger padding = 20;
    NSInteger depth = 20;
    NSInteger longWidth;
    NSInteger shortWidth;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (firstRFC) {
            longWidth = (self.view.frame.size.width / 2) - (2 * padding);
            shortWidth = (longWidth / 2) - (padding/2);
        }else{
            longWidth = 270;
            shortWidth = 120;
        }
        
    }else{
        longWidth = screenWidth-(2*padding);
        shortWidth = (longWidth/2)-(padding/2);
    }
    
    UIScrollView *scrollView=(UIScrollView *)self.view;
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.contentSize=CGSizeMake(320,740);
    
    // Personal info
    tf_rfc.frame = CGRectMake(padding, depth, longWidth, height);
    [scrollView addSubview:tf_rfc];
    tf_nombre.frame = CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_nombre];
    tf_apaterno.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_apaterno];
    tf_amaterno.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_amaterno];
    
    // If is firstRFC capture and the device is a iPad
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && firstRFC){
        depth = -20;
        padding += longWidth + (padding * 2);
    }
    
    // Address user info
    lb_direccion.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:lb_direccion];
    tf_calle.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_calle];
    //Numero interior
    tf_noint.frame =CGRectMake(padding, depth+=40, shortWidth, height);
    [scrollView addSubview:tf_noint];
    //Numero exterior
    tf_noext.frame =CGRectMake(padding*2+shortWidth, depth, shortWidth, height);
    [scrollView addSubview:tf_noext];
    tf_colonia.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_colonia];
    tf_delegacion.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_delegacion];
    tf_estado.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_estado];
    tf_ciudad.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_ciudad];
    tf_localidad.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_localidad];
    //Codigo Postal
    tf_cp.frame =CGRectMake(padding, depth+=40, longWidth, height);
    [scrollView addSubview:tf_cp];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !firstRFC){
        UIButton *listoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [listoButton setTitle:@"Guardar" forState:UIControlStateNormal];
        [listoButton addTarget:self action:@selector(saveInfoRFC) forControlEvents:UIControlEventTouchUpInside];
        listoButton.frame = CGRectMake(padding, depth+=40, longWidth, height);
        [scrollView addSubview:listoButton];
    }
    
    // CoreData
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    //Ready button
    self.navigationItem.rightBarButtonItem = bt_listo;
    
    //SCROLL VIEW
    self.view=scrollView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Inicialitation
/** Alloc and init each view element.
 
 Adding the method asings delegate and border style (TextField)
 */
- (void)createInvoiceData
{
    //RFC
    tf_rfc = [[UITextField alloc] init];
    tf_rfc.borderStyle = UITextBorderStyleRoundedRect;
    //tf_rfc.backgroundColor = [UIColor redColor];
    tf_rfc.delegate = self;
    //Nombre
    tf_nombre = [[UITextField alloc] init];
    tf_nombre.borderStyle = UITextBorderStyleRoundedRect;
    tf_nombre.delegate = self;
    //Apellido paterno
    tf_apaterno = [[UITextField alloc] init];
    tf_apaterno.borderStyle = UITextBorderStyleRoundedRect;
    tf_apaterno.delegate = self;
    //Apellido materno
    tf_amaterno = [[UITextField alloc] init];
    tf_amaterno.borderStyle = UITextBorderStyleRoundedRect;
    tf_amaterno.delegate = self;
    
    //Direccion
    lb_direccion = [[UILabel alloc] init];
    lb_direccion.text = @"Dirección";
    //Calle
    tf_calle = [[UITextField alloc] init];
    tf_calle.borderStyle = UITextBorderStyleRoundedRect;
    tf_calle.delegate = self;
    
    //Numero interior
    tf_noint = [[UITextField alloc] init];
    tf_noint.borderStyle = UITextBorderStyleRoundedRect;
    tf_noint.delegate = self,
    
    //Numero exterior
    tf_noext = [[UITextField alloc] init];
    tf_noext.borderStyle = UITextBorderStyleRoundedRect;
    tf_noext.delegate = self;
    
    //Colonia
    tf_colonia = [[UITextField alloc] init];
    tf_colonia.borderStyle = UITextBorderStyleRoundedRect;
    tf_colonia.delegate = self;

    //Delegacion
    tf_delegacion = [[UITextField alloc] init];
    tf_delegacion.borderStyle = UITextBorderStyleRoundedRect;
    tf_delegacion.delegate = self;
    
    //Estado
    tf_estado = [[UITextField alloc] init];
    tf_estado.borderStyle = UITextBorderStyleRoundedRect;
    tf_estado.delegate = self;
    
    //Ciudad
    tf_ciudad = [[UITextField alloc] init];
    tf_ciudad.borderStyle = UITextBorderStyleRoundedRect;
    tf_ciudad.delegate = self;
    
    //Localidad
    tf_localidad = [[UITextField alloc] init];
    tf_localidad.borderStyle = UITextBorderStyleRoundedRect;
    tf_localidad.delegate = self;
    
    //Codigo Postal
    tf_cp = [[UITextField alloc] init];
    tf_cp.borderStyle = UITextBorderStyleRoundedRect;
    tf_cp.delegate = self;
    
    //Ready button
    bt_listo = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(saveInfoRFC)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    tf_cp.delegate = self;
    
    [self setTitle:@"Datos de facturación"];
}



#pragma mark - init
/** Init the viewController with default values and firstRFC in YES.
 
 The firstRFC indicates that the rfc will be seved like default selected rfc in user preferens.
 
 @param title NSString with the view title.
 */
-(void)initWithFirstRFC:(NSString *)title
{
    firstRFC = YES;
    [self initWithDefault:title];
}

/** Init the viewController with default values.
 
 Put in each textField in placeholder feature the element name.
 
 @param title NSString with the view title.
 */
- (void)initWithDefault: (NSString *)title
{
    [self createInvoiceData];
    
    
    //Create new rfc in core data
    opcion = TRUE;
    
    //Title
    self.title = title;
    
    //RFC
    tf_rfc.placeholder = @"RFC";
    //Nombre
    tf_nombre.placeholder = @"Nombre";
    //Apellido paterno
    tf_apaterno.placeholder = @"Apellido Paterno";
    //Apellido materno
    tf_amaterno.placeholder = @"Apellido Materno";
    //Calle
    tf_calle.placeholder = @"Calle";
    //Numero interior
    tf_noint.placeholder = @"No Interior";
    //Numero exterior
    tf_noext.placeholder = @"No Exterior";
    //Colonia
    tf_colonia.placeholder = @"Colonia";
    //Delegacion
    tf_delegacion.placeholder = @"Delegación";
    //Estado
    tf_estado.placeholder = @"Estado";
    //Ciudad
    tf_ciudad.placeholder = @"Ciudad";
    //Localidad
    tf_localidad.placeholder = @"Localidad";
    //Codigo Postal
    tf_cp.placeholder = @"C.P.";
    
}

/** Init the viewController with rfcInfo values.
 
 Put in each textField in placeholder feature the rfcInfo value.
 
 @param rfcInfo BWRFCInfo to edit.
 @param title NSString with the view title.
 */
- (void)initWithBWRRFCInfo:(BWRRFCInfo *)rfcInfo title:(NSString *)title
{
    [self initWithDefault:title];
    
    //Don't create new object in core data
    opcion = FALSE;
    updateRFC = rfcInfo;
    
    //RFC
    tf_rfc.text = rfcInfo.rfc;
    //Nombre
    tf_nombre.text = rfcInfo.nombre;
    //Apellido paterno
    tf_apaterno.text = rfcInfo.apellidoPaterno;
    //Apellido materno
    tf_amaterno.text = rfcInfo.apellidoMaterno;
    //Calle
    tf_calle.text = rfcInfo.calle;
    //Numero interior
    tf_noint.text = rfcInfo.numInterior;
    //Numero exterior
    tf_noext.text = rfcInfo.numExterior;
    //Colonia
    tf_colonia.text = rfcInfo.colonia;
    //Delegacion
    tf_delegacion.text = rfcInfo.delegacion;
    //Estado
    tf_estado.text = rfcInfo.estado;
    //Ciudad
    tf_ciudad.text = rfcInfo.ciudad;
    //Localidad
    tf_localidad.text = rfcInfo.localidad;
    //Codigo Postal
    tf_cp.text = rfcInfo.codigoPostal;
    
}

#pragma mark - Navigation
/** Save the rfcInfo in core data.
 
 According to the option it inserts or updates the rfcInfo in core data and validate the action executed.
 
 @param rfcInfo BWRFCInfo to edit.
 @param title NSString with the view title.
 */
- (void)saveInfoRFC
{
    BWRRFCInfo *rfcInfo;
    
    if(opcion){
        rfcInfo = [NSEntityDescription insertNewObjectForEntityForName:@"RFCInfo" inManagedObjectContext:managedObjectContext];
    }else{
        rfcInfo = updateRFC;
    }
    
    if (rfcInfo) {
        
        //update rfc info
        rfcInfo.rfc = tf_rfc.text;
        rfcInfo.nombre = tf_nombre.text;
        rfcInfo.apellidoPaterno = tf_apaterno.text;
        rfcInfo.apellidoMaterno = tf_amaterno.text;
        rfcInfo.pais = @"MEXICO";
        rfcInfo.estado = tf_estado.text;
        rfcInfo.delegacion = tf_delegacion.text;
        rfcInfo.colonia = tf_colonia.text;
        rfcInfo.calle = tf_calle.text;
        rfcInfo.numInterior = tf_noint.text;
        rfcInfo.numExterior = tf_noext.text;
        rfcInfo.codigoPostal = tf_cp.text;
        rfcInfo.ciudad = tf_ciudad.text;
        rfcInfo.localidad = tf_localidad.text;
        
        NSError *error = nil;
        //Save changes in data base
        /*if (*/[managedObjectContext save:&error];//) {
            if (![BWRUserPreferences getStringValueForKey:@"rfc"]) {
                [BWRUserPreferences setStringValue:rfcInfo.rfc forKey:@"rfc"];
            }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !firstRFC){
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self performSegueWithIdentifier:@"invoiceHistorySegue" sender:self];
        }
        
        /*}else{
            NSLog(@"Error guardando elemento en base de datos %@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Datos no válidos" message:@"Verifique los datos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            NSDictionary *userInfo = error.userInfo;
            NSError *aux;
            NSString *validationErrorKey;
            if ((validationErrorKey = userInfo[@"NSValidationErrorKey"])) {
                NSLog(@"%@", validationErrorKey);
                [alertView setMessage:[NSString stringWithFormat:@"Hay un error en %@", validationErrorKey]];
            }else if((aux = userInfo[@"NSDetailedErrors"][0])){
                NSLog(@"%@", aux.userInfo[@"NSValidationErrorKey"]);
                [alertView setMessage:[NSString stringWithFormat:@"Hay un error en %@", aux.userInfo[@"NSValidationErrorKey"]]];
            }
            
            [alertView show];
        }*/

    }
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

@end
