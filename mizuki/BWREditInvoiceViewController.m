//
//  BWREditInvoiceViewController.m
//  mizuki
//
//  Created by Carolina Mora on 16/08/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWREditInvoiceViewController.h"
#import "BWRTicketViewElement.h"

@interface BWREditInvoiceViewController ()

@property UITableView *rfcTableView;
@property UITextField *companyTextField;
@property UIImageView *ticketImage;
@property UITextView *ocrLabel;
@property UIScrollView *ticketScrollView;

@end

@implementation BWREditInvoiceViewController

@synthesize completeInvoice;
@synthesize typeInvoice;
@synthesize rfcTableView;
@synthesize companyTextField;
@synthesize ticketImage;
@synthesize ocrLabel;
@synthesize ticketScrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Medidas
    NSInteger widthScreen = self.view.frame.size.width;
    NSInteger heightScreen = self.view.frame.size.height;
    NSInteger height = 44;
    NSInteger padding = 10;
    NSInteger depth = 0;
    NSInteger width = widthScreen-(2*padding);
    
    //Company TextField
    companyTextField = [[UITextField alloc] initWithFrame:CGRectMake(padding, depth+=height+20, width, height)];
    companyTextField.borderStyle = UITextBorderStyleRoundedRect;
    companyTextField.text = completeInvoice.company;
    companyTextField.delegate = self;
    [self.view addSubview:companyTextField];
    
    //Image view
    ticketImage = [[UIImageView alloc] initWithFrame:CGRectMake(padding, depth+=height+10, 100, 100.0f)];
    [ticketImage setContentMode:UIViewContentModeScaleToFill];
    ticketImage.image = completeInvoice.image;
    [self.view addSubview:ticketImage];
    
    //OCRLabel
    ocrLabel = [[UITextView alloc] initWithFrame:CGRectMake(padding, depth+=100+10, width, 100)];
    ocrLabel.editable = NO;
    ocrLabel.scrollEnabled = YES;
    ocrLabel.text = completeInvoice.resultOCR;
    [self.view addSubview:ocrLabel];
    
    //Scroll View
    ticketScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, depth+=100+10, widthScreen-10, heightScreen-100)];
    ticketScrollView.contentSize=CGSizeMake(widthScreen,heightScreen);
    ticketScrollView.hidden = NO;
    [self inicializeViewTicketElementsArray];
    [self.view addSubview:ticketScrollView];
    
    //Send Button
    UIBarButtonItem *bt_send = [[UIBarButtonItem alloc] initWithTitle:@"Enviar" style:UIBarButtonItemStylePlain target:self action:@selector(updateInvoice)];
    self.navigationItem.rightBarButtonItem = bt_send;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BWREditInvoiceViewController Sources
-(void)updateInvoice{
    
    for(BWRTicketViewElement *viewElement in completeInvoice.rulesViewElementsArray){
        if ([viewElement.viewTicketElement isKindOfClass:[UITextField class]]){
            viewElement.selectionValue = ((UITextField *)viewElement.viewTicketElement).text;
        }
    }
    
    [completeInvoice ADUCompleteInvoiceWithAction:2 status:@"Pendiente"];
    
}

-(void)inicializeViewTicketElementsArray{
    
    //Medidas
    NSInteger widthScreen = self.view.frame.size.width;
    NSInteger height = 44;
    NSInteger padding = 10;
    NSInteger depth = 0;
    NSInteger width = widthScreen-(2*padding);
    
    for(BWRTicketViewElement *viewElement in completeInvoice.rulesViewElementsArray){
        [viewElement createViewWithRect:padding y:depth width:width height:height/**[ticketViewElement.valueCampoTicket count]*/ delegate:self];
        ((UITextField *)viewElement.viewTicketElement).text = viewElement.selectionValue;
        [ticketScrollView addSubview:viewElement.viewTicketElement];
        depth = depth + (height /** [ticketViewElement.valueCampoTicket count]*/) +10;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
