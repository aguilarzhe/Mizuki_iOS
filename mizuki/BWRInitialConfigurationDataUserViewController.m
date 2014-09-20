//
//  BWRInitialConfigurationDataUserViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Baware SA de CV. All rights reserved.
//

#import "BWRInitialConfigurationDataUserViewController.h"
#import "BWRInvoiceDataViewController.h"
#import "BWRUserPreferences.h"
#import "BWRInvoiceHistoryViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>

/** A viewcontroller that authenticate user in gplus. That can be with a gplus login button or by silent mode login (if user login once).
 */
@interface BWRInitialConfigurationDataUserViewController ()
/** The signin object for authenticate user in google.
 */
@property GPPSignIn *signIn;
@end

@implementation BWRInitialConfigurationDataUserViewController
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
/** Catch the invocation segue event.
 When a invoiceDataSegue is called, we init a BWRInvoiceDataViewController with initWithFirstRFC method.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"invoiceDataSegue"]){
        BWRInvoiceDataViewController *configurationInvoiceData = [segue destinationViewController];
        [configurationInvoiceData initWithFirstRFC:@"Bienvenido"];
    }
    else if([[segue identifier] isEqualToString:@"invoiceCompleteDataSegue"]){
        BWRInvoiceHistoryViewController *invoicesHistory = [segue destinationViewController];
    }
}


/** Invoke user data capture view, for capture the RFC, names and address info of the user.
 
 When is the first time access of the application and isn't configured a user email and user invoice data, a user data capture view is invoked for obtain the invoice data necesary for process the requests.
 
 Also is saved the email of the user after of gplus login.
 
 */
- (void)invoiceDataViewController
{
    [BWRUserPreferences setDefaultsWithEmail:[self getEmailAddressFromGPPAccount]];
    [self performSegueWithIdentifier:@"invoiceDataSegue" sender:self];
}

/** Invoke the user history invoice view.
 
 Using a segue, invoke the invoice history view controller.
 */
- (void)invoiceHistoryViewController
{
    [self performSegueWithIdentifier:@"invoiceCompleteDataSegue" sender:self];
}

#pragma mark - GPPSignInDelegate
/** Show the status of gplus login intent.
 
 When user or a silent login try to authenticate, the response is received in this method. If error is diferent to nil, the error is showed in console.
 
 If error is equal to nil, we refresh the interface.
 */
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if(error == nil){
        [self refreshInterfaceBasedOnSignIn];
    }else{
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        if( error.code == -1009 && [userDefaults valueForKey:@"Correo"]  && [userDefaults valueForKey:@"rfc"]){
            [self invoiceHistoryViewController];
        }
        NSLog(@"%@", error);
    }
}

#pragma mark - GPlus Login Auxiliars Messages
/** Get the email address from the gplus account authenticated.
 @return Email address of google account.
 */
-(NSString*)getEmailAddressFromGPPAccount{
    NSString *email;
    
    email = signIn.authentication.userEmail;
    NSLog(@"Email: %@", email);
    return email;
}

/** If authentication is valid, we try to invoke the next view controller depending if is configurated the email address and the rfc info.
 */
-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        
        if(!([BWRUserPreferences applicationConfigured])){
            [self invoiceDataViewController];
        }else{
            [self invoiceHistoryViewController];
        }
    }
}


@end



