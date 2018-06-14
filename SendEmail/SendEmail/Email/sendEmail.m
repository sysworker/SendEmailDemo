//
//  sendEmail.m
//  sendEmail
//
//  Created by wang bowen on 2017/11/4.
//  Copyright © 2017年 wang bowen. All rights reserved.
//

#import "sendEmail.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

#define UIColorFromRGB(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define MAIN_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define MAIN_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface sendEmail()<SKPSMTPMessageDelegate>

@property (nonatomic,strong)            NSTimer         * countDownTimer;

@end

@implementation sendEmail

-(void)viewDidLoad
{
    self.title = @"上传信息";
    [self.view setBackgroundColor:UIColorFromRGB(0xe5e5e5, 1)];
    
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    testActivityIndicator.center = CGPointMake(100.0f, 100.0f);//只能设置中心，不能设置大小414352
    [testActivityIndicator setFrame:CGRectMake((MAIN_SCREEN_WIDTH - 100)/2, (MAIN_SCREEN_HEIGHT -100)/2 -80, 100, 100)];
    testActivityIndicator.color = UIColorFromRGB(0x414352, 1);
    [testActivityIndicator startAnimating]; // 开始旋转
    //     [testActivityIndicator stopAnimating]; // 结束旋转
    //    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    [self.view addSubview:testActivityIndicator];
    
    UILabel * infoLab = [[UILabel alloc] init];
    [infoLab setText:@"正在反馈问题......"];
    [infoLab setFont:[UIFont fontWithName:@"PingFang SC" size:23.f]];
    [infoLab setTextColor:UIColorFromRGB(0x414352, 1)];
    [infoLab sizeToFit];
    [infoLab setFrame:CGRectMake((MAIN_SCREEN_WIDTH - infoLab.frame.size.width)/2,
                                 (MAIN_SCREEN_HEIGHT - infoLab.frame.size.height)/2 ,
                                 infoLab.frame.size.width, infoLab.frame.size.height)];
    [self.view addSubview:infoLab];
    
    [self sendEmail];
    
    if(self.time)
    {
    }else{
        self.time = 2.5f;
    }
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(countDownAction)
                                                         userInfo:nil
                                                          repeats:YES];
    
    
}

-(void)countDownAction
{
    self.time--;
    if (self.time<0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)setLogPath:(NSString *)logPath
{
    if (logPath) {
        _logPath = logPath;
        [self sendEmail];
    }
    
}

-(void)sendEmail
{
    SKPSMTPMessage * mail = [[SKPSMTPMessage alloc] init];
    // 崩溃时间
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * nowTime = [formatter stringFromDate:[NSDate date]];
    
    [mail setSubject:[NSString stringWithFormat:@"你有一个新的bug邮件--%@",nowTime]];              //邮件主题
    [mail setToEmail:@"sysworker@163.com"];          //接收邮件
    [mail setFromEmail:@"workerios@163.com"];        //发送者邮件
    [mail setRelayHost:@"smtp.163.com"];             //发送邮件代理服务器
    [mail setRequiresAuth:YES];
    [mail setLogin:@"workerios@163.com"];            //sysworker@163
    [mail setPass:@"worker001"];
    [mail setWantsSecure:YES];
    [mail setDelegate:self];
    
    if (self.titleEmail) {
        [mail setSubject:[NSString stringWithFormat:@"%@--%@",self.titleEmail,nowTime]];              //邮件主题
    }
    
    if (self.ccEmail) {
        [mail setCcEmail:self.ccEmail];                 //抄送
    }
    
    if (self.passCode) {
        [mail setPass:self.passCode];
    }
    
    
    NSString * logStr = [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil];

    NSString * cont = [NSString stringWithFormat:@"具体崩溃信息看附件\n\n%@\n\n\n\n\n\n\n\n%@",self.contentStr,logStr];

    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"text/plain",kSKPSMTPPartContentTypeKey,
                               cont,kSKPSMTPPartMessageKey,
                               @"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    NSDictionary *plainPart222;
    if (self.logPath) {
        NSString * logStr = [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:nil];
        plainPart222 = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain; charset=UTF-8;\nThis is a test Email",kSKPSMTPPartContentTypeKey,
                        logStr,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
        
    }else{
        plainPart222 = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain; charset=UTF-8;\nThis is a test Email",kSKPSMTPPartContentTypeKey,
                        @"传的沙盒地址为空",kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    }
    
    
//    plainPart222 附件
    [mail setParts:@[plainPart,plainPart222]];
    [mail send];
}

//发送邮件成功的回调 删除沙盒文件
-(void)messageSent:(SKPSMTPMessage *)message
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isSuccess = [fileManager removeItemAtPath:self.logPath error:nil];
    if (isSuccess) {
        [self.delegate sendEmailBack:YES message:@"发送邮件成功，删除沙盒文件成功"];
        
    }else{
        [self.delegate sendEmailBack:YES message:@"发送邮件成功，删除沙盒失败"];
        
    }
}

//发送邮件失败的回调
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    [self.delegate sendEmailBack:NO message:@"邮件发送失败"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

