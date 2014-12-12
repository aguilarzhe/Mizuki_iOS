//
//  WevInvoiceViewController.m
//  Webview
//
//  Created by Carolina Mora on 18/07/14.
//  Copyright (c) 2014 Baware SA de CV. All rights reserved.
//
@import JavaScriptCore;

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
static NSString *messageAlert;

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
    
    //Init messate alert string and load error bool
    messageAlert = nil;
    loadError = FALSE;
    
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
        [self validateInvoiceWithStatus:1];
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
    //Delate alert messages from the page  window.location = \"ERROR ELEMENT\"; javascript:(function() {window.alert = function alert (message) {loacation.assign(\"http://google.es\");} })()
    //[invoiceWebView stringByEvaluatingJavaScriptFromString:@"javascript:(function() {window.alert=null; })()"];
    //setTimeout(function(){return true;},10000);
    //[self stringByEvaluatingJavaScriptFromString:@"window.alert = function(message) {setTimeout(function(){return true;},100000);}"];
    
    //Do invoicing in background
    //if(actualPage<[invoicePagesArray count] && !startInvoicing){
        //[self performSelectorInBackground:@selector(fillPagesInBackground) withObject:nil];
        //[self fillPagesInBackground];
       /* startInvoicing = TRUE;
    }*/
    //[self startInvoicingWebView];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Cargando otra pagina -----------------");
    
    //[self performSelectorInBackground:@selector(startInvoicingWebView) withObject:nil];
    //start invoicing
    [self startInvoicingWebView];

    //If one web page more (error)
    /*if(actualPage==[invoicePagesArray count]){
        NSLog(@"Ya son las paginas +++++++++++++++++++++++++ %d",[invoicePagesArray count]);
        if(startInvoicing){
            [self validateInvoiceWithStatus:2];
        }
    }*/
    
    //Error to load element
    NSURL *URL = [request URL];
    if ([URL.scheme isEqualToString: @"bwrerrorinvoicing"]) {
        
        //Check if another error had finished before
        if(startInvoicing){
            
            //Get message from alert
            messageAlert = [[[[URL absoluteString] componentsSeparatedByString: @"://"] lastObject] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            //Finish invoicing with error
            [self validateInvoiceWithStatus:2];
        }
    }
    
    return TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    //Check the own scheme
    if([[[[error userInfo] objectForKey:@"NSErrorFailingURLKey"] absoluteString] rangeOfString:@"bwrerrorinvoicing://"].location == NSNotFound){
        
        //Check if another error had finished before
        if(startInvoicing){
            messageAlert = @"Error al cargar la página";
            [self validateInvoiceWithStatus:2];
        }
    }
}

#pragma mark - WebInvoiceViewConetroller Sources
-(void) startInvoicingWebView{
    [self stringByEvaluatingJavaScriptFromString:@"window.alert = function(message) { var messageError = \"bwrerrorinvoicing://\" + message; \n messageError = messageError.replace(/\\s/g,\"_\"); \n  window.location = messageError; }"];
    
    //Do invoicing in background
    if(actualPage<[invoicePagesArray count] && !startInvoicing){
        [self performSelectorInBackground:@selector(executeJavaScriptFromWebPage) withObject:nil];
        //[self performSelectorOnMainThread:@selector(fillPagesInBackground) withObject:nil waitUntilDone:YES];
        //[self fillPagesInBackground];
        //[self executeJavaScriptFromWebPage];
        startInvoicing = TRUE;
    }
    
}

/*-(void) fillPagesInBackground {
    
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
        NSThread *threadLoad = [[NSThread alloc] initWithTarget:self selector:@selector(executeJavaScriptFromWebPage) object:nil];
        [threadLoad start];
        
        [self executeJavaScriptFromWebPage];
        //[self performSelectorOnMainThread:@selector(executeJavaScriptFromWebPage) withObject:nil waitUntilDone:YES];
        //#### background task ends
        
        //Clean up code. Tell the system that we are done.
        [application endBackgroundTask: background_task];
    });
        
}*/

