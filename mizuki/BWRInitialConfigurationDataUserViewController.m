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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceDataSegue"]){
        BWRInvoiceDataViewController *configurationInvoiceData = [segue destinationViewController];
        [configurationInvoiceData initWithDefault:@"bienvenido"];
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
    
    [self performSegueWithIdentifier:@"invoiceCompleteDataSegue" sender:self];
}

#pragma mark - GPPSignInDelegate
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if(error == nil){
        [self refreshInterfaceBasedOnSignIn];
    }else{
        NSLog(@"%@", error);
    }
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
    }
    [self buildInterface];
    
}


@end
