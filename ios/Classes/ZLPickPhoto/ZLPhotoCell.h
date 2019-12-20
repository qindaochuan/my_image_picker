//
//  ZLPhotoCell.h
//  PhotoKit的使用
//
//  Created by qq on 16/6/5.
//  Copyright © 2016年 lei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
@class ZLPhotoCell;

@protocol ZLPhotoCellDelegate <NSObject>
@optional
- (void)photoCell:(ZLPhotoCell *)cell longPressImage:(UIImage *)image;
@end

@interface ZLPhotoCell : UICollectionViewCell

@property (nonatomic,strong) UIImage *img;
@property (nonatomic, assign) BOOL isSelectPhoto;
@property (nonatomic, weak) id<ZLPhotoCellDelegate> deleage;
@end
