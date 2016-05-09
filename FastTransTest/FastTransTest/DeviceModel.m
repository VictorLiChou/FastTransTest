//
//  DeviceModel.m
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import "DeviceModel.h"

@interface DeviceModel ()<udpServerDelegate,tcpServerDelegate,msgClientDelegate,fileClientDelegate>

@property (nonatomic,strong)FileModel * tempFile;
@property (nonatomic,strong)BaseDeviceModel * tempDevice;
@property (nonatomic,assign)NSInteger tempStartIndex;
@property (nonatomic,strong)NSData * tempFileData;

@end

@implementation DeviceModel

+(instancetype)currentDevice{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.udpServer = [UdpServer defaultServer];
        self.udpServer.delegate = self;
        [self.udpServer start];
        self.tcpServer = [TcpServer defaultServer];
        self.tcpServer.delegate = self;
        [self.tcpServer start];
        self.msgClient = [MsgClient defaultClient];
        self.msgClient.delegate = self;
        self.fileClient = [FileClient defaultClient];
        self.fileClient.delegate = self;
        self.userName = [UIDevice currentDevice].name;
        self.host = [IPHelper deviceIPAdress];
    }
    return self;
}

-(void)sendOnlineMsg{
    [self.msgClient sendOnlineMsg];
}

-(void)sendOfflineMsg{
    [self.msgClient sendOfflineMsg];
}

-(void)sendCurrentFile{
    [self.fileClient sendData:_tempFileData withSatrtIndex:_tempStartIndex andFileInfo:_tempFile toDevice:_tempDevice];
}

-(void)refuseReceiveCurrentFile{
    NSString * dataStr = [NSString stringWithFormat:@"{\"commandType\":\"refuseReceiveFile\",\"fileName\":\"%@\",\"fileSize\":\"%@\"}",_tempFile.fileName,_tempFile.fileSize];
    [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toDevice:_tempDevice];
}

-(void)acceptReceiveCurrentFile{
    
    NSInteger startIndex = 0;
    NSData * data = self.tcpServer.recFileDic[_tempFile.fileName];
    if (data && [data isKindOfClass:[NSData class]]) {
        NSInteger len = data.length;
        if (len < _tempFile.fileSize.integerValue) {
            startIndex = len;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:[NSString stringWithFormat:@"%@文件已存在",_tempFile.fileName] delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
                [alertView show];

            });
            [self refuseReceiveCurrentFile];
            return;
        }
    }
    
    self.tcpServer.tempData = [NSMutableData dataWithData:data];
    self.tcpServer.tempFile = _tempFile;
    
    NSString * dataStr = [NSString stringWithFormat:@"{\"commandType\":\"acceptReceiveFile\",\"fileName\":\"%@\",\"fileSize\":\"%@\",\"startIndex\":\"%ld\"}",_tempFile.fileName,_tempFile.fileSize,startIndex];
    [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toDevice:_tempDevice];
}

-(void)sendFileData:(NSData *)data withFileInfo:(FileModel *)file toDevice:(BaseDeviceModel *)device{
    
    if (!device) {
        device = self.udpServer.currentDevice;
    }
    _tempFileData = data;
    NSString * dataStr = [NSString stringWithFormat:@"{\"commandType\":\"sendFileRequest\",\"fileName\":\"%@\",\"fileSize\":\"%@\"}",file.fileName,file.fileSize];
    [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toDevice:device];
}

-(void)disconnect{
    [self.tcpServer.tempSocket disconnect];
}

#pragma mark - udpDelegate

-(void)didReceiveOnlineMsgFromDevice:(BaseDeviceModel *)device{
    if ([self.delegate respondsToSelector:@selector(didReceiveOnlineMsgFromDevice:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveOnlineMsgFromDevice:device];
        });
    }
}

-(void)didReceiveOfflineMsgFromDevice:(BaseDeviceModel *)device{
    if ([self.delegate respondsToSelector:@selector(didReceiveOfflineMsgFromDevice:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveOfflineMsgFromDevice:device];
        });
    }
}

-(void)didReceiveSendFileRequestWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device{
    
    _tempFile = file;
    _tempDevice = device;
    
    if ([self.delegate respondsToSelector:@selector(didReceiveSendFileRequestWithFileInfo:FromDevice:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveSendFileRequestWithFileInfo:file FromDevice:device];
        });
    }
}

-(void)didReceiveAcceptReceiveFileMsgWithFileInfo:(FileModel *)file andStartIndex:(NSInteger)index FromDevice:(BaseDeviceModel *)device{
    
    _tempFile = file;
    _tempDevice = device;
    _tempStartIndex = index;
    
    if ([self.delegate respondsToSelector:@selector(didReceiveAcceptReceiveFileMsgWithFileInfo:andStartIndex:FromDevice:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveAcceptReceiveFileMsgWithFileInfo:file andStartIndex:index FromDevice:device];
        });
    }
}

-(void)didReceiveRefuseReceiveFileMsgWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device{
    
    _tempFile = file;
    _tempDevice = device;
    
    if ([self.delegate respondsToSelector:@selector(didReceiveSendFileRequestWithFileInfo:FromDevice:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveRefuseReceiveFileMsgWithFileInfo:file FromDevice:device];
        });
    }
}

#pragma mark - fileClientDelegate

-(void)didSendDataLength:(NSInteger)sendLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file{
    if ([self.delegate respondsToSelector:@selector(didSendDataLength:andTotalLength:withFileInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didSendDataLength:sendLength andTotalLength:totalLength withFileInfo:file];
        });
    }
}

#pragma mark - tcpServerDelegate

-(void)didRecvDatalength:(NSInteger)recvLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file{
    if ([self.delegate respondsToSelector:@selector(didRecvDatalength:andTotalLength:withFileInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didRecvDatalength:recvLength andTotalLength:totalLength withFileInfo:file];
        });
    }
}


@end
