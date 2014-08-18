//
//  BWRInitialConfigurationDataUserViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Baware SA de CV. All rights reserved.
//

#import "BWRInitialConfigurationDataUserViewController.h"
#import "BWRInvoiceDataViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

/** A viewcontroller that authenticate user in gplus. That can be with a gplus login button or by silent mode login (if user login once).
 */
@interface BWRInitialConfigurationDataUserViewController ()
/** The signin object for authenticate user in google.
 */
@property GPPSignIn *signIn;
@end

/*@implementation BWRInitialConfigurationDataUserViewController
@synthesize signInButton;
@synthesize signIn;
// Google app id, is provided for Google and is necesary for request a GPlus login and user information.
static NSString * const kClientId = @"853814459237-313spgj6avl7ot1au6gd5vhr8ttbo1d5.apps.googleusercontent.com";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"¡Bienvenido!";
    
    // GPlus Login
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kClientId;
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;
    [signIn trySilentAuthentication];
    [self buildInterface];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


/** Build interface for application login.
 
 Create a gplus login button for obtain the user gmail address and show a application logo image.
 
 */
/*-(void)buildInterface{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIImageView *logoImage = [[UIImageView alloc] init];
    NSInteger width;
    NSInteger heigth = 31;
    NSInteger padding = 20;
    NSInteger space = 65;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)) {
        width = (self.view.frame.size.width / 2) - (2*padding);
        logoImage.frame =CGRectMake(width + (3 * padding), space, width, width);
    }else {
        width = self.view.frame.size.width - ( 2 * padding);
        logoImage.frame = CGRectMake(padding, space, width, width);
        space += width - (padding*2);
    }
    
    logoImage.image = [UIImage imageNamed:@"bawarelogo.png"];
    [logoImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:logoImage];
    
    signInButton = [[GPPSignInButton alloc] initWithFrame:CGRectMake(padding, space, width, heigth)];
    [self.view addSubview:signInButton];
}

#pragma mark - Navigation
/** Catch the invocation segue event.
 When a invoiceDataSegue is called, we init a BWRInvoiceDataViewController with initWithFirstRFC method.
 */
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceDataSegue"]){
        BWRInvoiceDataViewController *configurationInvoiceData = [segue destinationViewController];
        [configurationInvoiceData initWithFirstRFC:@"bienvenido"];
    }
}


/** Invoke user data capture view, for capture the RFC, names and address info of the user.
 
 When is the first time access of the application and isn't configured a user email and user invoice data, a user data capture view is invoked for obtain the invoice data necesary for process the requests.
 
 Also is saved the email of the user after of gplus login.
 
 */
/*- (void)invoiceDataViewController
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setValue:[self getEmailAddressFromGPPAccount] forKey:@"Correo"];
    
    [self performSegueWithIdentifier:@"invoiceDataSegue" sender:self];
}

/** Invoke the user history invoice view.
 
 Using a segue, invoke the invoice history view controller.
 */
/*- (void)invoiceHistoryViewController
{
    [self performSegueWithIdentifier:@"invoiceCompleteDataSegue" sender:self];
}

#pragma mark - GPPSignInDelegate
/** Show the status of gplus login intent.
 
 When user or a silent login try to authenticate, the response is received in this method. If error is diferent to nil, the error is showed in console.
 
 If error is equal to nil, we refresh the interface.
 */
/*- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if(error == nil){
        [self refreshInterfaceBasedOnSignIn];
    }else{
        NSLog(@"%@", error);
    }
}

#pragma mark - GPlus Login Auxiliars Messages
/** Get the email address from the gplus account authenticated.
 @return Email address of google account.
 */
/*-(NSString*)getEmailAddressFromGPPAccount{
    NSString *email;
    
    email = signIn.authentication.userEmail;
    NSLog(@"Email: %@", email);
    return email;
}

/** If authentication is valid, we try to invoke the next view controller depending if is configurated the email address and the rfc info.
 */
/*-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        
        if(!([userDefaults valueForKey:@"Correo"] && [userDefaults valueForKey:@"rfc"])){
            [self invoiceDataViewController];
        }else{
            [self invoiceHistoryViewController];
        }
    }
}


@end*/

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
    tf_password.secureTextEntry = YES;
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
        tf_confpassword.secureTextEntry = YES;
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

