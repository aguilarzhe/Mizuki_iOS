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
#import "BWRWebConnection.h"

@interface WebInvoiceViewController ()

//@property UIWebView *invoiceWebView;
@property NSURLResponse *theResponse;
@property NSMutableData *dataRecive;
@property BOOL loadError;

@end

static UIWebView *invoiceWebView;

@implementation WebInvoiceViewController

@synthesize invoicePagesArray;
//@synthesize invoiceWebView;
@synthesize companyURL;
@synthesize actualPage;
@synthesize theResponse;
@synthesize dataRecive;
@synthesize completeInvoice;
@synthesize loadError;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    //If there is't conection or doesn't correspond
    else{
        if([completeInvoice addCompleteInvoiceWithStatus:@"Pendiente"]){
            NSLog(@"SE REALIZO EL ADD CORRECTAMENTE: %@", completeInvoice.idInvoice);
        }else{
            NSLog(@"ERROR EN EL ADD");
        }
        //[completeInvoice updateCompleteInvoiceWithRFC:completeInvoice.rfc status:@"Pendiente"];
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
    // TODO: Change performSelectorInBackground to dispatch_async and dispatch_queue_t
    //[self performSelectorInBackground:@selector(executeJavaScriptFromWebPageDiv) withObject:nil];
    [self performSelectorInBackground:@selector(fillPagesAccordingToService) withObject:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    if(actualPage==[invoicePagesArray count]){
        NSLog(@"Ya son las paginas +++++++++++++++++++++++++ %d",[invoicePagesArray count]);
        //loadError = TRUE;
        [completeInvoice updateCompleteInvoiceWithRFC:completeInvoice.rfc status:@"Pendiente"];
        return FALSE;
    }
    return TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"ERROR: %@", error);
    loadError = TRUE;
    [completeInvoice addCompleteInvoiceWithStatus:@"Pendiente"];
}

#pragma mark - WebInvoiceViewConetroller Sources
-(void) fillPagesAccordingToService {
    
    [self performSelectorOnMainThread:@selector(executeJavaScriptFromWebPageDiv) withObject:nil waitUntilDone:YES];
}

- (void) executeJavaScriptFromWebPageDiv{
    
    //Fill and send all forms
    //if(!loadError){
        for (int index=actualPage; index<[invoicePagesArray count]; index++){
            BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:index];
            NSString *javascript = [self createJavaScriptStringWithRules:invoicePage.rules];
            //[self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:javascript waitUntilDone:YES];
            [self stringByEvaluatingJavaScriptFromString:javascript];
            [NSThread sleepForTimeInterval:3];
            actualPage++;
        }
    //}
    
    //Finish invoicing
    //Update invoice with new status
    NSString *status = @"Facturada";
    /*if(loadError){
        status = @"Pendiente";
    }*/
    [completeInvoice addCompleteInvoiceWithStatus:status];
    NSLog(@"Se agregó la factura------------------------------------------");
    //[self goToInvoiceHistory];
    
}

-(void)stringByEvaluatingJavaScriptFromString:(NSString *)javascript
{
    if([invoiceWebView stringByEvaluatingJavaScriptFromString:javascript]){
        NSLog(@"Java Script ejecutado");
    }else{
        NSLog(@"Java Script FALLO");
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

-(void)goToInvoiceHistory{
    
    //Update invoice with new status
    /*NSString *status = @"Facturada";
    if(loadError){
        status = @"Pendiente";
    }*/
    
    //if([completeInvoice updateCompleteInvoiceWithRFC:completeInvoice.rfc status:status]){
        //Go to history
        [self performSegueWithIdentifier:@"InvoiceCompleteSegue" sender:self];
    //}
    
}




@end
