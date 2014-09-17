//
//  OpenCV.m
//  mizuki
//
//  Created by Carolina Mora on 18/06/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenCV.h"

@interface OpenCV ()



@end


@implementation OpenCV


/** Convert UIImage type to cvMat type.
 
 @param image UIImage to convert.
 @return The UIImage converted to cvMat.
 */
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

/** Convert UIImage type to cvMat type and in gray scale.
 
 @param image UIImage to convert.
 @return The UIImage converted to cvMat in gray scale.
 */
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

/** Convert cvMat type to UIImage type.
 
 @param cvMat cvMat to convert.
 @return The cvMat converted to UIImage.
 */
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

/** Generate the image bitarization (white and black).
 
 @param image original UIImage.
 @return The binarized image.
 */
- (UIImage *)generateBinaryImageFromUIImage: (UIImage *) image{
    
    cv::Mat mat_original = [self cvMatFromUIImage:image];
    cv::Mat mat_gray = mat_original.clone();
    cv::Mat mat_binary = mat_original.clone();
    
    cvtColor(mat_original, mat_gray, CV_RGB2GRAY);
    threshold(mat_gray, mat_binary, 150, 255, CV_THRESH_BINARY);
    
    //Free memory
    mat_original.release();
    mat_gray.release();
    
    return [self UIImageFromCVMat:mat_binary];
    
}

/** Get the image dilatation.
 
 @param image UIImage to dilate.
 @return The dilated image.
 */
- (UIImage *)generateDilateImageFromUIImage: (UIImage *) image{
    
    cv::Mat mat_original = [self cvMatFromUIImage:image];
    cv::Mat mat_dilate = mat_original.clone();
    
    //Create mask
    cv::Mat element = getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(7, 7));
    
    //Dilate image
    //dilate(mat_original, mat_dilate, element);
    erode(mat_original, mat_dilate, element);
    
    //Free memory
    mat_original.release();
    
    return [self UIImageFromCVMat:mat_dilate];
    
}

/** Improve the image to tesseract process.
 
 First get the gray scale image, then the histogram to get the image media. According to media value, asign the value of the params for methods: dilatation and binarization.
 
 @param image UIImage to convert.
 @return cvMat The UIImage converted to cvMat.
 */
- (UIImage *)improveImageFromUIImage: (UIImage *) image{
    
    cv::Mat mat_original = [self cvMatFromUIImage:image];
    cv::Mat mat_gray = mat_original.clone();
    cv::Mat mat_binary = mat_original.clone();
    cv::Mat mat_dilate = mat_original.clone();
    
    //Grey scale
    cvtColor(mat_original, mat_gray, CV_RGB2GRAY);
    
    uint8_t* pixelPtr = (uint8_t*)mat_gray.data;
    int histogram[256]={0};
    //double frec_acumulada[256]={0};
    double media = 0;
    int num_pixels = mat_gray.cols*mat_gray.rows;
    
    //Get histogram
    for(int rows = 0; rows < mat_gray.rows; rows++)
    {
        for(int colum = 0; colum < mat_gray.cols; colum++)
        {
            histogram[pixelPtr[rows*mat_gray.cols + colum]]+=1;
            //NSLog(@"Valor: %d", pixelPtr[rows*mat_gray.cols + colum]);
        }
    }
    
    //Get media
    for( int index = 0; index < 256; index++ ){
        media += (index*histogram[index]);
        //printf("%d, ", histogram[index]);
    }
    media = media / num_pixels;
    NSLog(@"Media: %f", media);
    
    //dilatation param y binarization param according to media
    int size_mask = 0;
    int range_inf = 0;
    
    if (media<=60) {
        return nil;
    }else if(media>60 && media<=100){
        size_mask = 3;
        range_inf = 70;
    }else if(media>100 && media<=170){
        size_mask = 5;
        range_inf = 100;
    }else if(media>170 && media <=230){
        size_mask = 7;
        range_inf = 130;
    }else{
        return nil;
    }
    
    //Dilatation
    cv::Mat element = getStructuringElement(cv::MORPH_CROSS, cv::Size(size_mask, size_mask));
    erode(mat_gray, mat_dilate, element);
    
    //Binarization
    threshold(mat_dilate, mat_binary, range_inf, 255, CV_THRESH_BINARY);
    
    //Free memory
    mat_original.release();
    mat_dilate.release();
    mat_gray.release();
    
    return [self UIImageFromCVMat:mat_binary];
}

/** Apply the blur filter to image.
 
 @param image UIImage to filter.
 @return The image with blur filter.
 */
- (UIImage *)blurFilterImageFromUIImage: (UIImage *) image{
    
    cv::Mat mat_original = [self cvMatFromUIImage:image];
    cv::Mat mat_blur = mat_original.clone();
    
    //Filtro blur
    blur(mat_original, mat_blur, cv::Size(5,5));
    
    //Free memory
    mat_original.release();
    
    return [self UIImageFromCVMat:mat_blur];
}


@end
