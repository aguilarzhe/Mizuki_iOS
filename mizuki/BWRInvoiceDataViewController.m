//
//  BWRInvoiceDataViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRInvoiceDataViewController.h"
#import "BWRInvoiceHistoryViewController.h"
#import "AppDelegate.h"

@interface BWRInvoiceDataViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate>
@property NSManagedObjectContext *managedObjectContext;
@property BOOL opcion;
@property BWRRFCInfo *updateRFC;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Medidas
    NSInteger anchoPantalla = self.view.frame.size.width;
    NSInteger ALTO = 31;
    NSInteger PADING = 20;
    NSInteger espaciado = 20;
    NSInteger ANCHO_LARGO = anchoPantalla-(2*PADING);
    NSInteger ANCHO_CHICO = (ANCHO_LARGO/2)-(PADING/2);
    
    UIScrollView *scrollView=(UIScrollView *)self.view;
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.contentSize=CGSizeMake(320,740);
    
    //RFC
    tf_rfc.frame = CGRectMake(PADING, espaciado, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_rfc];
    //Nombre
    tf_nombre.frame = CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_nombre];
    //Apellido paterno
    tf_apaterno.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_apaterno];
    //Apellido materno
    tf_amaterno.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_amaterno];
    //Direccion
    lb_direccion.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:lb_direccion];
    //Calle
    tf_calle.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_calle];
    //Numero interior
    tf_noint.frame =CGRectMake(PADING, espaciado+=40, ANCHO_CHICO, ALTO);
    [scrollView addSubview:tf_noint];
    //Numero exterior
    tf_noext.frame =CGRectMake(PADING*2+ANCHO_CHICO, espaciado, ANCHO_CHICO, ALTO);
    [scrollView addSubview:tf_noext];
    //Colonia
    tf_colonia.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_colonia];
    //Delegacion
    tf_delegacion.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_delegacion];
    //Estado
    tf_estado.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_estado];
    //Ciudad
    tf_ciudad.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_ciudad];
    //Localidad
    tf_localidad.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_localidad];
    //Codigo Postal
    tf_cp.frame =CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO);
    [scrollView addSubview:tf_cp];
    
    // CoreData
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    //Boton Listo
    self.navigationItem.rightBarButtonItem = bt_listo;
    
    //SCROLL VIEW
    self.view=scrollView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Inicialitation
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
    
    //Boton Listo
    bt_listo = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(saveInfoRFC)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    tf_cp.delegate = self;
    
    //Boton Listo
    bt_listo = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(saveInfoRFC)];
    
    [self setTitle:@"Datos de facturación"];
}

- (void)initWithDefault: (NSString *)title
{
    [self createInvoiceData];
    
    //Crear nuevo rfc en core data
    opcion = TRUE;
    
    //Titulo
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

- (void)initWithBWRRFCInfo:(BWRRFCInfo *)rfcInfo title:(NSString *)title
{
    [self initWithDefault:title];
    
    //No crear nuevo objeto en core data
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
- (void)saveInfoRFC
{
    BWRRFCInfo *rfcInfo;
    
    if(opcion){
        rfcInfo = [NSEntityDescription insertNewObjectForEntityForName:@"RFCInfo" inManagedObjectContext:managedObjectContext];
    }else{
        rfcInfo = updateRFC;
    }
    
    if (rfcInfo) {
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
        /*if (*/[managedObjectContext save:&error];//) {
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
            if (![userDefaults valueForKey:@"rfc"]) {
                [userDefaults setValue:rfcInfo.rfc forKey:@"rfc"];
                [userDefaults setBool:TRUE forKey:@"Notificaciones"];
                [userDefaults setBool:TRUE forKey:@"Sonido"];
                [userDefaults setBool:TRUE forKey:@"Guardar Fotos"];
                [userDefaults setBool:TRUE forKey:@"Solo wifi"];
                
                /************ TEMPORAL*/
                [userDefaults setValue:@"192.168.1.77" forKey:@"ipServidor"];
                //***********************
            }
            
            [self performSegueWithIdentifier:@"invoiceHistorySegue" sender:self];
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
