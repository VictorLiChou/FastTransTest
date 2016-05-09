//
//  FileClient.m
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import "FileClient.h"
#import "GCDAsyncSocket.h"

@interface FileClient ()

@property (nonatomic,strong)GCDAsyncSocket * fileClient;

@property (nonatomic,strong)FileModel * tempFile;

@property (nonatomic,strong)NSData *sendData;

@property (nonatomic,strong)NSTimer *sendFileTimer;

@end

@implementation FileClient

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
        self.fileClient = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}


-(void)refrehSendProgress{
    NSUInteger doneLength;
    NSUInteger totalLength;
    
    [self.fileClient progressOfWriteReturningTag:nil bytesDone:&doneLength total:&totalLength];
    if ([self.delegate respondsToSelector:@selector(didSendDataLength:andTotalLength:withFileInfo:)]) {
        if (doneLength > 0) {
            NSInteger sendLength = _tempFile.fileSize.integerValue - _sendData.length + doneLength;
            [self.delegate didSendDataLength:sendLength andTotalLength:_tempFile.fileSize.integerValue withFileInfo:_tempFile];
        }
    }
}

-(void)sendData:(NSData *)data withSatrtIndex:(NSInteger)index andFileInfo:(FileModel *)file toDevice:(BaseDeviceModel *)device{
    
    if (self.fileClient.isConnected) {
        [self.fileClient disconnect];
    }
    
    NSInteger sendDataLength = data.length - index;
    _sendData = [data subdataWithRange:NSMakeRange(index, sendDataLength)];
    _tempFile = file;
    NSError * error;
    BOOL connectSuccess = [self.fileClient connectToHost:device.host onPort:8080 error:&error];
    if (connectSuccess) {
        [self.fileClient writeData:_sendData withTimeout:-1 tag:1];
        
        if (!self.sendFileTimer) {
            self.sendFileTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refrehSendProgress) userInfo:nil repeats:YES];
        }else{
            [self.sendFileTimer setFireDate:[NSDate date]];
            [self.sendFileTimer fire];
        }
    }else{
        NSLog(@"connet failed... error == %@",error);
    }
    
}


#pragma mark - GCDAsyncSocketDelegate

- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock{
    return dispatch_get_main_queue();
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
    if ([self.delegate respondsToSelector:@selector(didSendDataLength:andTotalLength:withFileInfo:)]) {
        [self.delegate didSendDataLength:_tempFile.fileSize.integerValue andTotalLength:_tempFile.fileSize.integerValue withFileInfo:_tempFile];
    }
    
    [self.sendFileTimer setFireDate:[NSDate distantFuture]];
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    NSLog(@"socket did disconnect... error == %@",err);
    
    [self.sendFileTimer setFireDate:[NSDate distantFuture]];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    
}


@end
