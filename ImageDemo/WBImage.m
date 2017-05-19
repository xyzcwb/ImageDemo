//
//  WBImage.m
//  ImageDemo
//
//  Created by cy on 2017/5/19.
//  Copyright © 2017年 xyzcwb. All rights reserved.
//

#import "WBImage.h"

typedef NS_ENUM(NSUInteger, WBImageType) {
    Gray, // 灰度图片
    SkinWhite,  // 美白图片
    Color // 彩色底版图片
};

@implementation WBImage

#pragma mark - Public
+ (UIImage *)wb_grayImageWithImage:(UIImage *)image {
    return [[WBImage alloc] p_image:image withType:Gray];
}
+ (UIImage *)wb_skinWhiteImageWithImage:(UIImage *)image {
    return [[WBImage alloc] p_image:image withType:SkinWhite];
}
+ (UIImage *)wb_colorImageWithImage:(UIImage *)image {
    return [[WBImage alloc] p_image:image withType:Color];
}

#pragma mark - Private
- (UIImage *)p_image:(UIImage *)image withType:(WBImageType)type {
    //图片大小
    CGSize imageSize = image.size;
    //获取原始图片的数据
    unsigned char* originalData = [[WBImage alloc] p_imageToData:image];
    unsigned char* data = NULL;
    switch (type) {
        case Gray:
            data = [[WBImage alloc] p_grayDataWithData:originalData imageSize:imageSize];
            break;
        case SkinWhite:
            data = [[WBImage alloc] p_skinWhiteWithData:originalData imageSize:imageSize];
            break;
        case Color:
            data = [[WBImage alloc] p_colorDataWithData:originalData imageSize:imageSize];
            break;
            
        default:
            break;
    }
    return [[WBImage alloc] p_dataToImage:data imageSize:imageSize];
}
/*
 * image --> data
 */
- (unsigned char*)p_imageToData:(UIImage *)image {
    //使用的是框架是CoreGraphics，所以要把image ——> CGImage
    CGImageRef imageRef = [image CGImage];
    CGSize imageSize = image.size;
    //颜色空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    //分配bit级空间大小，一个像素点分为 R G B A 为4byte，像素点个数 = 宽*高
    void *data = malloc(4*imageSize.width*imageSize.height);
    //Bitmap上下文
    //kCGImageAlphaPremultipliedLast 当前颜色的排列顺序
    //kCGBitmapByteOrder32Big 位数  4*8
    CGContextRef context = CGBitmapContextCreate(data, imageSize.width, imageSize.height, 8, 4*imageSize.width, colorSpaceRef, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    //渲染
    //参数1：bitmap上下文
    //参数2：需要渲染的空间大小
    //参数3：原始图片
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), imageRef);
    //释放
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(context);
    return (unsigned char*)data;
}
/*
 * data --> image
 */
- (UIImage *)p_dataToImage:(unsigned char*)imageData imageSize:(CGSize)imageSize {
    //原始数据   4*imageSize.width*imageSize.height 数据空间大小
    CGDataProviderRef dataProRef = CGDataProviderCreateWithData(NULL, imageData, 4*imageSize.width*imageSize.height, NULL);
    
    CGImageRef imageRef = CGImageCreate(imageSize.width, imageSize.height, 8, 32, 4*imageSize.width, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, dataProRef, NULL, NO, kCGRenderingIntentDefault);
    UIImage *imageNew = [UIImage imageWithCGImage:imageRef];
    //释放
    CFRelease(imageRef);
    CGDataProviderRelease(dataProRef);
    return imageNew;
}
/*
 * 灰度处理
 */
- (unsigned char*)p_grayDataWithData:(unsigned char*)imageData imageSize:(CGSize)imageSize {
    unsigned char* data = malloc(4*sizeof(unsigned char)*imageSize.width*imageSize.height);
    //初始化data 内存
    //参数1：内存地址
    //参数2：填充的值
    //参数3：需要填充的内存空间大小
    memset(data, 0, 4*imageSize.width*imageSize.height);
    for (int h = 0; h < imageSize.height; h++) {
        for (int w = 0; w < imageSize.width; w++) {
            //当前像素点的位置
            unsigned int index = h*imageSize.width+w;
            //取出原始的RGBA
            //imageData+index*4: imageData地址加上偏移量（每个像素4byte）
            unsigned char red = *(imageData+index*4);
            unsigned char green = *(imageData+index*4+1);
            unsigned char blue = *(imageData+index*4+2);
            //灰度处理
            unsigned int newRGB = red*0.299+green*0.587+blue*0.114;
            //可能算出来的值大于255
            newRGB = newRGB > 255? 255:newRGB;
            memset(data+index*4, newRGB, 1);
            memset(data+index*4+1, newRGB, 1);
            memset(data+index*4+2, newRGB, 1);
        }
    }
    return data;
}
/*
 * 美白处理
 */
- (unsigned char*)p_skinWhiteWithData:(unsigned char*)imageData imageSize:(CGSize)imageSize {
    void *data = malloc(4*imageSize.width*imageSize.height);
    memset(data, 0, imageSize.width*imageSize.height);
    NSArray *array = @[@"55",@"110",@"155",@"185",@"225",@"240",@"250",@"255"];
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    int last = 0;//记录前一次的值，一开始为 0
    for (int i = 0; i < 8; i++) {
        int num = [array[i] intValue];
        float step = (num - last)/32.0;//步长，每次增加多少
        for (int j = 0; j < 32; j++) {
            float newNum = last+step*j;//上一次的值加上步长*j 得到对应位置的值
            NSString *newNumStr = [NSString stringWithFormat:@"%lf",newNum];
            [colorArray addObject:newNumStr];
        }
        last = num;
    }
    for (int h = 0; h < imageSize.height; h++) {
        for (int w = 0; w < imageSize.width; w++) {
            unsigned int index = h*imageSize.width+w;
            //取出原始的RGBA
            unsigned int red = *(imageData+index*4);
            unsigned int green = *(imageData+index*4+1);
            unsigned int blue = *(imageData+index*4+2);
            //美白处理
            unsigned int newRed = [colorArray[red] floatValue];
            unsigned int newGreen = [colorArray[green] floatValue];
            unsigned int newBlue = [colorArray[blue] floatValue];
            memset(data+index*4, newRed, 1);
            memset(data+index*4+1, newGreen, 1);
            memset(data+index*4+2, newBlue, 1);
        }
    }
    return data;
    
}
/*
 * 彩色底版处理
 */
- (unsigned char*)p_colorDataWithData:(unsigned char*)imageData imageSize:(CGSize)imageSize {
    unsigned char* data = malloc(4*sizeof(unsigned char)*imageSize.width*imageSize.height);
    //初始化data 内存， 1：内存地址  2：填充的值  3：需要填充的内存空间大小
    memset(data, 0, 4*imageSize.width*imageSize.height);
    for (int h = 0; h < imageSize.height; h++) {
        for (int w = 0; w < imageSize.width; w++) {
            unsigned int index = h*imageSize.width+w;
            //取出原始的RGBA
            unsigned char red = *(imageData+index*4);
            unsigned char green = *(imageData+index*4+1);
            unsigned char blue = *(imageData+index*4+2);
            //彩色处理
            unsigned int newRed = 255-red;
            unsigned int newGreen = 255-green;
            unsigned int newBlue = 255-blue;
            memset(data+index*4, newRed, 1);
            memset(data+index*4+1, newGreen, 1);
            memset(data+index*4+2, newBlue, 1);
        }
    }
    return data;
}
@end
