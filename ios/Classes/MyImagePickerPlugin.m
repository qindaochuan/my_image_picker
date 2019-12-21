#import "MyImagePickerPlugin.h"
#import "ZLPickPhotoViewController.h"
#import "ZLPhotoCell.h"

@interface MyImagePickerPlugin ()

@property(copy, nonatomic) FlutterResult result;

@end

@implementation MyImagePickerPlugin
{
    NSDictionary *_arguments;
    UIViewController *_viewController;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.flutter.io/my_image_picker"
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    MyImagePickerPlugin *instance = [[MyImagePickerPlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (self.result) {
        self.result([FlutterError errorWithCode:@"multiple_request"
                                        message:@"Cancelled by a second request"
                                        details:nil]);
        self.result = nil;
    }
    
    if ([@"circleCrop" isEqualToString:call.method]) {
        self.result = result;
        _arguments = call.arguments;
        [self selectPhtoto];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)selectPhtoto{
    // 创建选择图片控制器
    ZLPickPhotoViewController *vc = [[ZLPickPhotoViewController alloc] initWithCompleteHandle:^(NSArray *images) {
        //[weakSelf.resultImage removeAllObjects];
        //[weakSelf.resultImage addObjectsFromArray:images];
        //[weakSelf.collectionView reloadData];
    } result:self.result];
    // 限制最多能选多少张
    vc.limitCount = 1;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [_viewController presentViewController:nav animated:YES completion:nil];
}

@end
