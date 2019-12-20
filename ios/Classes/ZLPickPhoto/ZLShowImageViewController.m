//
//  ShowImageViewController.m
//  PhotoKit的使用
//
//  Created by 张磊 on 16/6/7.
//  Copyright © 2016年 lei. All rights reserved.
//
/**
 浏览大图控制器
 */

#import "ZLShowImageViewController.h"

@interface ZLShowImageViewController () <UIGestureRecognizerDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) UIImageView *imgView;
@end

@implementation ZLShowImageViewController
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.userInteractionEnabled = YES;
    }
    return _imgView;
}

- (instancetype)init {
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.imgView.image = self.image;
    
    [self addPan];
    [self addPinch];

    [self addTap];
    
    [self.view addSubview:_imgView];
}

#pragma mark - 平移手势 -------------------------------------------
- (void)addPan {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.imgView addGestureRecognizer:pan];
}
- (void)pan:(UIPanGestureRecognizer *)pan {
    // 获取手指移动位置
    CGPoint translationP = [pan translationInView:self.imgView];

    CGFloat d = self.imgView.transform.d;

    if (d <= 1.0 ) {
        return;
    }
    
    // 平移图片
    self.imgView.transform = CGAffineTransformTranslate(self.imgView.transform, translationP.x, translationP.y);
    
    // 复位
    [pan setTranslation:CGPointZero inView:self.imgView];
}
#pragma mark - 捏合手势 -------------------------------------------
- (void)addPinch {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    [self.imgView addGestureRecognizer:pinch];
}
- (void)pinch:(UIPinchGestureRecognizer *)pinch {
    NSLog(@"pinch.scanle = %f",pinch.scale);

    CGFloat d = self.imgView.transform.d;
    
    if ((d < 1.0 ) && pinch.state == UIGestureRecognizerStateEnded) {
        self.imgView.transform = CGAffineTransformIdentity;
    }

    if ((d >3.0 ) && pinch.state == UIGestureRecognizerStateEnded) {
        self.imgView.transform = CGAffineTransformMakeScale(3, 3);
    }
    
   else {
        self.imgView.transform = CGAffineTransformScale(self.imgView.transform, pinch.scale, pinch.scale);
    }
    
    // 复位,注意:最小复位倍数是1,不然会出错
    pinch.scale = 1;
}
#pragma mark - 旋转手势 -------------------------------------------
- (void)addRotation {
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotation:)];
    rotation.delegate = self;
    [self.imgView addGestureRecognizer:rotation];
}
- (void)rotation:(UIRotationGestureRecognizer *)rotation {
    CGFloat velocity = rotation.velocity;
    NSLog(@"rotation = %f,velocity = %f",rotation.rotation,velocity);
    // 每次归位角度
    //    self.imgView.transform = CGAffineTransformMakeRotation(rotation.rotation);
    
    // 基于上一次的角度计算
    self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, rotation.rotation);
    
    // 清除角度,复位
    rotation.rotation = 0;
}
#pragma mark - 单击手势-------------------------------------------
- (void)addTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    // 点击多少次才能识别
    tap.numberOfTapsRequired = 1;
    // 几个手指才能识别
    tap.numberOfTouchesRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // 双手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    // 点击多少次才能识别
    doubleTap.numberOfTapsRequired = 2;
    // 几个手指才能识别
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.delegate = self;
    [self.view addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)doubleTap {
    [UIView animateWithDuration:0.25 animations:^{
        self.imgView.transform = CGAffineTransformIdentity;
    }];
    
}

// 是否允许同时使用多个手势,默认不允许
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
