//
//  TodayViewController.m
//  Mizuki-Widget
//
//  Created by Carolina Mora on 07/09/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "BWRInvoiceHistoryViewController.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //rezise
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 50);
    
    //Tool bar
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 10, self.view.frame.size.width-40, 40);
    
    //Button intem - invoices
    UIBarButtonItem *invoicesButton = [[UIBarButtonItem alloc] initWithTitle:@"Mis facturas" style:UIBarButtonItemStylePlain target:self action:@selector(invoiceWithHistory)];
    //Button item - galery
    UIBarButtonItem *camaraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(invoiceWithCamara)];
    //Button item - data
    UIBarButtonItem *dataButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(invoiceWithData)];
    //Button item - camara
    UIBarButtonItem *galeryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(invoiceWithGalery)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //add button items
    toolbar.items = @[flexibleItem, invoicesButton, camaraButton, dataButton, galeryButton];
    toolbar.barTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    [self.view addSubview:toolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

- (void)invoiceWithCamara {
    NSURL *url = [NSURL URLWithString:@"com.baware.mizuki://?token=9204265553"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (void)invoiceWithData {
    
}

- (void)invoiceWithGalery {
    
}

- (void)invoiceWithHistory {
    
}

@end
