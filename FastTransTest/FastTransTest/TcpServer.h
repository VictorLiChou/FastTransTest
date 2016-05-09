//
//  TcpServer.h
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileModel.h"
#import "GCDAsyncSocket.h"

@protocol tcpServerDelegate <NSObject>
@optional

-(void)didRecvDatalength:(NSInteger)recvLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file;

@end

@interface TcpServer : NSObject

@property (nonatomic,weak) id<tcpServerDelegate> delegate;

@property (nonatomic,strong)NSMutableDictionary * recFileDic;

@property (nonatomic,strong)NSMutableData * tempData;

@property (nonatomic,strong)FileModel * tempFile;

@property (nonatomic,strong)GCDAsyncSocket * tempSocket;

+(instancetype)defaultServer;

-(BOOL)start;

-(BOOL)stop;

@end
