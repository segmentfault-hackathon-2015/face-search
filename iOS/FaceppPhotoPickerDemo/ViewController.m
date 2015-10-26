//
//  ViewController.m
//  FaceppPhotoPickerDemo
//
//  Created by youmu on 12-12-5.
//  Copyright (c) 2012年 Megvii. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "../APIKey+APISecret.h"
#import "ImageViewController.h"

@implementation ViewController
{
    NSDictionary *_positiongDic;
    UIImage *_imageToDisplay;
    UIWindow *windows;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _positiongDic  = [[NSDictionary alloc]init];
	// Do any additional setup after loading the view, typically from a nib.
    imagePicker = [[UIImagePickerController alloc] init];
    windows =   [[[UIApplication sharedApplication] delegate] window];

    // initialize
    NSString *API_KEY = _API_KEY;
    NSString *API_SECRET = _API_SECRET;

    [FaceppAPI initWithApiKey:API_KEY andApiSecret:API_SECRET andRegion:APIServerRegionCN];
    
    // turn on the debug mode
    [FaceppAPI setDebugMode:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pickFromCameraButtonPressed:(id)sender {
        
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imagePicker animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"failed to camera"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        [alert release];
    }
}

-(IBAction)pickFromLibraryButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:imagePicker animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"failed to access photo library"
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        [alert release];
    }
}

- (IBAction)imageAnalyPressed:(id)sender
{
    ImageViewController *vc = [[ImageViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}



- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// Use facepp SDK to detect faces
-(void) detectWithImage: (UIImage*) image {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    FaceppResult *result = [[FaceppAPI detection] detectWithURL:nil orImageData:UIImageJPEGRepresentation(image, 0.5) mode:FaceppDetectionModeNormal attribute:FaceppDetectionAttributeNone];
    if (result.success) {
        double image_width = [[result content][@"img_width"] doubleValue] *0.01f;
        double image_height = [[result content][@"img_height"] doubleValue] * 0.01f;

        UIGraphicsBeginImageContext(image.size);
        [image drawAtPoint:CGPointZero];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0, 0, 1.0, 1.0);
        CGContextSetLineWidth(context, image_width * 0.7f);
        
        // draw rectangle in the image
        int face_count = [[result content][@"face"] count];
        for (int i=0; i<face_count; i++) {
            double width = [[result content][@"face"][i][@"position"][@"width"] doubleValue];
            double height = [[result content][@"face"][i][@"position"][@"height"] doubleValue];
            CGRect rect = CGRectMake(([[result content][@"face"][i][@"position"][@"center"][@"x"] doubleValue] - width/2) * image_width,
                                     ([[result content][@"face"][i][@"position"][@"center"][@"y"] doubleValue] - height/2) * image_height,
                                     width * image_width,
                                     height * image_height);
            CGContextStrokeRect(context, rect);
        }
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        float scale = 1.0f;
        scale = MIN(scale, 280.0f/newImage.size.width);
        scale = MIN(scale, 257.0f/newImage.size.height);
        [imageView setFrame:CGRectMake(imageView.frame.origin.x,
                                       imageView.frame.origin.y,
                                       newImage.size.width * scale,
                                       newImage.size.height * scale)];
        [imageView setImage:newImage];
    } else {
        // some errors occurred
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"error message: %@", [result error].message]
                              message:@""
                              delegate:nil
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        [alert release];
    }
    [image release];
    [MBProgressHUD hideHUDForView:windows animated:YES];
    
    [pool release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:windows];
    hud.labelText = @"努力匹配照片中";
    hud.tag = 100;
    //    hud.detailsLabelText = message;
//    hud.accessibilityLabel = @"加载中";
    [windows addSubview:hud];
    [hud show:YES];

//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIImage *sourceImage = info[UIImagePickerControllerOriginalImage];
    _imageToDisplay = [self fixOrientation:sourceImage];
    
    // perform detection in background thread
//    [self performSelectorInBackground:@selector(detectWithImage:) withObject:[imageToDisplay retain]];
        [self performSelectorInBackground:@selector(recongnizeWithImage:) withObject:[_imageToDisplay retain]];
    [picker dismissViewControllerAnimated:NO completion:nil];
}
-(void)recongnizeWithImage:(UIImage *)img
{
    //        FaceppResult *result = [[FaceppAPI detection] detectWithURL:nil orImageData:UIImageJPEGRepresentation(image, 0.5) mode:FaceppDetectionModeNormal attribute:FaceppDetectionAttributeNone];
    
    // recognize
    NSString *groupName = @"group_test";
    FaceppResult *recognizeResult  =  [[FaceppAPI recognition] identifyWithGroupId:nil
                                                                       orGroupName:groupName
                                                                            andURL:nil
                                                                       orImageData:UIImageJPEGRepresentation(img, 0.5)
                                                                       orKeyFaceId:nil
                                                                             async:NO];
    NSLog(@"recognizeResult:%@",recognizeResult);
    if (recognizeResult == nil) {
        [MBProgressHUD hideHUDForView:windows animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"匹配失败，请重试" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
//    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
//    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    NSDictionary *dataDic = recognizeResult.content;
    if (dataDic && [dataDic isKindOfClass:[NSDictionary class]])
    {
       NSArray *faceArr =  [dataDic objectForKey:@"face"];
        if (faceArr.count == 0)
        {
            [MBProgressHUD hideHUDForView:windows animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"没有匹配到对应的人，请更换照片重试" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            return;
        }
        NSDictionary *candidateDic = [faceArr firstObject];
        NSArray *candidArr =  [candidateDic objectForKey:@"candidate"];
        _positiongDic = [candidateDic objectForKey:@"position"];
        
        if (candidArr && [candidArr isKindOfClass:[NSArray class]]) {
          NSDictionary *dic =   [candidArr firstObject];
            NSString *confidence = [dic objectForKey:@"confidence"];
            if (  [confidence doubleValue] <= 20)
            {
                [MBProgressHUD hideHUDForView:windows animated:YES];

                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"匹配度低于20%，请更换照片重试" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                return;

            };
           NSString *personName = [dic objectForKey:@"person_name"];
            NSLog(@"personName = %@",personName);
            [self httpAsynchronousRequest:personName];
             }
        
            
       
        

    }
  

    
}

- (void)httpAsynchronousRequest:(NSString *)personName
{
    NSString *urlStr = [NSString stringWithFormat:@"http://10.2.200.138:4567/person_info/%@",personName];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error)
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [MBProgressHUD hideHUDForView:windows animated:YES];

                                       UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请求服务器数据库错误" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                       [alertView show];
                                       [alertView release];
                                       return ;

                                   });
                                 NSLog(@"Httperror:%@%ld", error.localizedDescription,(long)error.code);
                               }else{
                                   
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                       NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   NSLog(@"HttpResponseCode:%ld", (long)responseCode);
                                   NSLog(@"HttpResponseBody %@",dataDic);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       
                                       
                                      ImageViewController *imgVC = [[ImageViewController alloc]initWithPersonData:dataDic andPositionData:_positiongDic andImage:_imageToDisplay];
                                       
//                                       UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imgVC];

                                      [self presentViewController:imgVC animated:YES completion:nil];
                                      [imgVC release];
                                       [MBProgressHUD hideHUDForView:windows animated:YES];

//                                      [nav release];
                                   });
                               }
                           }];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) dealloc {
    [imagePicker release];
    [super dealloc];
}
@end
