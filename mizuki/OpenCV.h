//
//  OpenCV.h
//  mizuki
//
//  Created by Carolina Mora on 18/06/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/highgui/highgui.hpp>


@interface OpenCV : NSObject

- (UIImage *)generateBinaryImageFromUIImage: (UIImage *) image;
- (UIImage *)generateDilateImageFromUIImage: (UIImage *) image;
- (UIImage *)improveImageFromUIImage: (UIImage *) image;
- (UIImage *)blurFilterImageFromUIImage: (UIImage *) image;

@end