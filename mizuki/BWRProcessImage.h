//
//  BWRProcessImage.h
//  mizuki
//
//  Created by Carolina Mora on 12/06/14.
//  Copyright (c) 2014 Baware S.A. de C.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tesseract.h"
#import "OpenCV.h"

@interface BWRProcessImage : NSObject

@property UIImage *processImage;

-(BWRProcessImage *)initWithImage:(UIImage *)imageReceived;
-(NSString *)processRecognitionOCR;

@end