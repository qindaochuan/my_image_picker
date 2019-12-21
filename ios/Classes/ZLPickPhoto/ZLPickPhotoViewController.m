//
//  SelectPhotoCollectionViewController.m
//  PhotoKit的使用
//
//  Created by qq on 16/6/5.
//  Copyright © 2016年 lei. All rights reserved.
//
/**
 * 选择图片的控制器，长安可以浏览大图
 */

#import "ZLPickPhotoViewController.h"
#import "ZLPhotoHelper.h"
#import "ZLPhotoCell.h"
#import "ZLShowImageViewController.h"
#import "../imageCropper/PhotoViewController.h"

@interface ZLPickPhotoViewController () <ZLPhotoCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PhotoViewControllerDelegate>
@property (nonatomic, strong) PHFetchResult *fetchResul;
@property (nonatomic,strong) NSMutableArray *resultImage;
@property (nonatomic,strong) NSMutableArray *selectIndexs;
@property (nonatomic,strong) UIBarButtonItem *rightItem;
@property (nonatomic,copy) Complete completeHandle;
@property (nonatomic,copy) FlutterResult result;
@end

@implementation ZLPickPhotoViewController

static NSString * const reuseIdentifier = @"Cell";

- (PHFetchResult *)fetchResul {
    if (!_fetchResul) {
        _fetchResul = [[ZLPhotoHelper sharedZLPhotoHelper] getAllPhoteAsset];
    }
    return _fetchResul;
}

- (NSMutableArray *)resultImage {
    if (!_resultImage) {
        _resultImage = [[NSMutableArray alloc] init];
    }
    return _resultImage;
}

- (NSMutableArray *)selectIndexs {
    if (!_selectIndexs) {
        _selectIndexs = [NSMutableArray array];
    }
    return _selectIndexs;
}

- (NSInteger)limitCount {
    if (_limitCount == 0) {
        return self.resultImage.count;
    }
    return _limitCount;
}

- (instancetype)initWithCompleteHandle:(Complete)completeHandle result:(FlutterResult)result  {
    if (self = [self init]) {
        self.completeHandle = completeHandle;
        self.result = result;
    }
    return self;
}

- (instancetype)init {
   UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenW = MIN(screenSize.width, screenSize.height);
    
    CGFloat w = screenW / 4.0;
    flowLayout.itemSize = CGSizeMake(w - 1,w - 1);
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftItemClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
//    self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
//    self.navigationItem.rightBarButtonItem = self.rightItem;
//    self.rightItem.enabled = NO;
    
    [self setupCollectionView];

    self.title = [NSString stringWithFormat:@"0/%lu",(unsigned long)self.limitCount];

    __weak typeof(self) weakSelf = self;
    
    [[ZLPhotoHelper sharedZLPhotoHelper] checkAuthorizationWithHandle:^{
        [weakSelf performSelectorInBackground:@selector(loadPhoto) withObject:nil];
    } failHandle:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    } showMsgCtr:self];
}

- (void)setupCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZLPhotoCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)loadPhoto {
    [self.resultImage removeAllObjects];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"camera" ofType:@".jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [self.resultImage addObject:image];
    __weak typeof(self) weakSelf = self;
    [self.fetchResul enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[ZLPhotoHelper sharedZLPhotoHelper] getThumbnailImageWithAsset:obj completion:^(UIImage *photo, NSDictionary *info) {
            [weakSelf.resultImage addObject:photo];
            // 当满屏时候刷新 或 加载完成以后刷新
            if (weakSelf.resultImage.count == weakSelf.fetchResul.count || weakSelf.resultImage.count == 28) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.collectionView reloadData];
                });
                
            }
        }];
    }];
}

- (void)loadSelectPhoto {
    if (self.selectIndexs == 0) {
        return;
    }
    
    NSArray *newArr = [self.selectIndexs sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 intValue] > [obj2 intValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    self.selectIndexs = [NSMutableArray arrayWithArray:newArr];
    
    NSMutableArray *selectPhoto = [NSMutableArray array];
    for (NSNumber *n in self.selectIndexs) {
        PHAsset *asset = self.fetchResul[[n integerValue]];
        [[ZLPhotoHelper sharedZLPhotoHelper] getFullScreenImageWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
            [selectPhoto addObject:photo];
        }];
    }
    
    if (self.completeHandle) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completeHandle(selectPhoto);
        });
    }
}
- (void)rightItemClick {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelectorInBackground:@selector(loadSelectPhoto) withObject:nil];
}



