//
//  BWRProcessImage.m
//  mizuki
//
//  Created by Carolina Mora on 12/06/14.
//  Copyright (c) 2014 Baware S.A. de C.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWRProcessImage.h"

@interface BWRProcessImage ()


@end


@implementation BWRProcessImage

@synthesize processImage;

-(BWRProcessImage *)initWithImage:(UIImage *)imageReceived;
{
    self = [super init];
    processImage = gs_convert_image(imageReceived);
    return self;
}

-(NSString *)processRecognitionOCR;
{
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"spa"];
    OpenCV *opencv = [[OpenCV alloc] init];
    //UIImage *image_result = [UIImage imageNamed:@"starbucks_con_dobles.jpg"];
    
    if(!processImage){
        return @"Error";
    }
    
    //Improve image
    processImage = [opencv improveImageFromUIImage:processImage];
    //processImage = [opencv improveImageFromUIImage:image_result];

    
    if(!processImage){
        return @"Imagen demasiado obscura o demasiado clara";
    }
    
    //Recognize text
    [tesseract setImage: processImage];
    [tesseract recognize];
    NSString *result = [tesseract recognizedText];
    NSLog(@"%@", result);
    
    //Free memory
    tesseract = nil; //deallocate and free all memory
    
    return result;
    
}

// this does the trick to have tesseract accept the UIImage.
UIImage * gs_convert_image (UIImage * src_img) {
    CGColorSpaceRef d_colorSpace = CGColorSpaceCreateDeviceRGB();
    /*
     * Note we specify 4 bytes per pixel here even though we ignore the
     * alpha value; you can't specify 3 bytes per-pixel.
     */
    size_t d_bytesPerRow = src_img.size.width * 4;
    unsigned char * imgData = (unsigned char*)malloc(src_img.size.height*d_bytesPerRow);
    CGContextRef context =  CGBitmapContextCreate(imgData, src_img.size.width,
                                                  src_img.size.height,
                                                  8, d_bytesPerRow,
                                                  d_colorSpace,
                                                  (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    UIGraphicsPushContext(context);
    // These next two lines 'flip' the drawing so it doesn't appear upside-down.
    CGContextTranslateCTM(context, 0.0, src_img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    // Use UIImage's drawInRect: instead of the CGContextDrawImage function, otherwise you'll have issues when the source image is in portrait orientation.
    [src_img drawInRect:CGRectMake(0.0, 0.0, src_img.size.width, src_img.size.height)];
    UIGraphicsPopContext();
    
    /*
     * At this point, we have the raw ARGB pixel data in the imgData buffer, so
     * we can perform whatever image processing here.
     */
    
    
    // After we've processed the raw data, turn it back into a UIImage instance.
    CGImageRef new_img = CGBitmapContextCreateImage(context);
    UIImage * convertedImage = [[UIImage alloc] initWithCGImage:
                                new_img];
    
    CGImageRelease(new_img);
    CGContextRelease(context);
    CGColorSpaceRelease(d_colorSpace);
    free(imgData);
    return convertedImage;
}


@end