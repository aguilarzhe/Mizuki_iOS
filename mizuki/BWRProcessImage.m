//
//  BWRProcessImage.m
//  mizuki
//
//  Created by Carolina Mora on 12/06/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRProcessImage.h"

@interface BWRProcessImage ()

@property UIImage *processImage;

@end


@implementation BWRProcessImage

@synthesize processImage;

-(BWRProcessImage *)initWithImage:(UIImage *)imageReceived;
{
    processImage = imageReceived;
    return [super init];
}

-(NSString *)processRecognitionOCR;
{
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"spa"];
    
    //Pruebas
    //[tesseract setImage:[UIImage imageNamed:@"starbucks_liso.jpg"]];
    
    //Ejecución normal
    [tesseract setImage:processImage];
    
    [tesseract recognize];
    
    NSString *result = [tesseract recognizedText];
    NSLog(@"%@", result);
    
    tesseract = nil; //deallocate and free all memory
    
    return result;
    
}


@end