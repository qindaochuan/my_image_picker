//
//  ZLPhotoHelper.m
//  PhotoKit的使用
//
//  Created by qq on 16/6/5.
//  Copyright © 2016年 lei. All rights reserved.
//

/**
 * 从图片库获取图片的核心类
 */

#import "ZLPhotoHelper.h"

@interface ZLPhotoHelper()
@property (nonatomic, strong) PHImageRequestOptions *op;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) int multiple;// 几倍的分辨率
@end

@implementation ZLPhotoHelper
HMSingletonM(ZLPhotoHelper)

- (int)multiple {
    if (!_multiple) {
        // screenSize = (width = 414, height = 736),6p分辨率
       CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (screenSize.width == 414 && screenSize.height == 736) {
            return 3;
        } else {
            _multiple = 2;
        }
        
    }
    return _multiple;
}

- (PHImageRequestOptions *)op {
    if (!_op) {
        _op = [[PHImageRequestOptions alloc] init];
        _op.version = PHImageRequestOptionsVersionCurrent;   // 版本
        _op.resizeMode = PHImageRequestOptionsResizeModeFast; // 剪裁方式，快速Fast (比 .Exact 效率更高，但返回图像可能和目标大小不一样) ，Exact 返回和目标图片大小一样，None，不剪裁，占用内存比Exact高
        _op.networkAccessAllowed = NO;//是否允许使用网络访问ICloud,默认NO
        _op.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat; // 图片质量，fast为低质量,HighQualityFormat 为高质量，时间等待较长，内存占用较大；Opportunistic，如果用的是移步，将得到多张图片，如果是同步，将得到一张图片，占用内存较大
        _op.synchronous = YES;// 是否同步，默认NO;

    }
    return _op;
}

/// 检查授权状态
- (void)checkAuthorizationWithHandle:(void(^)())succesHandle failHandle:(void(^)())failHandle showMsgCtr:(UIViewController *)showMsgCtr {
    __weak typeof(self) weakSelf = self;
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {   // 第一次用户没用选择的操作
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    if (succesHandle) {
                        succesHandle();
                    }
                } else {
                    [weakSelf showAlertViewWithHandle:failHandle showMsgCtr:showMsgCtr];
                }
            });
        }];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {   // 授权成功的操作
        if (succesHandle) {
            succesHandle();
        }
    } else {    // 授权失败的操作
        [self showAlertViewWithHandle:failHandle showMsgCtr:showMsgCtr];
    }
}

- (void)showAlertViewWithHandle:(void(^)())handle showMsgCtr:(UIViewController *)showMsgCtr {
    NSString *tipTextWhenNoPhotosAuthorization = @"请到设置-隐私-照片,允许该应用访问您的手机相册";
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"提示" message:tipTextWhenNoPhotosAuthorization preferredStyle:UIAlertControllerStyleAlert];
    
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handle) {
            handle();
        }
    }]];
    [showMsgCtr presentViewController:alertCtr animated:YES completion:nil];
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}
    


// 获取所有资源的集合，并按资源的创建时间排序
- (PHFetchResult *)getAllPhoteAsset {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    NSLog(@"获取所有资源的集合:%lu",(unsigned long)assetsFetchResults.count);
    return assetsFetchResults;
}

// 根据PHAsset获取100 ＊ 100缩略图片
- (void)getThumbnailImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion {
    [self requestImageWithAsset:asset size:CGSizeMake(100 * self.multiple, 100 * self.multiple) completion:completion];

}

// 根据PHAsset获取满屏图片
- (void)getFullScreenImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion {
    
    [self requestImageWithAsset:asset size:[UIScreen mainScreen].bounds.size completion:completion];
}

// 根据PHAsset获取原图图片
- (void)getOriginImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion {
    
    [self requestImageWithAsset:asset size:PHImageManagerMaximumSize completion:completion];
}

// 根据大小获取照片
- (void)requestImageWithAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *photo, NSDictionary *info))completion {

    [self.imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:self.op resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            completion(result,info);
        }
    }];
//        NSLog(@"info:%@",info);
        // 从info判断是否是高清图片，PHImageResultIsDegradedKey 表示当前返回的 UIImage 是低清图
//        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
//        if (downloadFinined) {
//            if (completion) {
//                completion(result,info);
//            }
//        }
        
        /*
        NSDate *date = asset.creationDate;
        NSUInteger w = asset.pixelWidth;
        NSUInteger h = asset.pixelHeight;
        
        NSData *imgData = UIImagePNGRepresentation(result);
        NSLog(@"图片size:%@",NSStringFromCGSize( result.size));
        NSLog(@"图片容量:%lu",(unsigned long)imgData.length);
        NSLog(@"线程:%@",[NSThread currentThread]);

        NSLog(@"创建时间:%@,w = %lu,h = %lu",date,(unsigned long)w,(unsigned long)h);
        */

}

/*******************************************************************************/
/*
// 代码示例
- (void)getPhoto {
    // 列出所有相册智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    NSLog(@"列出所有相册智能相册:%lu",(unsigned long)smartAlbums.count);
    
    [smartAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"index = %lu,obj = %@",(unsigned long)idx,obj);
        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
        // 相册名字
        NSString *title = assetCollection.localizedTitle;
        NSLog(@"title = %@",title);
    }];
    
    
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    NSLog(@"列出所有用户创建的相册:%lu",(unsigned long)topLevelUserCollections.count);
    
    
    
    [topLevelUserCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"index = %lu,obj = %@",(unsigned long)idx,obj);
        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
        // 相册名字
        NSString *title = assetCollection.localizedTitle;
        NSLog(@"title = %@",title);
    }];
    
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    NSLog(@"获取所有资源的集合:%lu",(unsigned long)assetsFetchResults.count);
    NSMutableArray *imgs = [NSMutableArray array];
    // 在资源的集合中获取第一个集合，并获取其中的图片,一个PHAsset包含一张图片
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    
    [assetsFetchResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"index = %lu,obj = %@",(unsigned long)idx,obj);
        PHAsset *asset = (PHAsset *)obj;
        NSString *identifier = asset.localIdentifier;
        
        NSLog(@"identifier = %@",identifier);
    }];
    
    PHAsset *asset = assetsFetchResults[0];
    
    
    
    PHImageRequestOptions *op = [[PHImageRequestOptions alloc] init];
    op.version = PHImageRequestOptionsVersionCurrent;   // 版本
    op.resizeMode = PHImageRequestOptionsResizeModeFast; // 剪裁方式，快速
    op.networkAccessAllowed = NO;//是否允许使用网络访问ICloud,默认NO
    op.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; // 图片质量，fast为低质量
    op.synchronous = NO;// 是否同步，默认NO;
    // 要获取图片等大小，PHImageManagerMaximumSize为最大尺寸，所有的尺寸都是用 Pixel，因此这里想要获得正确大小的图像，需要把输入的尺寸转换为 Pixel
    CGSize someSize = CGSizeMake(10, 10);
    //如果允许访问网络，可能会从网络上获取一张低清图，再获取高清图（调用两次）
    [imageManager requestImageForAsset:asset targetSize:someSize contentMode:PHImageContentModeDefault options:op resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [imgs addObject:result];
        NSLog(@"info:%@",info);
        // 从info判断是否是高清图片，PHImageResultIsDegradedKey 表示当前返回的 UIImage 是低清图
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        
        NSData *imgData = UIImagePNGRepresentation(result);
        NSLog(@"图片大小:%lu",(unsigned long)imgData.length);
    }];
    
    NSLog(@"有%lu张图片",(unsigned long)imgs.count);
}
*/
@end
