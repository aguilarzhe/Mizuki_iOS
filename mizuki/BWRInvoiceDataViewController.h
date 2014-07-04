//
//  BWRInvoiceDataViewController.h
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWRInvoiceDataViewController : UIViewController

@property UITextField *tf_rfc;
@property UITextField *tf_nombre;
@property UITextField *tf_apaterno;
@property UITextField *tf_amaterno;
@property UITextField *tf_calle;
@property UITextField *tf_noint;
@property UITextField *tf_noext;
@property UITextField *tf_colonia;
@property UITextField *tf_delegacion;
@property UITextField *tf_estado;
@property UITextField *tf_ciudad;
@property UITextField *tf_localidad;
@property UITextField *tf_cp;

@property UILabel *lb_facturacion;
@property UILabel *lb_direccion;
@property UIBarButtonItem *bt_listo;


- (BWRInvoiceDataViewController *)initWithDefault: (NSString *)title;
- (BWRInvoiceDataViewController *)initWithNSDictionary:(NSDictionary *)dictionary title:(NSString *)title;

@end
