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


- (UIImage *)generateBinaryImageFromUIImage: (UIImage *) image{
    
    cv::Mat mat_original = [self cvMatFromUIImage:image];
    cv::Mat mat_gray = mat_original.clone();
    cv::Mat mat_binaria = mat_original.clone();
    
    cvtColor(mat_original, mat_gray, CV_RGB2GRAY);
    threshold(mat_gray, mat_binaria, 150, 255, CV_THRESH_BINARY);
    
    //Liberar memoria
    mat_original.release();
    mat_gray.release();
    
    return [self UIImageFromCVMat:mat_binaria];
    
}

- (UIImage *)generateDilateImageFromUIImage: (UIImage *) image{
    
    cv::Mat mat_original = [self cvMatFromUIImage:image];
    cv::Mat mat_dilate = mat_original.clone();
    
    //Creando mascara
    cv::Mat element = getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(7, 7));
    
    //Metodo para dilatar imagen
    //dilate(mat_original, mat_dilate, element);
    erode(mat_original, mat_dilate, element);
    
    //Liberar memoria
    mat_original.release();
    
    return [self UIImageFromCVMat:mat_dilate];
    
}

- (UIImage *)improveImageFromUIImage: (UIImage *) image{
    
    cv::Mat mat_original = [self cvMatFromUIImage:image];
    cv::Mat mat_gray = mat_original.clone();
    cv::Mat mat_binaria = mat_original.clone();
    cv::Mat mat_dilate = mat_original.clone();
    
    //Escala de grises
    cvtColor(mat_original, mat_gray, CV_RGB2GRAY);
    
    uint8_t* pixelPtr = (uint8_t*)mat_gray.data;
    int histogram[256]={0};
    double frec_acumulada[256]={0};
    double media = 0;
    int num_pixeles = mat_gray.cols*mat_gray.rows;
    
    //Calculando Histograma
    for(int filas = 0; filas < mat_gray.rows; filas++)
    {
        for(int colum = 0; colum < mat_gray.cols; colum++)
        {
            histogram[pixelPtr[filas*mat_gray.cols + colum]]+=1;
            //NSLog(@"Valor: %d", pixelPtr[filas*mat_gray.cols + colum]);
        }
    }
    
    //Calculando media
    for( int indice = 0; indice < 256; indice++ ){
        media += (indice*histogram[indice]);
        //printf("%d, ", histogram[indice]);
    }
    media = media / num_pixeles;
    NSLog(@"Media: %f", media);
    
    //Parametros de dilatacion y binarizacion segun media
    int tam_mascara = 0;
    int rango_inf = 0;
    
    if (media<=60) {
        return nil;
    }else if(media>60 && media<=100){
        tam_mascara = 3;
        rango_inf = 70;
    }else if(media>100 && media<=170){
        tam_mascara = 5;
        rango_inf = 100;
    }else if(media>170 && media <=230){
        tam_mascara = 7;
        rango_inf = 130;
    }else{
        return nil;
    }
    
    //Dilatacion
    cv::Mat element = getStructuringElement(cv::MORPH_CROSS, cv::Size(tam_mascara, tam_mascara));
    erode(mat_gray, mat_dilate, element);
    
    //Binarizacion
    threshold(mat_dilate, mat_binaria, rango_inf, 255, CV_THRESH_BINARY);
    
    //Liberar memoria
    mat_original.release();
    mat_dilate.release();
    mat_gray.release();
    
    return [self UIImageFromCVMat:mat_binaria];
}


@end
