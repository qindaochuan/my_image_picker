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

@interface ZLPickPhotoViewController () <ZLPhotoCellDelegate>
@property (nonatomic, strong) PHFetchResult *fetchResul;
@property (nonatomic,strong) NSMutableArray *resultImage;
@property (nonatomic,strong) NSMutableArray *selectIndexs;
@property (nonatomic,strong) UIBarButtonItem *rightItem;
@property (nonatomic,copy) Complete completeHandle;
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

- (instancetype)initWithCompleteHandle:(Complete)completeHandle  {
    if (self = [self init]) {
        self.completeHandle = completeHandle;
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
}

- (void)photoCell:(ZLPhotoCell *)cell longPressImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PHAsset *asset = self.fetchResul[indexPath.row];
    [[ZLPhotoHelper sharedZLPhotoHelper]getOriginImageWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
        ZLShowImageViewController *vc = [[ZLShowImageViewController alloc] init];
        vc.image = photo;
        [weakSelf presentViewController:vc animated:YES completion:nil];
    }];
    
    
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