- (void) validateInvoiceWithStatus: (int)status{
    
    NSString *statusString;
    NSString *message;
    
    startInvoicing = FALSE;
    
    switch (status) {
        case 0:     //Invoice rigth
            statusString = @"Facturada";
            message = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"Ticket facturado.",nil), NSLocalizedString(@"Estado: ",nil), NSLocalizedString(statusString,nil)];
            break;
            
        case 1:     //Invoice pending
            statusString = @"Pendiente";
            message = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"Ticket no facturado.",nil), NSLocalizedString(@"Estado: ",nil), NSLocalizedString(statusString,nil)];
            break;
            
        default:    //Invoice failed
            loadError = TRUE;
            statusString = @"Fallida";
            message = @"Error de facturación";
            NSLog(@"Error: %@", messageAlert);
            break;
    }
    
    [BWRMessagesToUser Notification:message withIdentifier:statusString];
    [completeInvoice updateCompleteInvoiceWithRFC:completeInvoice.rfc status:statusString];
}


#pragma  mark - JavaScript
- (void) executeJavaScriptFromWebPage{
    int status = 0; //Facturada
    
   //Fill and send all forms
    for (int index=actualPage; index<[invoicePagesArray count]; index++){
        BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:index];
        
        //Get javascript code
        NSString *javascript = [self createJavaScriptStringWithRules:invoicePage.rules];
        
        //Validate elements
        //[self validateViewTicketElementsInWebPageWithRules:invoicePage.rules];
        
        //Put value of elements
        //[self stringByEvaluatingJavaScriptFromString:javascript];
        [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:javascript waitUntilDone:YES];
        
        if(loadError){
            status = 2;
            //Validate message alert
            if(messageAlert == nil){
                messageAlert = @"Error al ejecutar javascript";
            }
            break;
        }
        actualPage++;
    }
        
    //Finish invoicing
    NSLog(@"Esperando otros errores");
    [NSThread sleepForTimeInterval:5];
    if(startInvoicing){
        [self validateInvoiceWithStatus:status];
    }
    
    
}

-(void)stringByEvaluatingJavaScriptFromString:(NSString *)javascript
{
    if([invoiceWebView stringByEvaluatingJavaScriptFromString:javascript]!=nil){
        NSLog(@"Java Script ejecutado");
    }else{
        NSLog(@"Java Script FALLO");
        loadError = TRUE;
    }
    
}

- (NSString *) createJavaScriptStringWithRules: (NSArray *)invoicePageRules{
    
    [NSThread sleepForTimeInterval:9];
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
            //Validate element in page
            [javascript appendFormat:@"if(document.getElementById('%@') == null){ alert(\"Elemento aun no esta cargado en la pagina\");}else{", viewElement.formField];
            
            //Put value element
            [javascript appendFormat:@"document.getElementById('%@').value = '%@';\n", viewElement.formField, viewElement.selectionValue];
            
            //Close else
            [javascript appendString:@"}"];
        }
    }
    
    [javascript appendString:@"})()"];
    //NSLog(@"%@", javascript);
    return javascript;
}

/*- (void) validateViewTicketElementsInWebPageWithRules:  (NSArray *)invoicePageRules{
    
    NSMutableString *javascript = [[NSMutableString alloc] initWithString:@"javascript:(function() {\n"];
    
    for(BWRTicketViewElement *viewElement in invoicePageRules){
        //ticket or user info
        if([viewElement.formFieldType isEqualToString:@"user_info"] || [viewElement.formFieldType isEqualToString:@"ticket_info"] ){
            
            //Validate element in page
            [javascript appendFormat:@"if(document.getElementById('%@') == null){ window.location = \"ERROR ELEMENT\";\n location.reload(true);}", viewElement.formField];
        }
    }
    
    [javascript appendString:@"})()"];
    
    [self stringByEvaluatingJavaScriptFromString:javascript];
}*/

#pragma mark - Notification
- (void) alertNotificationWithState: (NSString *)status{
    
    UIAlertView *alertView;
    //Status is failed
    if([status isEqualToString:@"Fallida"]){
         alertView= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error de facturación",nil)
                                                            message:NSLocalizedString(@"La facturación tuvo un error. ¿Desea verlo?",nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Después",nil)
                                                  otherButtonTitles:NSLocalizedString(@"Ver",nil), nil];
    }
    //Status is right or pending
    else{
        [BWRMessagesToUser Alert:NSLocalizedString(@"Ticket facturado.",nil) message:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Estado: ",nil), NSLocalizedString(status,nil)]];
    }
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Button selection
    switch(buttonIndex) {
        case 0: //"More later" pressed
            break;
        case 1: //"See" pressed
            if([UIApplication sharedApplication].applicationIconBadgeNumber != 0){
                [UIApplication sharedApplication].applicationIconBadgeNumber--; //Decrement notification badge
            }
            [self showWebViewController];
            [BWRMessagesToUser Alert:@"Error de facturación" message:messageAlert];
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
