//
//  ViewController.m
//  ImageDemo
//
//  Created by xyzcwb on 2017/4/18.
//  Copyright © 2017年 xyzcwb. All rights reserved.
//

#import "ViewController.h"
#import "WBImage.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *grayImageView;
@property (nonatomic, strong) UIImageView *colorImageView;
@property (nonatomic, strong) UIImageView *skinWhiteImageView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initImageView];
}

- (void)initImageView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    UIImage *image = [UIImage imageNamed:@"image"];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    self.imageView.image = image;
    [scrollView addSubview:self.imageView];
    
    //灰度处理
    self.grayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200+10, kScreenWidth, 200)];
    self.grayImageView.image = [WBImage wb_grayImageWithImage:image];
    [scrollView addSubview:self.grayImageView];
    
    //简单图片美白处理
    self.skinWhiteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (200+10)*2, kScreenWidth, 200)];
    self.skinWhiteImageView.image = [WBImage wb_skinWhiteImageWithImage:image];
    [scrollView addSubview:self.skinWhiteImageView];
    
    //彩色底版处理
    self.colorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (200+10)*3, kScreenWidth, 200)];
    self.colorImageView.image = [WBImage wb_colorImageWithImage:image];
    [scrollView addSubview:self.colorImageView];
    
    scrollView.contentSize = CGSizeMake(0, 200*4+10*3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
