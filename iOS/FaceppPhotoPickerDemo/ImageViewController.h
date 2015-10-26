//
//  ImageViewController.h
//  FaceppSDK+Demo
//
//  Created by Lson on 15/10/24.
//  Copyright © 2015年 Megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
-(id)initWithPersonData:(NSDictionary *)personDic andPositionData:(NSDictionary *)positionDic andImage:(UIImage *)personImg;
- (void)setImage:(UIImage *)image andInfo:(NSDictionary *)info;

@end
