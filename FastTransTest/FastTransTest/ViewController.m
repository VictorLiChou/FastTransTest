//
//  ViewController.m
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import "ViewController.h"
#import "NetWorkHelper.h"
#import "DeviceModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<deviceDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UILabel *wifiLabel;

@property (nonatomic,strong) UIProgressView *SendProgressView;

@property (nonatomic,strong) UILabel *SendLabel;

@property (nonatomic,strong) UIProgressView *RecProgressView;

@property (nonatomic,strong) UILabel *RecLabel;

@property (nonatomic,strong) MPMoviePlayerController *playVc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initServer];
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerDidstop:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

-(void)initServer{
    [DeviceModel currentDevice].delegate = self;
}

-(void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"FT";
    
    _wifiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 40)];
    [self.view addSubview:_wifiLabel];
    _wifiLabel.textAlignment = NSTextAlignmentCenter;
    [self refreshCurrentWifiName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentWifiName) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    NSArray *buttonTitles = @[@"上线", @"下线", @"发送文件", @"断开连接",@"播放视频"];
    
    for (int i = 0; i < buttonTitles.count; i ++)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 120.0f + 60*i, self.view.bounds.size.width - 40.0f, 40.0f)];
        [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        button.backgroundColor = [UIColor grayColor];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.tag = 1000+i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
        if (i == (buttonTitles.count - 1)) {
            
            self.SendProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            self.SendProgressView.frame = CGRectMake(20.0f, CGRectGetMaxY(button.frame) + 40.0f, self.view.bounds.size.width - 40.0f, 40.0f);
            self.SendProgressView.progressTintColor = [UIColor blueColor];
            self.SendProgressView.progress = 0;
            [self.view addSubview:self.SendProgressView];
            
            self.SendLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, CGRectGetMaxY(self.SendProgressView.frame), self.view.bounds.size.width - 40.0f, 40.0f)];
            self.SendLabel.text = @"正在发送";
            self.SendLabel.font = [UIFont systemFontOfSize:12.0f];
            [self.view addSubview:self.SendLabel];
            
            self.RecProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            self.RecProgressView.frame = CGRectMake(20.0f, CGRectGetMaxY(self.SendLabel.frame) + 20.0f, self.view.bounds.size.width - 40.0f, 40.0f);
            self.RecProgressView.progressTintColor = [UIColor blueColor];
            self.RecProgressView.progress = 0;
            [self.view addSubview:self.RecProgressView];

            self.RecLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, CGRectGetMaxY(self.RecProgressView.frame), self.view.bounds.size.width - 40.0f, 40.0f)];
            self.RecLabel.text = @"正在接收";
            self.RecLabel.font = [UIFont systemFontOfSize:12.0f];
            [self.view addSubview:self.RecLabel];
        }
    }
    
    
}

-(void)refreshCurrentWifiName{
    NSString * currentSsid = [NetWorkHelper getWifiName]?:@"无";
    if ([self isPersonHotPointOpen]) {
        currentSsid = [UIDevice currentDevice].name;
    }
    _wifiLabel.text = [NSString stringWithFormat:@"当前WiFi:%@",currentSsid];
}

-(void)buttonClicked:(UIButton *)btn{
    switch (btn.tag) {
        case 1000:{
            [[DeviceModel currentDevice] sendOnlineMsg];
        }
            break;
        case 1001:{
            [[DeviceModel currentDevice] sendOfflineMsg];
        }
            break;
        case 1002:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"testVideo" ofType:@"mp4"];
            NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
            FileModel * model = [[FileModel alloc] init];
            model.fileName = @"testVideo.mp4";
            model.fileSize = [NSString stringWithFormat:@"%ld",data.length];
            [[DeviceModel currentDevice] sendFileData:data withFileInfo:model toDevice:nil];
        }
            break;
        case 1003:{
            [[DeviceModel currentDevice] disconnect];
        }
            break;
        case 1004:{
            if (_RecProgressView.progress == 1) {
                [self playVideo];
            }
        }
        default:
            break;
    }
}

-(void)playVideo{
    
    NSString * filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"];
    BOOL suc = [[DeviceModel currentDevice].tcpServer.tempData writeToFile:filePath atomically:YES];
    if (suc) {
        
        self.playVc = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
        self.playVc.controlStyle = MPMovieControlStyleFullscreen;
        self.playVc.scalingMode = MPMovieScalingModeAspectFill;
        self.playVc.view.frame = self.view.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:self.playVc.view];
        [UIApplication sharedApplication].statusBarHidden = YES;
        [self.playVc prepareToPlay];
        [self.playVc play];
    }else{
        NSLog(@"write data fail...");
    }
}

-(void)videoPlayerDidstop:(NSNotification *)not{
    [self.playVc stop];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.playVc.view removeFromSuperview];
}

#pragma mark - deviceDelegate

-(void)didReceiveOnlineMsgFromDevice:(BaseDeviceModel *)device{
    NSLog(@"%@上线了...",device.userName);
}

-(void)didReceiveOfflineMsgFromDevice:(BaseDeviceModel *)device{
    NSLog(@"%@下线了...",device.userName);
}

-(void)didReceiveSendFileRequestWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device{
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"收到发送文件请求" message:[NSString stringWithFormat:@"%@请求给你发送文件:\n文件名:%@\n大小:%@",device.userName,file.fileName,file.fileSize] delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"好的", nil];
    alertView.tag = 100;
    [alertView show];
    
}

-(void)didReceiveAcceptReceiveFileMsgWithFileInfo:(FileModel *)file andStartIndex:(NSInteger)index FromDevice:(BaseDeviceModel *)device{
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"收到接收文件请求" message:[NSString stringWithFormat:@"%@请求从%ld开始接收文件%@\n是否发送？",device.userName,index,file.fileName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
    alertView.tag = 101;
    [alertView show];
}

-(void)didReceiveRefuseReceiveFileMsgWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device{
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"收到拒绝接收文件请求" message:[NSString stringWithFormat:@"%@拒绝接收文件%@",device.userName,file.fileName] delegate:self cancelButtonTitle:@"明白" otherButtonTitles: nil];
    alertView.tag = 102;
    [alertView show];
}

-(void)didSendDataLength:(NSInteger)sendLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file{

    _SendLabel.text = [NSString stringWithFormat:@"正在发送 %@ : %ld/%ld",file.fileName,sendLength,totalLength];
    _SendProgressView.progress = sendLength/(float)totalLength;
    
}

-(void)didRecvDatalength:(NSInteger)recvLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file{

    _RecLabel.text = [NSString stringWithFormat:@"正在接收 %@ : %ld/%ld",file.fileName,recvLength,totalLength];
    _RecProgressView.progress = recvLength/(float)totalLength;
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 100:{
        
            if (buttonIndex == 0) {
                [[DeviceModel currentDevice] refuseReceiveCurrentFile];
            }else{
                [[DeviceModel currentDevice] acceptReceiveCurrentFile];
            }
            
        }
            break;
        case 101:{
        
            if (buttonIndex == 0) {
                
            }else{
                [[DeviceModel currentDevice] sendCurrentFile];
            }
            
        }
        case 102:{
        
            
            
        }
        default:
            break;
    }
}

-(BOOL)isPersonHotPointOpen {
    BOOL bPersonalHotspotConnected = (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)==40)?YES:NO;
    if (bPersonalHotspotConnected) {
        return YES;
    } else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
