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

@end

@class GPPSignInButton;