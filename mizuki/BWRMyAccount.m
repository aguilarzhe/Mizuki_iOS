//
//  BWRMyAccount.m
//  mizuki
//
//  Created by Efrén Aguilar on 7/2/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRMyAccount.h"

@interface BWRMyAccount () <UITableViewDelegate, UITableViewDataSource>
@property UITableView *rfcTableView;
@property UITableView *userInfoTableView;
@property NSArray *dummyRFCArray;
@property NSDictionary *dummyUserInfoDictionary;
@end

@implementation BWRMyAccount
@synthesize rfcTableView, userInfoTableView;
@synthesize dummyRFCArray, dummyUserInfoDictionary;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self initializeDummyDataSources];
    
    // Tabla de información de usuario
    UILabel *userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 60.0f, self.view.frame.size.width, 44.0f)];
    userInfoLabel.text = @"Datos de usuario";
    [self.view addSubview:userInfoLabel];
    
    userInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, self.view.frame.size.width, (44 * dummyUserInfoDictionary.count)) style:UITableViewStylePlain];
    userInfoTableView.scrollEnabled = NO;
    userInfoTableView.dataSource = self;
    userInfoTableView.delegate = self;
    [self.view addSubview:userInfoTableView];
    
    // Tabla de RFC
    UILabel *rfcLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 195.0f, 100.0f, 44.0f)];
    rfcLabel.text = @"RFC";
    [self.view addSubview:rfcLabel];
    
    rfcTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 230.0f, self.view.frame.size.width, (44 * (dummyRFCArray.count + 1))) style:UITableViewStylePlain];
    rfcTableView.scrollEnabled = NO;
    rfcTableView.dataSource = self;
    rfcTableView.delegate = self;
    [self.view addSubview:rfcTableView];
    
    // Configuración de vista
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"Mi cuenta";
}

-(void)initializeDummyDataSources{
    
    dummyRFCArray = @[@"AUZH900820SI1", @"BAW1234566"];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSString *email, *levelAccount;
    if(!(email = [userDefaults valueForKey:@"Correo"])){
        NSLog(@"Setting email");
        [userDefaults setValue:@"aguilarzhe@gmail.com" forKey:@"Correo"];
        email = [userDefaults valueForKey:@"Correo"];
    }
    if(!(levelAccount = [userDefaults valueForKey:@"Tipo cuenta"])){
        [userDefaults setValue:@"Premium" forKey:@"Tipo cuenta"];
        levelAccount = [userDefaults valueForKey:@"Tipo cuenta"];
    }

    
    dummyUserInfoDictionary = [[NSDictionary alloc]initWithObjects:@[email, levelAccount] forKeys:@[@"Correo", @"Tipo cuenta"]];
    
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if(tableView == rfcTableView){
        numberOfRows = [dummyRFCArray count] + 1;
    }else if(tableView == userInfoTableView){
        numberOfRows = [dummyUserInfoDictionary count];
    }
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if(tableView == rfcTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RFC"];
        if (indexPath.row < dummyRFCArray.count) {
            cell.textLabel.text = dummyRFCArray[indexPath.row];
        }else{
            cell.textLabel.text = @"Agregar RFC";
        }
    }else if(tableView == userInfoTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"USERINFO"];
        cell.textLabel.text = [dummyUserInfoDictionary allKeys][indexPath.row];
        cell.detailTextLabel.text = dummyUserInfoDictionary[cell.textLabel.text];
    }

    return cell;
}


@end