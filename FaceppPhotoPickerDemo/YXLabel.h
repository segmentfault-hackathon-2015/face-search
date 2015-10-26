//
//  YXLabel.h
//  FaceppSDK+Demo
//
//  Created by Lson on 15/10/25.
//  Copyright © 2015年 Megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXLabel : UILabel

@property (nonatomic, strong) NSString *text;       // 文本的文字
@property (nonatomic, strong) UIFont   *font;       // 文本的字体

@property (nonatomic, assign) CGFloat   startScale; // 最初处于alpha = 0状态时的scale值
@property (nonatomic, assign) CGFloat   endScale;   // 最后处于alpha = 0状态时的scale值

@property (nonatomic, strong) UIColor  *backedLabelColor; // 不会消失的那个label的颜色
@property (nonatomic, strong) UIColor  *colorLabelColor;  // 最终会消失的那个label的颜色

- (void)startAnimation;


@end
