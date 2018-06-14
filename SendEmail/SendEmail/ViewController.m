//
//  ViewController.m
//  SendEmail
//
//  Created by wang bowen on 2018/6/13.
//  Copyright © 2018 wang bowen. All rights reserved.
//

#import "ViewController.h"
#import "Email/sendEmail.h"

@interface ViewController ()<sendEmailDelegate>

/* 发送邮按钮 */
@property (nonatomic, strong)               UIButton                        *  sendBut;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
    self.sendBut = [[UIButton alloc] init];
    [self.sendBut setTitle:@"点击崩溃->下次启动发送邮件" forState:(UIControlStateNormal)];
    [self.sendBut setBackgroundColor:[UIColor yellowColor]];
    [self.sendBut addTarget:self action:@selector(sendEmail:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.sendBut setFrame:CGRectMake(150, 250, 200, 60)];
    [self.view addSubview:self.sendBut];
    
    // 发送崩溃日志
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *dataPath = [path stringByAppendingPathComponent:@"AppLog/log.txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    
    if (data != nil) {
        sendEmail * send = [[sendEmail alloc] init];
        send.delegate = self;
        send.titleEmail = @"新的bug邮件";
        send.contentStr = @"这是默认的内容";
        send.ccEmail = @"1005573473@qq.com";
        //路径要放最后，设置路径后即代表发送邮件
        send.logPath = dataPath;
        
    }
    
}

- (void)sendEmail:(id)sender
{
    /////模拟崩溃，测试邮件发送
    NSArray * arr = [NSArray arrayWithObjects:@1,@2,@3, nil];
    NSLog(@"%@",arr[4]);
}

-(void)sendEmailBack:(BOOL)state message:(NSString *)messageStr
{
    NSLog(@"当前的异常------%@",messageStr);
}

#pragma mark - 收集崩溃信息（11-3王博文）
void UncaughtExceptionHandler(NSException *aException)
{
    /*需要记录错误原因,并且返回到服务器
     1,知道设备版本
     2,崩溃日期*/
    //设备类型 iPhone/iPhone6/iPhone6 Plus/iPad......
    
    // 异常的堆栈信息
    NSArray * stackArray = [aException callStackSymbols];
    // 出现异常的原因
    NSString * reason = [aException reason];
    // 异常名称
    NSString * name = [aException name];
    //设备版本
    NSString * version=[[UIDevice currentDevice]systemVersion];
    // 手机名称
    NSString * model=[[UIDevice currentDevice]model];
    // 崩溃时间
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateTime = [formatter stringFromDate:[NSDate date]];
    
    //获取项目名称
    NSString * executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    
    // app版本
    
    NSString *app_Version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *app_build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason（手机名称)：%@\n\nException reason（崩溃原因)：%@\n\nException name（崩溃名字)：%@\n\nxception name（崩溃时间)：%@\n\nException version（崩溃系统版本)：%@\n\nException reason（项目名称)：%@\n\nException reason（项目版本)：%@\n\nException reason（项目渠道版本)：%@\n\nException stack（堆栈信息)：%@",model,name, reason,dateTime,version,executableFile,app_Version,app_build,stackArray];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *iOSDirectory = [documentsPath stringByAppendingPathComponent:@"AppLog"];
    BOOL isSuccess = [fileManager createDirectoryAtPath:iOSDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    if (isSuccess) {
        NSLog(@"success");
        NSString *iOSPath = [iOSDirectory stringByAppendingPathComponent:@"log.txt"];
        BOOL isSuccess = [fileManager createFileAtPath:iOSPath contents:nil attributes:nil];
        if (isSuccess) {
            BOOL isSuccess = [exceptionInfo writeToFile:iOSPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (isSuccess) {
                NSLog(@"崩溃日志缓存成功");
            }
        }
    } else {
        NSLog(@"fail");
    }
    
    //    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"AppLog/eror.log"];
    //    NSFileManager *fileManager =[NSFileManager defaultManager];
    //    [fileManager createFileAtPath:path contents:[exceptionInfo dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    //    [exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/Log/eror.log",NSHomeDirectory()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
