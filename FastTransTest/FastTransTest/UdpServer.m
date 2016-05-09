//
//  UdpServer.m
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import "UdpServer.h"
#import "GCDAsyncUdpSocket.h"
#import "IPHelper.h"

@interface UdpServer()<GCDAsyncUdpSocketDelegate>

@property (nonatomic,strong)GCDAsyncUdpSocket * udpServerSocket;

@property (nonatomic,strong)NSMutableDictionary * deviceDic;

@end

@implementation UdpServer


+(instancetype)defaultServer{
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
        self.udpServerSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        [self.udpServerSocket setIPv4Enabled:NO];
        [self.udpServerSocket enableBroadcast:YES error:nil];
        self.deviceDic = [NSMutableDictionary dictionary];
        NSError * error;
        BOOL bindSuccess = [self.udpServerSocket bindToPort:8080 error:&error];
        if (!bindSuccess) {
            NSLog(@"udpserver bind fail... error == %@",error);
        }
        
//        BOOL Suc = [self.udpServerSocket joinMulticastGroup:@"225.228.0.1" error:&error];
//        if (!Suc) {
//            NSLog(@"udpserver join group fail... error == %@",error);
//        }
    }
    return self;
}

-(BOOL)start{
    NSError * error;
    if (self.udpServerSocket) {
        BOOL beginRecSuccess = [self.udpServerSocket beginReceiving:&error];
        if (beginRecSuccess) {
            return YES;
        }
    }
    NSLog(@"udpserver start fail... error == %@",error);
    return NO;
}

-(BOOL)stop{
    if (self.udpServerSocket) {
        [self.udpServerSocket pauseReceiving];
    }
    NSLog(@"udpserver stopped...");
    return YES;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    NSString *host;
    uint16_t port;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    host = [host stringByReplacingOccurrencesOfString:@"::ffff:" withString:@""];
    if (![host isEqualToString:[IPHelper deviceIPAdress]]) {
        if (data && [data isKindOfClass:[NSData class]])
        {
            NSError *error;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (dic && [dic isKindOfClass:[NSDictionary class]])
            {
//                NSLog(@"udp rec dic == %@",dic);
                
                NSString * commandType = dic[@"commandType"];
                if (commandType) {
                    if ([commandType isEqualToString:@"onlLine"]) {
                        if ([self.delegate respondsToSelector:@selector(didReceiveOnlineMsgFromDevice:)]) {
                            BaseDeviceModel * device = self.deviceDic[host];
                            if (!device) {
                                device = [[BaseDeviceModel alloc] init];
                                device.host = host;
                                device.userName = dic[@"userName"];
                                [self.deviceDic setObject:device forKey:host];
                            }
                            _currentDevice = device;
                            [self.delegate didReceiveOnlineMsgFromDevice:device];
                        }
                    }else if ([commandType isEqualToString:@"offLine"]){
                        BaseDeviceModel * device = self.deviceDic[host];
                        if (device) {
                            if ([self.delegate respondsToSelector:@selector(didReceiveOfflineMsgFromDevice:)]) {
                                [self.delegate didReceiveOfflineMsgFromDevice:device];
                            }
                            [self.deviceDic removeObjectForKey:host];
                        }
                    }else if ([commandType isEqualToString:@"sendFileRequest"]){
                        BaseDeviceModel * device = self.deviceDic[host];
                        if (device) {
                            if ([self.delegate respondsToSelector:@selector(didReceiveSendFileRequestWithFileInfo:FromDevice:)]) {
                                FileModel * file = [[FileModel alloc] init];
                                file.fileName = dic[@"fileName"];
                                file.fileSize = dic[@"fileSize"];
                                [self.delegate didReceiveSendFileRequestWithFileInfo:file FromDevice:device];
                            }
                        }
                    }else if ([commandType isEqualToString:@"acceptReceiveFile"]){
                        BaseDeviceModel * device = self.deviceDic[host];
                        if (device) {
                            if ([self.delegate respondsToSelector:@selector(didReceiveAcceptReceiveFileMsgWithFileInfo:andStartIndex:FromDevice:)]) {
                                FileModel * file = [[FileModel alloc] init];
                                file.fileName = dic[@"fileName"];
                                file.fileSize = dic[@"fileSize"];
                                NSInteger startIndex = [dic[@"startIndex"] integerValue];
                                [self.delegate didReceiveAcceptReceiveFileMsgWithFileInfo:file andStartIndex:startIndex FromDevice:device];
                            }
                        }
                    }else if ([commandType isEqualToString:@"refuseReceiveFile"]){
                        BaseDeviceModel * device = self.deviceDic[host];
                        if (device) {
                            if ([self.delegate respondsToSelector:@selector(didReceiveRefuseReceiveFileMsgWithFileInfo:FromDevice:)]) {
                                FileModel * file = [[FileModel alloc] init];
                                file.fileName = dic[@"fileName"];
                                file.fileSize = dic[@"fileSize"];
                                [self.delegate didReceiveRefuseReceiveFileMsgWithFileInfo:file FromDevice:device];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
}

@end
