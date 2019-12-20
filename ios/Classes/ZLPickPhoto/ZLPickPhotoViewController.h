//
//  SelectPhotoCollectionViewController.h
//  PhotoKit的使用
//
//  Created by qq on 16/6/5.
//  Copyright © 2016年 lei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Complete)(NSArray *images);

@interface ZLPickPhotoViewController : UICollectionViewController
@property (nonatomic,assign) NSInteger limitCount;  // 限制选择多少张图片，0为不限制
- (instancetype)initWithCompleteHandle:(Complete)completeHandle;
@end
