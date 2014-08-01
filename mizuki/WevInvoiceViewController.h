//
//  WevInvoiceViewController.h
//  Webview
//
//  Created by Carolina Mora on 18/07/14.
//  Copyright (c) 2014 Carolina Mora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WevInvoiceViewController : UIViewController <UIWebViewDelegate>

@property NSMutableArray *invoicePagesArray;
@property NSURL *companyURL;
@property NSInteger actualPage;


@end
