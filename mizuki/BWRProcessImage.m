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
    OpenCV *opencv = [[OpenCV alloc] init];
    UIImage *image_result = [UIImage imageNamed:@"starbucks_con_dobles.jpg"];
    
    if(!processImage){
        return @"Error";
    }
    
    //Mejorar la imagen
    //UIImage *image_erode = [opencv generateDilateImageFromUIImage:processImage];
    UIImage *image_erode = [opencv generateDilateImageFromUIImage:image_result];
    processImage = [opencv generateBinaryImageFromUIImage:image_erode];
    
    //Reconocer texto
    [tesseract setImage: processImage];
    [tesseract recognize];
    NSString *result = [tesseract recognizedText];
    NSLog(@"%@", result);
    
    //Liberar memoria
    tesseract = nil; //deallocate and free all memory
    
    
    return result;
    
}


@end