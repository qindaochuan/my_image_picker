//
//  ZLPhotoHelper.h
//  PhotoKit的使用
//
//  Created by qq on 16/6/5.
//  Copyright © 2016年 lei. All rights reserved.
//

// .h文件
#define HMSingletonH(name) + (instancetype)shared##name;
// .m文件
#define HMSingletonM(name) \
static id _instance; \
\
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}

#import <Foundation/Foundation.h>
#import <PhotosUI/PhotosUI.h>

@interface ZLPhotoHelper : NSObject
HMSingletonH(ZLPhotoHelper)
// 获取所有资源的集合，并按资源的创建时间排序
- (PHFetchResult *)getAllPhoteAsset;
// 根据PHAsset获取缩略图片
- (void)getThumbnailImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion;
// 根据PHAsset获取满屏图片
- (void)getFullScreenImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion;
// 根据PHAsset获取原图图片
- (void)getOriginImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion;
/// 检查授权状态以及授权成功或失败以后的操作
- (void)checkAuthorizationWithHandle:(void(^)())succesHandle failHandle:(void(^)())failHandle showMsgCtr:(UIViewController *)showMsgCtr;
@end
