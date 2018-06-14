//
//  sendEmail.h
//  sendEmail
//
//  Created by wang bowen on 2017/11/4.
//  Copyright © 2017年 wang bowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendEmailDelegate <NSObject>

-(void)sendEmailBack:(BOOL)state message:(NSString *)messageStr;

@end


@interface sendEmail : UIViewController


/**
 沙盒文件地址
 */
@property (nonatomic, strong)       NSString        * logPath;

/**
 抄送人邮件
 */
@property (nonatomic, strong)       NSString        * ccEmail;

/**
 邮件主题
 */
@property (nonatomic, strong)       NSString        * titleEmail;

/**
 邮件的内容
 */
@property (nonatomic, strong)       NSString        * contentStr;

/**
 界面显示的时间(秒)，不能为0，默认2.5秒
 */
@property (nonatomic, assign)       float               time;

/**
 安全码（发送者的一个属性，相当于密码，可不填）
 */
@property (nonatomic, strong)       NSString        * passCode;

@property (nonatomic, weak) id<sendEmailDelegate> delegate;

@end

