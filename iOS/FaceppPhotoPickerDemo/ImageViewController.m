//
//  ImageViewController.m
//  FaceppSDK+Demo
//
//  Created by Lson on 15/10/24.
//  Copyright © 2015年 Megvii. All rights reserved.
//

#import "ImageViewController.h"
#import "UMSocial.h"
#import "YXLabel.h"

#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)
#define navHeight 64
#define screenScale ([UIScreen mainScreen].scale)

@interface ImageViewController ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) NSDictionary *personDict;
@property (nonatomic,strong) NSDictionary *positionDict;
@property (nonatomic,strong) UIImageView *frameImageView;
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)NSMutableArray *array;
@property (nonatomic,strong)UIImage *personImage;
@end

@implementation ImageViewController
-(id)initWithPersonData:(NSDictionary *)personDic andPositionData:(NSDictionary *)positionDic andImage:(UIImage *)personImg
{
    self = [super init];
    if (self) {
        _personDict =[ personDic copy];//[NSDictionary dictionaryWithDictionary:personDic];
        _positionDict = [NSDictionary dictionaryWithDictionary:positionDic];
        self.personImage = personImg;
//        self.backBtn.hidden = YES;
//        self.rightBtn.hidden = YES;
        self.array = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.rightBtn];
    
    [self.imageView addSubview:self.frameImageView];

    double x  = [self.positionDict[@"center"][@"x"] doubleValue] * 0.01 *self.view.frame.size.width;
    double y  = [self.positionDict[@"center"][@"y"] doubleValue] * 0.01 *self.view.frame.size.height;
    double width = [self.positionDict[@"width"] doubleValue] * 0.01 *self.view.frame.size.height;
    
    CGRect rect = self.frameImageView.frame;
    rect.size.width = width;
    rect.size.height = width;
    self.frameImageView.frame = rect;
    CGPoint p = CGPointMake(x,y);
    self.frameImageView.center = p;

    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBanner)];
    [self.imageView addGestureRecognizer:tap];
    
    [self performSelector:@selector(showFont) withObject:self afterDelay:0.5];
    
}

static int sec = 0;

- (void)showFont
{

    int i = 0;
    for (NSString *str in self.personDict.allValues) {
        NSLog(@"d%@",str);
        
        
        
            YXLabel *label   = [[YXLabel alloc] initWithFrame:CGRectMake(0 ,0 ,180,30)];
            [self.array addObject:label];
            
            label.text       = str;
            label.startScale = 0.3f;
            label.endScale   = 2.f;
            label.backedLabelColor = [UIColor whiteColor];
            label.colorLabelColor  = [UIColor cyanColor];
            label.font = [UIFont systemFontOfSize:20];
            label.shadowColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(10, 10);
            [label sizeToFit];
            label.center   = self.view.center;
            [self.imageView addSubview:label];
        
            [label startAnimation];
        
        CGPoint center = CGPointMake(100 * i * 0.4, 70 * i * 2.5);
        
        switch (i) {
            case 0:
                center = CGPointMake(150, 200);
                break;
            case 1:
                center = CGPointMake(50, 257);
                break;
            case 2:
                center = CGPointMake(187, 158);
                break;
            case 3:
                center = CGPointMake(89, 280);
                break;
            case 4:
                center = CGPointMake(109, 145);
                break;
            default:
                center = CGPointMake(100 + rand()%100, 200 + rand()%100);
                break;
        }
        
        label.center = center;
        
        
        
        i ++ ;
        
        
    }
    
    

}

- (void)showBanner
{
    return;
    self.backBtn.hidden = !self.backBtn.hidden;
    self.rightBtn.hidden = !self.rightBtn.hidden;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setters and getters

- (UIImageView *)imageView
{
    if(_imageView == nil)
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _imageView.image = self.personImage != nil?_personImage:[UIImage imageNamed:@"26244-HdQpaA.jpg"];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIButton *)backBtn
{
    if(_backBtn == nil)
    {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 15, 25)];
        [_backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [_backBtn setBackgroundImage:[UIImage imageNamed:@"26.pic_hd.jpg"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"26.pic_hd.jpg"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)rightBtn
{
    if(_rightBtn == nil)
    {
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 25 - 10, 20, 20, 25)];
        [_rightBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [_rightBtn setBackgroundImage:[UIImage imageNamed:@"39.pic_hd.jpg"] forState:UIControlStateNormal];
        [_rightBtn setImage:[UIImage imageNamed:@"39.pic_hd.jpg"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(shareMethod) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UIImageView *)frameImageView
{
    if(!_frameImageView)
    {
        _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _frameImageView.image = [UIImage imageNamed:@"30.pic_hd.jpg"];
    }
    return _frameImageView;
}

- (void)goback
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)shareMethod
{
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"54866bd5fd98c597e20004cb"
                                      shareText:@"分享"
                                     shareImage:[self screenShot]
                                shareToSnsNames:nil
                                       delegate:self];
}

- (void)setImage:(UIImage *)image andInfo:(NSDictionary *)info
{
    
}

//屏幕截屏
- (UIImage *)screenShot
{
    
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth*screenScale, screenHeight*screenScale), YES, 0);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth*screenScale, screenHeight*screenScale-navHeight), YES, 0);

    //设置截屏大小
    [[[[UIApplication sharedApplication] keyWindow] layer] renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect = CGRectMake(0, 0, screenWidth*screenScale,screenHeight*screenScale-navHeight);
    
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    return sendImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
