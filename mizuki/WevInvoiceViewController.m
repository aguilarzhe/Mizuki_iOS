//
//  WevInvoiceViewController.m
//  Webview
//
//  Created by Carolina Mora on 18/07/14.
//  Copyright (c) 2014 Baware SA de CV. All rights reserved.
//

#import "WevInvoiceViewController.h"
#import "BWRTicketViewElement.h"
#import "BWRInvoiceTicketPage.h"

@interface WevInvoiceViewController ()

@property UIWebView *invoiceWebView;

@end

@implementation WevInvoiceViewController

@synthesize invoicePagesArray;
@synthesize invoiceWebView;
@synthesize companyURL;
@synthesize actualPage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    invoiceWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    invoiceWebView.delegate = self;
    
    
    //load url into webview
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:companyURL];

    [invoiceWebView loadRequest:urlRequest];
    
    [self.view addSubview:invoiceWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIWebViewDelegate
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //[self performSelectorInBackground:@selector(fillPagesAccordingToService) withObject:nil];
    [self fillPagesAccordingToService];
}

- (NSString *) createJavaScriptStringWithRules: (NSArray *)invoicePageRules{
    
    NSMutableString *javascript = [[NSMutableString alloc] initWithString:@"javascript:(function() {\n"];
    
    for(BWRTicketViewElement *viewElement in invoicePageRules){
        if ([viewElement.tipoCampoFormulario isEqualToString:@"submit"]) {
            //self.actualPage++;
            [javascript appendFormat:@"document.getElementById('%@').click();\n", viewElement.campoFormulario];
        }else{
            NSLog(@"Elemento %@ valor: %@", viewElement.campoTicket, viewElement.selectionValue);
            [javascript appendFormat:@"document.getElementById('%@').value = '%@';\n", viewElement.campoFormulario, viewElement.selectionValue];
        }
    }
    
    [javascript appendString:@"})()"];
    NSLog(@"%@", javascript);
    return javascript;
}

- (void) executeJavaScriptFromWebPageDiv{
    
    //for (BWRInvoiceTicketPage *invoicePage in invoicePagesArray){
    BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:actualPage];
        NSString *javascript = [self createJavaScriptStringWithRules:invoicePage.rules];
        
        if([invoiceWebView stringByEvaluatingJavaScriptFromString:javascript]){
            NSLog(@"Java Script ejecutado");
        }else{
            NSLog(@"Java Script FALLO");
        }
        [NSThread sleepForTimeInterval:10];
    actualPage++;
        [self viewDidLoad];
        
    //}
}

-(void) fillPagesAccordingToService {
    
    //[self performSelectorOnMainThread:@selector(executeJavaScriptFromWebPageDiv) withObject:nil waitUntilDone:NO];
    [self executeJavaScriptFromWebPageDiv];
}



@end
