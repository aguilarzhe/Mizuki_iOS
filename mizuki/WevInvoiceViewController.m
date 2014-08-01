//
//  WevInvoiceViewController.m
//  Webview
//
//  Created by Carolina Mora on 18/07/14.
//  Copyright (c) 2014 Carolina Mora. All rights reserved.
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
    // Dispose of any resources that can be recreated.
}


- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //Obtener elementos de la pagina actual
    BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:actualPage];
    //NSLog(@"page %d rules: %@", actualPage, invoicePage.rules);
    for(BWRTicketViewElement *viewElement in invoicePage.rules){
        
        NSString *javaScript;
        //Si es el boton
        if ([viewElement.dataSource isEqualToString:@"submit"]) {
            self.actualPage++;
            javaScript = [NSString stringWithFormat:@"javascript:(function() {document.%@.submit();})()", viewElement.campoFormulario];
        }
        
        //Si es otro campo
        else{
            NSLog(@"Elemento %@ valor: %@", viewElement.campoTicket, viewElement.selectionValue);
            javaScript = [NSString stringWithFormat:@"javascript:(function() {document.getElementById('%@').value = '%@';})()", viewElement.campoFormulario, viewElement.selectionValue];
        }
        
        if([invoiceWebView stringByEvaluatingJavaScriptFromString:javaScript]){
            NSLog(@"Java Script ejecutado");
        }else{
            NSLog(@"Java Script FALLO");
        }
    }
}



@end
