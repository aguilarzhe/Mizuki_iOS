//
//  BWRMail.m
//  mizuki
//
//  Created by Carolina-iOS on 25/11/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRMail.h"
#import "BWRMessagesToUser.h"

@interface BWRMail ()

@property UIViewController<MFMailComposeViewControllerDelegate> *actualViewController;
@property NSData *imageMail;

@end


NSString *emailSupport = @"skyla1504@hotmail.com";

@implementation BWRMail

@synthesize rfcData;
@synthesize imageMail;


-(BWRMail*) initWithRFC: (BWRRFCInfo *)rfc image:(UIImage *)image context:(UIViewController<MFMailComposeViewControllerDelegate> *)controller{
    self = [super init];
    
    rfcData = rfc;
    _actualViewController = controller;
    imageMail = [NSData dataWithData:UIImagePNGRepresentation(image)];
    
    return self;
}

- (void) showEmailWithCompany: (NSString *)company {
    //Can send email
    if ([MFMailComposeViewController canSendMail]){
        // Email Subject
        NSString *emailTitle = company;
        // Email Content
        NSString *messageBody = [self getFormatFromRFC];
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:emailSupport];
        
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = _actualViewController;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        [mc addAttachmentData:imageMail mimeType:@"PNG" fileName:@"TicketPhoto.png"];
        
        // Present mail view controller on screen
        [_actualViewController presentViewController:mc animated:YES completion:NULL];
    }
    
    else{
        NSLog(@"This device cannot send email. Please, configure email in Mail application.");
        [BWRMessagesToUser Alert:@"No se puede enviar correo" message:@"Por favor configure un correo en la aplicación Mail"];
    }
    
}


- (NSString *) getFormatFromRFC {
    NSString *RFCformat = [NSString stringWithFormat:
                           @"RFC: %@\nNombre: %@\nPaís: %@\nEstado: %@\nDelegación: %@\nColonia: %@\nCalle: %@\nNúmero Interior: %@\nNúmero Exterior: %@\nCódigo Postal: %@\nCiudad: %@",
                           rfcData.rfc,
                           rfcData.nombre,
                           rfcData.pais,
                           rfcData.estado,
                           rfcData.delegacion,
                           rfcData.colonia,
                           rfcData.calle,
                           rfcData.numInterior,
                           rfcData.numExterior,
                           rfcData.codigoPostal,
                           rfcData.ciudad];
    return RFCformat;
}

- (void) didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            [BWRMessagesToUser Alert:@"Correo cancelado" message:@"No se ha enviado solicitud de tienda nueva"];
            break;
        case MFMailComposeResultSaved:
            [BWRMessagesToUser Alert:@"Correo guardado" message:@"No se ha enviado solicitud de tienda nueva"];
            break;
        case MFMailComposeResultSent:
            [BWRMessagesToUser Alert:@"Correo enviado" message:@"Se ha enviado solicitud de tienda nueva"];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            [BWRMessagesToUser Alert:@"Error de envío" message:@"El correo tuvo un error al ser enviado"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [_actualViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
