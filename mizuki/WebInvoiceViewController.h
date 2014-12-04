//
//  WevInvoiceViewController.h
//  Webview
//
//  Created by Carolina Mora on 18/07/14.
//  Copyright (c) 2014 Carolina Mora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWRCompleteInvoice.h"

@interface WebInvoiceViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property NSMutableArray *invoicePagesArray;
@property NSURL *companyURL;
@property NSInteger actualPage;
@property BWRCompleteInvoice *completeInvoice;

- (void) showWebViewController;
- (void) alertNotificationWithState: (NSString *)status;

@end
