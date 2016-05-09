//
//  MsgClient.m
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import "MsgClient.h"
#import "GCDAsyncUdpSocket.h"
#import "DeviceModel.h"

@interface MsgClient ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic,strong) GCDAsyncUdpSocket * msgClient;

@end

@implementation MsgClient

+(instancetype)defaultClient{
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
        self.msgClient = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        [self.msgClient enableBroadcast:YES error:nil];
    }
    return self;
}

-(void)sendOnlineMsg{
    NSString * dataStr = [NSString stringWithFormat:@"{\"commandType\":\"onlLine\",\"userName\":\"%@\"}",[UIDevice currentDevice].name];
    if ([self isPersonHotPointOpen]) {
        DeviceModel * model = self.delegate;
        [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toHost:model.udpServer.currentDevice.host port:8080 withTimeout:-1 tag:0];
        
//        [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toHost:@"225.228.0.1" port:8080 withTimeout:-1 tag:0];
    }else{
        [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:8080 withTimeout:-1 tag:0];
    }
}

-(void)sendOfflineMsg{
    NSString * dataStr = [NSString stringWithFormat:@"{\"commandType\":\"offLine\",\"userName\":\"%@\"}",[UIDevice currentDevice].name];
    if ([self isPersonHotPointOpen]) {
        DeviceModel * model = self.delegate;
        [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toHost:model.udpServer.currentDevice.host port:8080 withTimeout:-1 tag:0];
        
//        [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toHost:@"225.228.0.1" port:8080 withTimeout:-1 tag:0];
    }else{
        [self.msgClient sendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:8080 withTimeout:-1 tag:0];
    }
}


-(void)sendData:(NSData *)data toDevice:(BaseDeviceModel *)device{
    [self.msgClient sendData:data toHost:device.host port:8080 withTimeout:-1 tag:0];
}

-(BOOL)isPersonHotPointOpen {
    BOOL bPersonalHotspotConnected = (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)==40)?YES:NO;
    if (bPersonalHotspotConnected) {
        return YES;
    } else {
        return NO;
    }
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

}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
}



@end
