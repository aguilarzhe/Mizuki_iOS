//
//  BWRProcessImage.h
//  mizuki
//
//  Created by Carolina Mora on 12/06/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tesseract.h"

@interface BWRProcessImage : NSObject

-(BWRProcessImage *)initWithImage:(UIImage *)imageReceived;
-(NSString *)processRecognitionOCR;

@end