//
//  BWRInitialConfigurationDataUserViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRInitialConfigurationDataUserViewController.h"
#import "BWRInvoiceDataViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>


@interface BWRInitialConfigurationDataUserViewController ()
@property GPPSignIn *signIn;
@end

@implementation BWRInitialConfigurationDataUserViewController

@synthesize tf_correo;
@synthesize tf_password;
@synthesize tf_confpassword;
@synthesize bt_siguiente;
@synthesize signInButton;
@synthesize signIn;

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

-(void)buildInterface{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIImageView *logoImage = [[UIImageView alloc] init];
    NSInteger width;
    NSInteger heigth = 31;
    NSInteger padding = 20;
    NSInteger space;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)) {
        width = self.view.frame.size.width / 2;
        space = 60;
        logoImage.bounds =CGRectMake(width + padding, space, width - (padding*2), self.view.frame.size.height - 120);
    }else {
        space = 60;
        width = self.view.frame.size.width;
        logoImage.bounds = CGRectMake(padding, space, width - (padding*2), width - (padding*2));
        space += width - (padding*2);
    }
    width = width-(2*padding);
    logoImage.image = [UIImage imageNamed:@"bawarelogo.png"];
    [logoImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:logoImage];
    
    signInButton = [[GPPSignInButton alloc] initWithFrame:CGRectMake(padding, space, width, heigth)];
    [self.view addSubview:signInButton];
    
    //Comprobando si no es la primera vez de la aplicacion
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    
    if(!([userDefaults valueForKey:@"Correo"] && [userDefaults valueForKey:@"rfc"])){
        bt_siguiente = [[UIBarButtonItem alloc] initWithTitle:@"Siguiente" style:UIBarButtonItemStylePlain target:self action:@selector(invoiceDataViewController)];
    }else{
        bt_siguiente = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(invoiceHistoryViewController)];
    }
    
    //Boton siguiente
    self.navigationItem.rightBarButtonItem = bt_siguiente;
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
    [userDefaults setValue:[self getEmailAddressFromGPPAccount] forKey:@"Correo"];
    
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

#pragma mark - GPPSignInDelegate
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if(error == nil){
        //[self refreshInterfaceBasedOnSignIn];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        
        if(!([userDefaults valueForKey:@"Correo"] && [userDefaults valueForKey:@"rfc"])){
            [self invoiceDataViewController];
        }else{
            [self invoiceHistoryViewController];
        }
    }else{
        NSLog(@"%@", error);
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

-(NSString*)getEmailAddressFromGPPAccount{
    NSString *email;
    
    email = signIn.authentication.userEmail;
    NSLog(@"Email: %@", email);
    return email;
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        
        if(!([userDefaults valueForKey:@"Correo"] && [userDefaults valueForKey:@"rfc"])){
            [self invoiceDataViewController];
        }else{
            [self invoiceHistoryViewController];
        }
    } else {
        [self buildInterface];
    }
}


@end
