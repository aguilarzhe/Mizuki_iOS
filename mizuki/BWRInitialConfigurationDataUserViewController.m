//
//  BWRInitialConfigurationDataUserViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRInitialConfigurationDataUserViewController.h"
#import "BWRInvoiceDataViewController.h"

@interface BWRInitialConfigurationDataUserViewController ()

@end

@implementation BWRInitialConfigurationDataUserViewController

@synthesize tf_correo;
@synthesize tf_password;
@synthesize tf_confpassword;
@synthesize bt_siguiente;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"¡BIENVENIDO!";
    
    //Medidas
    NSInteger anchoPantalla = self.view.frame.size.width;
    NSInteger ALTO = 31;
    NSInteger PADING = 20;
    NSInteger espaciado = 100;
    NSInteger ANCHO_LARGO = anchoPantalla-(2*PADING);
    
    //Correo
    tf_correo = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado, ANCHO_LARGO, ALTO)];
    tf_correo.borderStyle = UITextBorderStyleRoundedRect;
    tf_correo.font = [UIFont systemFontOfSize:17.0];
    tf_correo.placeholder = @"Correo";
    [self.view addSubview:tf_correo];
    
    //Contraseña
    tf_password = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
    tf_password.borderStyle = UITextBorderStyleRoundedRect;
    tf_password.font = [UIFont systemFontOfSize:17.0];
    tf_password.placeholder = @"Contraseña";
    [self.view addSubview:tf_password];
    
    //Comprobando si no es la primera vez de la aplicacion
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    if(!([userDefaults valueForKey:@"Correo"] && [userDefaults valueForKey:@"rfc"])){
        bt_siguiente = [[UIBarButtonItem alloc] initWithTitle:@"Siguiente" style:UIBarButtonItemStylePlain target:self action:@selector(invoiceDataViewController)];
        
        //Confirmacion contraseña
        tf_confpassword = [[UITextField alloc] initWithFrame:CGRectMake(PADING, espaciado+=40, ANCHO_LARGO, ALTO)];
        tf_confpassword.borderStyle = UITextBorderStyleRoundedRect;
        tf_confpassword.font = [UIFont systemFontOfSize:17.0];
        tf_confpassword.placeholder = @"Confirmacion de contraseña";
        [self.view addSubview:tf_confpassword];
        
    }else{
        bt_siguiente = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(invoiceHistoryViewController)];
    }
    
    //Boton siguiente
    self.navigationItem.rightBarButtonItem = bt_siguiente;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceDataSegue"]){
        BWRInvoiceDataViewController *configurationInvoiceData = [segue destinationViewController];
        [configurationInvoiceData initWithDefault:@"¡BIENVENIDO!"];
    }
}

- (void)invoiceDataViewController
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setValue:tf_correo.text forKey:@"Correo"];
    
    [self performSegueWithIdentifier:@"invoiceDataSegue" sender:self];
}

- (void)invoiceHistoryViewController
{
    //Temporal
    /*NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
     [userDefaults setValue:nil forKey:@"Correo"];
     [userDefaults setValue:nil forKey:@"rfc"];*/
    
    [self performSegueWithIdentifier:@"invoiceCompleteDataSegue" sender:self];
}



@end
