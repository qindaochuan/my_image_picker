//
//  ZLPhotoCell.m
//  PhotoKit的使用
//
//  Created by qq on 16/6/5.
//  Copyright © 2016年 lei. All rights reserved.
//

#import "ZLPhotoCell.h"
#import "ZLPhotoHelper.h"


@interface ZLPhotoCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;

@end
@implementation ZLPhotoCell

- (void)awakeFromNib {
    _selectImgView.layer.cornerRadius = 12.5;
    _selectImgView.layer.masksToBounds = YES;
    _selectImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    _selectImgView.layer.borderWidth = 1;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        NSLog(@"state = %ld",(long)longPress.state);
        if ([self.deleage respondsToSelector:@selector(photoCell:longPressImage:)]) {
            [self.deleage photoCell:self longPressImage:self.imgView.image];
        }
    }
}

- (void)setIsSelectPhoto:(BOOL)isSelectPhoto {
    _selectImgView.hidden = !isSelectPhoto;;
    self.imgView.alpha = isSelectPhoto ? 0.7 : 1;
}

- (void)setImg:(UIImage *)img {
    _imgView.image = img;

}

@end