- (void)leftItemClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultImage.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.img = self.resultImage[indexPath.row];
    cell.isSelectPhoto = [self.selectIndexs containsObject:@(indexPath.row)];
    cell.deleage = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger i = indexPath.row;
    if ([self.selectIndexs containsObject:@(i)]) {
        [self.selectIndexs removeObject:@(i)];
    } else {
        if (self.limitCount != 0 && self.selectIndexs.count >= self.limitCount) {
            return;
        }
        [self.selectIndexs addObject:@(i)];
    }

    [collectionView reloadData];

    self.title = self.title = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)self.selectIndexs.count,(unsigned long)self.limitCount];
    //self.rightItem.enabled = self.selectIndexs.count > 0;
    if(i == 0)//第一个是相机
    {
        //资源类型为照相机
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        //判断是否有相机
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:nil];
        }else {
            //NSLog(@"该设备无摄像头");
            [[[UIAlertView alloc] initWithTitle:@"Error"
                      message:@"Camera not available."
                     delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil] show];
        }
    }
    else
    {
        PhotoViewController *photoVC = [[PhotoViewController alloc] init];
               photoVC.oldImage = self.resultImage[indexPath.row];
           //    photoVC.btnBackgroundColor = COLOR_NAV;
               //    photoVC.backImage = ;自定义返回按钮图片
               photoVC.mode = PhotoMaskViewModeCircle;
               photoVC.cropWidth = CGRectGetWidth(self.view.bounds) - 80;
               //photoVC.isDark = YES;
               photoVC.delegate = self;
           //    photoVC.lineColor = COLOR_NAV;
        photoVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:photoVC animated:(YES) completion:nil];
        //[self.navigationController pushViewController:photoVC animated:(YES)];
    }
}

#pragma mark -  UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    PhotoViewController *photoVC = [[PhotoViewController alloc] init];
        photoVC.oldImage = image;
    //    photoVC.btnBackgroundColor = COLOR_NAV;
        //    photoVC.backImage = ;自定义返回按钮图片
        photoVC.mode = PhotoMaskViewModeCircle;
        photoVC.cropWidth = CGRectGetWidth(self.view.bounds) - 80;
        //photoVC.isDark = YES;
        photoVC.delegate = self;
    //    photoVC.lineColor = COLOR_NAV;
        [picker pushViewController:photoVC animated:YES];
}

#pragma mark - photoViewControllerDelegate
- (void)imageCropper:(PhotoViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    NSData *imagedata = UIImageJPEGRepresentation(editedImage,1.0);
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss-SS"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[dateString stringByAppendingString:@".jpg" ]];
    [imagedata writeToFile:savedImagePath atomically:YES];
    self.result(savedImagePath);
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        CATransition *animation = [CATransition animation];
        animation.duration = 0.4f;
        animation.type = kCATransitionMoveIn;
        animation.subtype = kCATransitionFromBottom;
    }];
    
    [self dismissViewControllerAnimated:(YES) completion:^{
                 
    }];
}

- (void)photoCell:(ZLPhotoCell *)cell longPressImage:(UIImage *)image {
//    __weak typeof(self) weakSelf = self;
//    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
//    PHAsset *asset = self.fetchResul[indexPath.row];
//    [[ZLPhotoHelper sharedZLPhotoHelper]getOriginImageWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
//        ZLShowImageViewController *vc = [[ZLShowImageViewController alloc] init];
//        vc.image = photo;
//        [weakSelf presentViewController:vc animated:YES completion:nil];
//    }];
    
    
}

- (void)dealloc {
    [self.resultImage removeAllObjects];
    [self.selectIndexs removeAllObjects];
    self.resultImage = nil;
    self.selectIndexs = nil;
    self.fetchResul = nil;
    self.completeHandle = nil;
}
@end
