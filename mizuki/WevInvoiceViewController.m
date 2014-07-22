//
//  WevInvoiceViewController.m
//  Webview
//
//  Created by Carolina Mora on 18/07/14.
//  Copyright (c) 2014 Carolina Mora. All rights reserved.
//

#import "WevInvoiceViewController.h"
#import "BWRTicketViewElement.h"

@interface WevInvoiceViewController ()

@property UIWebView *invoiceWebView;

@end

@implementation WevInvoiceViewController

@synthesize ticketViewElementsArray;
@synthesize invoiceWebView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    invoiceWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    invoiceWebView.delegate = self;
    
    
    //load url into webview
    NSString *strURL = @"https://alsea.interfactura.com/RegistroDocumento.aspx?opc=Starbucks";
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
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
    for(BWRTicketViewElement *viewElement in ticketViewElementsArray){
        NSString *javaScript = [NSString stringWithFormat:@"javascript:(function() {document.getElementById('%@').value = '%@';})()", viewElement.campoFormulario, viewElement.selectionValue];
        if(
           [invoiceWebView stringByEvaluatingJavaScriptFromString:javaScript]){
            NSLog(@"Java Script ejecutado");
        }else{
            NSLog(@"Java Script FALLO");
        }
    }
}



@end
