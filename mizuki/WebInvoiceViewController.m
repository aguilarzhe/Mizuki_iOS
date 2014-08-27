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

@interface WebInvoiceViewController ()

@property UIWebView *invoiceWebView;
@property NSURLResponse *theResponse;
@property NSMutableData *dataRecive;
@property NSError *loadError;

@end

@implementation WebInvoiceViewController

@synthesize invoicePagesArray;
@synthesize invoiceWebView;
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
    
    //load url into webview
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:companyURL];
    [invoiceWebView loadRequest:urlRequest];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIWebViewDelegate
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    // TODO: Change performSelectorInBackground to dispatch_async and dispatch_queue_t
    [self performSelectorInBackground:@selector(executeJavaScriptFromWebPageDiv) withObject:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    return TRUE;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    loadError = error;
}

#pragma mark - WebInvoiceViewConetroller Sources
-(void) fillPagesAccordingToService {
    
    [self performSelectorOnMainThread:@selector(executeJavaScriptFromWebPageDiv) withObject:nil waitUntilDone:YES];
}

- (void) executeJavaScriptFromWebPageDiv{
    
    for (int index=actualPage; index<[invoicePagesArray count]; index++){
        BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:index];
        NSString *javascript = [self createJavaScriptStringWithRules:invoicePage.rules];
        [self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:javascript waitUntilDone:YES];
        
        [NSThread sleepForTimeInterval:3];
        actualPage++;
    }
    
    //Update invoice with new status
    NSString *status = @"Facturada";
    if(loadError){
        status = @"Error";
    }
    [completeInvoice updateCompleteInvoiceWithRFC:completeInvoice.rfc status:status];
    
    [self performSegueWithIdentifier:@"InvoiceCompleteSegue" sender:self];
    
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
        }else{
            [javascript appendFormat:@"document.getElementById('%@').value = '%@';\n", viewElement.formField, viewElement.selectionValue];
        }
    }
    
    [javascript appendString:@"})()"];
    NSLog(@"%@", javascript);
    return javascript;
}






@end
