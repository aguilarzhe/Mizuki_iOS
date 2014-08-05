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
    NSMutableString *javascript = [[NSMutableString alloc] initWithString:@"javascript:(function() {\n"];
    // Get actual page elements
    BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:actualPage];

    for(BWRTicketViewElement *viewElement in invoicePage.rules){
        if ([viewElement.tipoCampoFormulario isEqualToString:@"submit"]) {
            self.actualPage++;
            [javascript appendFormat:@"document.getElementById('%@').click();\n", viewElement.campoFormulario];
        }else{
            NSLog(@"Elemento %@ valor: %@", viewElement.campoTicket, viewElement.selectionValue);
            [javascript appendFormat:@"document.getElementById('%@').value = '%@';\n", viewElement.campoFormulario, viewElement.selectionValue];
        }
    }
    
    [javascript appendString:@"})()"];
    NSLog(@"%@", javascript);
    if([invoiceWebView stringByEvaluatingJavaScriptFromString:javascript]){
        NSLog(@"Java Script ejecutado");
    }else{
        NSLog(@"Java Script FALLO");
    }
}



@end
