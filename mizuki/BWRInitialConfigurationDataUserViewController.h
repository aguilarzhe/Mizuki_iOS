//
//  BWRInitialConfigurationDataUserViewController.h
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@interface BWRInitialConfigurationDataUserViewController : UIViewController <GPPSignInDelegate>
/** Google plus button for authentication.
 */
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

@property UITextField *tf_correo;
@property UITextField *tf_password;
@property UITextField *tf_confpassword;
@property UIBarButtonItem *bt_siguiente;

@end

@class GPPSignInButton;