//
//  BWRInvoiceDataViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRInvoiceDataViewController.h"
#import "BWRInvoiceHistoryViewController.h"

@interface BWRInvoiceDataViewController ()

@end

@implementation BWRInvoiceDataViewController

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

@synthesize lb_facturacion;
@synthesize lb_direccion;
@synthesize bt_listo;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BWRInvoiceDataViewController *)initWithDefault: (NSString *)title
{
    self = [super init];
    
    //Medidas
    static NSInteger ALTO = 31;
    static NSInteger ANCHO_LARGO = 200;
    static NSInteger ANCHO_CHICO = 130;
    static NSInteger PADING = 20;
    NSInteger espaciado = 20;
    
    
    //Titulo
    self.title = title;
    
    //Facturacion
    lb_facturacion = [[UILabel alloc] initWithFrame:CGRectMake(PADING, espaciado, 270, 21)];
    lb_facturacion.text = @"DATOS DE FACTURACIÓN";
    
    //RFC
    tf_rfc = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_rfc.borderStyle = UITextBorderStyleRoundedRect;
    tf_rfc.placeholder = @"RFC";  //place holder
    
    //Nombre
    tf_nombre = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_nombre.borderStyle = UITextBorderStyleRoundedRect;
    tf_nombre.placeholder = @"Nombre";  //place holder
    
    //Apellido paterno
    tf_apaterno = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_apaterno.borderStyle = UITextBorderStyleRoundedRect;
    tf_apaterno.placeholder = @"Apellido Materno";  //place holder
    
    //Apellido materno
    tf_amaterno = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_amaterno.borderStyle = UITextBorderStyleRoundedRect;
    tf_amaterno.placeholder = @"Apellido Paterno";  //place holder
    
    //Direccion
    lb_direccion = [[UILabel alloc] initWithFrame:CGRectMake(PADING, espaciado+=60, ANCHO_CHICO, 21)];
    lb_direccion.text = @"Dirección";
    
    //Calle
    tf_calle = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_calle.borderStyle = UITextBorderStyleRoundedRect;
    tf_calle.placeholder = @"Calle";  //place holder
    
    //Numero interior
    tf_noint = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_CHICO, ALTO)];
    tf_noint.borderStyle = UITextBorderStyleRoundedRect;
    tf_noint.placeholder = @"No Interior";  //place holder
    
    //Numero exterior
    tf_noext = [[UITextField alloc] initWithFrame:CGRectMake(PADING*2+ANCHO_CHICO, espaciado, ANCHO_CHICO, ALTO)];
    tf_noext.borderStyle = UITextBorderStyleRoundedRect;
    tf_noext.placeholder = @"No Exterior";  //place holder
    
    //Colonia
    tf_colonia = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_colonia.borderStyle = UITextBorderStyleRoundedRect;
    tf_colonia.placeholder = @"Colonia";  //place holder
    
    //Delegacion
    tf_delegacion = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_delegacion.borderStyle = UITextBorderStyleRoundedRect;
    tf_delegacion.placeholder = @"Delegación";
    
    //Estado
    tf_estado = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_estado.borderStyle = UITextBorderStyleRoundedRect;
    tf_estado.placeholder = @"Estado";
    
    //Ciudad
    tf_ciudad = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_ciudad.borderStyle = UITextBorderStyleRoundedRect;
    tf_ciudad.placeholder = @"Ciudad";
    
    //Localidad
    tf_localidad = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_localidad.borderStyle = UITextBorderStyleRoundedRect;
    tf_localidad.placeholder = @"Localidad";
    
    //Codigo Postal
    tf_cp = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_CHICO, ALTO)];
    tf_cp.borderStyle = UITextBorderStyleRoundedRect;
    tf_cp.placeholder = @"C.P.";
    
    //Boton Listo
    bt_listo = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(invoiceHistoryViewController)];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIScrollView *scrollView=(UIScrollView *)self.view;
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.contentSize=CGSizeMake(320,740);
    
    
    //Facturacion
    [scrollView addSubview:lb_facturacion];
    //RFC
    [scrollView addSubview:tf_rfc];
    //Nombre
    [scrollView addSubview:tf_nombre];
    //Apellido paterno
    [scrollView addSubview:tf_apaterno];
    //Apellido materno
    [scrollView addSubview:tf_amaterno];
    //Direccion
    [scrollView addSubview:lb_direccion];
    //Calle
    [scrollView addSubview:tf_calle];
    //Numero interior
    [scrollView addSubview:tf_noint];
    //Numero exterior
    [scrollView addSubview:tf_noext];
    //Colonia
    [scrollView addSubview:tf_colonia];
    //Delegacion
    [scrollView addSubview:tf_delegacion];
    //Estado
    [scrollView addSubview:tf_estado];
    //Ciudad
    [scrollView addSubview:tf_ciudad];
    //Localidad
    [scrollView addSubview:tf_localidad];
    //Codigo Postal
    [scrollView addSubview:tf_cp];
    
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

- (void)invoiceHistoryViewController
{
    BWRInvoiceHistoryViewController *historyViewController = [[BWRInvoiceHistoryViewController alloc] init];
    historyViewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:historyViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
