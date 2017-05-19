//
//  WBImage.h
//  ImageDemo
//
//  Created by cy on 2017/5/19.
//  Copyright © 2017年 xyzcwb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBImage : NSObject

/**
 灰度处理
 */
+ (UIImage *)wb_grayImageWithImage:(UIImage *)image;
/**
 简单图片美白
 */
+ (UIImage *)wb_skinWhiteImageWithImage:(UIImage *)image;
/**
 彩色底版处理
 */
+ (UIImage *)wb_colorImageWithImage:(UIImage *)image;
@end
