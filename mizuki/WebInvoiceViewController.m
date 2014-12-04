//
//  WevInvoiceViewController.m
//  Webview
//
//  Created by Carolina Mora on 18/07/14.
//  Copyright (c) 2014 Baware SA de CV. All rights reserved.
//

#import "WebInvoiceViewController.h"
#import "BWRTicketViewElement.h"
#import "BWRInvoiceTicketPage.h"
#import "BWRMessagesToUser.h"
#import "BWRWebConnection.h"
#import "AppDelegate.h"

@interface WebInvoiceViewController ()

@property NSURLResponse *theResponse;
@property NSMutableData *dataRecive;
@property BOOL loadError;

@end

static BOOL startInvoicing = FALSE;
static UIWebView *invoiceWebView;

@implementation WebInvoiceViewController

@synthesize invoicePagesArray;
@synthesize companyURL;
@synthesize actualPage;
@synthesize theResponse;
@synthesize dataRecive;
@synthesize completeInvoice;
@synthesize loadError;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Update webview application
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.webView = self;
    
    //Webview
    invoiceWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    invoiceWebView.delegate = self;
    [self.view addSubview:invoiceWebView];
    
    //Validate internet connection
    if ([BWRWebConnection getConnection]) {
        
        //load url into webview
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:companyURL];
        [invoiceWebView loadRequest:urlRequest];
    }
    //If no conection or doesn't correspond
    else{
        [self errorOcurred];
    }
    
    [self goToInvoiceHistory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIWebViewDelegate
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //Delate alert messages from the page
    [invoiceWebView stringByEvaluatingJavaScriptFromString:@"javascript:(function() {window.alert=null; })()"];
    
    //Do invoicing in background
    if(actualPage<[invoicePagesArray count] && !startInvoicing){
        [self performSelectorInBackground:@selector(fillPagesInBackground) withObject:nil];
        startInvoicing = TRUE;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    //If one web page more (error)
    if(actualPage==[invoicePagesArray count]){
        NSLog(@"Ya son las paginas +++++++++++++++++++++++++ %d",[invoicePagesArray count]);
        [self errorOcurred];
    }
    
    return TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"ERROR: %@", error);
    [self errorOcurred];
}

#pragma mark - WebInvoiceViewConetroller Sources
-(void) fillPagesAccordingToService{
    
    [self performSelectorOnMainThread:@selector(executeJavaScriptFromWebPage) withObject:nil waitUntilDone:YES];
}

-(void) fillPagesInBackground {
    
    UIBackgroundTaskIdentifier background_task;
    UIApplication *application = [UIApplication sharedApplication];
    
    //Init background task
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        
        //Clean up code. Tell the system that we are done.
        [application endBackgroundTask: background_task];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //### background task starts
        NSLog(@"Running in the background\n");
        [self executeJavaScriptFromWebPage];
        //#### background task ends
        
        //Clean up code. Tell the system that we are done.
        [application endBackgroundTask: background_task];
    });
        
}

- (void) errorOcurred {
    loadError = TRUE;
    //Show webview
    [BWRMessagesToUser Notification:@"Error de facturación"];
    //Add invoice
    [self validateInvoiceError];
}

- (void) validateInvoiceError{
    
    //Get state
    NSString *status = @"Facturada";
    //If there is an error
    if(loadError){
        status = @"Pendiente";
    }
    
    else{
        [BWRMessagesToUser Notification:[NSString stringWithFormat:@"Ticket facturado. Estado: %@", status]];
    }
    
    //Update invoice
    [completeInvoice updateCompleteInvoiceWithRFC:completeInvoice.rfc status:status];
    
    NSLog(@"Se agregó la factura--------------status: %@----------------------------", status);
    startInvoicing = FALSE;
    
}

#pragma  mark - JavaScript
- (void) executeJavaScriptFromWebPage{
    
   //Fill and send all forms
    for (int index=actualPage; index<[invoicePagesArray count]; index++){
        BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:index];
        NSString *javascript = [self createJavaScriptStringWithRules:invoicePage.rules];
        [NSThread sleepForTimeInterval:6];
        //[self stringByEvaluatingJavaScriptFromString:javascript];
        [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:javascript waitUntilDone:YES];
        
        if(loadError){
            //Show webview
            [BWRMessagesToUser Notification:@"Error de facturación"];
            break;
        }loadError = TRUE;
        actualPage++;
    }
        
    //Finish invoicing
    [self validateInvoiceError];
    
    
}

-(void)stringByEvaluatingJavaScriptFromString:(NSString *)javascript
{
    if([invoiceWebView stringByEvaluatingJavaScriptFromString:javascript]!=nil){
        NSLog(@"Java Script ejecutado");
    }else{
        NSLog(@"Java Script FALLO");
        loadError = TRUE;
        //Show webinvoice
        [BWRMessagesToUser Notification:@"Error de facturación"];
    }
    
}

- (NSString *) createJavaScriptStringWithRules: (NSArray *)invoicePageRules{
    
    NSMutableString *javascript = [[NSMutableString alloc] initWithString:@"javascript:(function() {\n"];
    
    for(BWRTicketViewElement *viewElement in invoicePageRules){
        if ([viewElement.formFieldType isEqualToString:@"submit"]) {
            [javascript appendFormat:@"document.getElementById('%@').click();\n", viewElement.formField];
        }
        
        else if([viewElement.formFieldType isEqualToString:@"js_code"]){
            [javascript appendString:viewElement.formField];
        }
        
        else if([viewElement.formFieldType isEqualToString:@"captcha"]){
            
        }
        
        else{
            [javascript appendFormat:@"document.getElementById('%@').value = '%@';\n", viewElement.formField, viewElement.selectionValue];
        }
    }
    
    [javascript appendString:@"})()"];
    NSLog(@"%@", javascript);
    return javascript;
}

- (void) validateViewTicketElementsInWebPageWithRules:  (NSArray *)invoicePageRules{
    
}

#pragma mark - Notification
- (void) alertNotification{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error de facturación",nil)
                                                        message:NSLocalizedString(@"La facturación tuvo un error. ¿Desea verlo?",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Después",nil)
                                              otherButtonTitles:NSLocalizedString(@"Ver",nil), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([UIApplication sharedApplication].applicationIconBadgeNumber != 0){
        [UIApplication sharedApplication].applicationIconBadgeNumber--; //Decrement notification badge
    }
    
    //Button selection
    switch(buttonIndex) {
        case 0: //"More later" pressed
            break;
        case 1: //"See" pressed
            [self showWebViewController];
            break;
    }
}

- (void) showWebViewController {
    //History button
    UIBarButtonItem *historyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Mis facturas",nil) style:UIBarButtonItemStyleDone target:self action:@selector(goToInvoiceHistory)];
    self.navigationItem.rightBarButtonItem = historyButton;
    
    //Navigation
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    
    //Set rootViewController with self
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navigationController];
}

#pragma mark - Navigation
-(void)goToInvoiceHistory{
    [self performSegueWithIdentifier:@"InvoiceCompleteSegue" sender:self];
    
}

@end
