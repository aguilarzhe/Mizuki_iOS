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
@property NSURLConnection *urlConnection;

@end

@implementation WebInvoiceViewController

@synthesize invoicePagesArray;
@synthesize invoiceWebView;
@synthesize companyURL;
@synthesize actualPage;
@synthesize theResponse;
@synthesize dataRecive;
@synthesize urlConnection;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    invoiceWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    invoiceWebView.delegate = self;
    [self.view addSubview:invoiceWebView];
    
    //load url into webview
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:companyURL];
    //urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [invoiceWebView loadRequest:urlRequest];
    
    //invoiceWebView.suppressesIncrementalRendering = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIWebViewDelegate
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelectorInBackground:@selector(fillPagesAccordingToService) withObject:nil];
    //[self fillPagesAccordingToService];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"\n\n**************REQUEST URL: %@   COMPANY URL: %@\n\n", request.URL, companyURL);
    
    return TRUE;
}

/*#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    theResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [dataRecive appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    CGFloat percentage = (dataRecive.length*100)/theResponse.expectedContentLength;
    NSLog(@"PORCENTAJE: %f", percentage);
}*/

#pragma mark - WebInvoiceViewConetroller Sources
-(void) fillPagesAccordingToService {
    
    [self performSelectorOnMainThread:@selector(executeJavaScriptFromWebPageDiv) withObject:nil waitUntilDone:YES];
    //[self executeJavaScriptFromWebPageDiv];
}

- (void) executeJavaScriptFromWebPageDiv{
    
    //for (BWRInvoiceTicketPage *invoicePage in invoicePagesArray){
    for (int index=actualPage; index<[invoicePagesArray count]; index++){
        BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:index];
        //BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:actualPage];
        NSString *javascript = [self createJavaScriptStringWithRules:invoicePage.rules];
        
        if([invoiceWebView stringByEvaluatingJavaScriptFromString:javascript]){
            NSLog(@"Java Script ejecutado");
        }else{
            NSLog(@"Java Script FALLO");
        }
        
        NSLog(@"\n\n++++++++++LOADING: %hhd \n\n", invoiceWebView.loading);
        
        if(![invoiceWebView.request.URL isEqual:companyURL]){
            //break;
        }
        
        [NSThread sleepForTimeInterval:15];
        actualPage++;
        //[self viewDidLoad];
        
    }
}

- (NSString *) createJavaScriptStringWithRules: (NSArray *)invoicePageRules{
    
    NSMutableString *javascript = [[NSMutableString alloc] initWithString:@"javascript:(function() {\n"];
    
    for(BWRTicketViewElement *viewElement in invoicePageRules){
        if ([viewElement.tipoCampoFormulario isEqualToString:@"submit"]) {
            [javascript appendFormat:@"document.getElementById('%@').click();\n", viewElement.campoFormulario];
        }else{
            //NSLog(@"Elemento %@ valor: %@", viewElement.campoTicket, viewElement.selectionValue);
            [javascript appendFormat:@"document.getElementById('%@').value = '%@';\n", viewElement.campoFormulario, viewElement.selectionValue];
        }
    }
    
    [javascript appendString:@"})()"];
    NSLog(@"%@", javascript);
    return javascript;
}






@end
