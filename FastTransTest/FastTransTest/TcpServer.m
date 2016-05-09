//
//  TcpServer.m
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import "TcpServer.h"

@interface TcpServer()<GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket * tcpServerSocket;

@property (nonatomic,assign) BOOL shouldAcceptPort;

@end


@implementation TcpServer

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
        self.recFileDic = [NSMutableDictionary dictionary];
        self.tcpServerSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}

-(BOOL)start{
    NSError * error;
    if (self.tcpServerSocket) {
        BOOL acceptSuccess = [self.tcpServerSocket acceptOnPort:8080 error:&error];
        self.shouldAcceptPort = YES;
        if (acceptSuccess) {
            return YES;
        }
    }
    NSLog(@"tcpserver accept fail... error == %@",error);
    return NO;
}

-(BOOL)stop{
    self.shouldAcceptPort = NO;
    return YES;
}

#pragma mark - GCDAsyncSocketDelegate

- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock{
    return dispatch_get_main_queue();
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    
    if (self.shouldAcceptPort) {
        _tempSocket = newSocket;
        
        if (!self.recFileDic[self.tempFile.fileName]) {
            self.tempData = [NSMutableData data];
        }
        [self.recFileDic setObject:self.tempData forKey:self.tempFile.fileName];
        
        [_tempSocket readDataWithTimeout:-1 tag:1];
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if (self.shouldAcceptPort) {
        [_tempData appendData:data];
        if ([self.delegate respondsToSelector:@selector(didRecvDatalength:andTotalLength:withFileInfo:)]) {
            [self.delegate didRecvDatalength:_tempData.length andTotalLength:_tempFile.fileSize.integerValue withFileInfo:_tempFile];
        }
        
        [_tempSocket readDataWithTimeout:-1 tag:1];
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    
}

@end
