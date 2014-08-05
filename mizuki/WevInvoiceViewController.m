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
//-(void) webInvoiceDataLoad
{
    //Obtener elementos de la pagina actual
    BWRInvoiceTicketPage *invoicePage = [invoicePagesArray objectAtIndex:actualPage];
    for(BWRTicketViewElement *viewElement in invoicePage.rules){
        
        NSString *javaScript;
        //Si es el boton
        if ([viewElement.tipoCampoFormulario isEqualToString:@"submit"]) {
            self.actualPage++;
            //javaScript = [NSString stringWithFormat:@"javascript:(function() {document.%@.submit();})()", viewElement.campoFormulario];
            javaScript = [NSString stringWithFormat:@"javascript:(function() {document.getElementById('%@').click()})()", viewElement.campoFormulario];
            /*NSURL *urlClick = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"javascript:document.getElementById(\"%@\").click()", viewElement.campoFormulario]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlClick];
            [invoiceWebView loadRequest:urlRequest];*/
        }
        
        //Si es otro campo
        else{
            NSLog(@"Elemento %@ valor: %@", viewElement.campoTicket, viewElement.selectionValue);
            javaScript = [NSString stringWithFormat:@"javascript:(function() {document.getElementById('%@').value = '%@';})()", viewElement.campoFormulario, viewElement.selectionValue];
            
        }
        
        //Ejecutando Javascript
        NSString *result;
        if((result =[invoiceWebView stringByEvaluatingJavaScriptFromString:javaScript])!=nil){
            NSLog(@"Java Script ejecutado : %@", result);
        }else{
            NSLog(@"Java Script FALLO");
        }
        
        
    }
}



@end
