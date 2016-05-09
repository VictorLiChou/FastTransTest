//
//  DeviceModel.h
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDeviceModel.h"
#import "UdpServer.h"
#import "TcpServer.h"
#import "MsgClient.h"
#import "FileClient.h"
#import <UIKit/UIKit.h>
#import "IPHelper.h"

@protocol deviceDelegate <NSObject>
@optional

-(void)didReceiveOnlineMsgFromDevice:(BaseDeviceModel *)device;

-(void)didReceiveOfflineMsgFromDevice:(BaseDeviceModel *)device;

-(void)didReceiveSendFileRequestWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device;

-(void)didReceiveAcceptReceiveFileMsgWithFileInfo:(FileModel *)file andStartIndex:(NSInteger)index FromDevice:(BaseDeviceModel *)device;

-(void)didReceiveRefuseReceiveFileMsgWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device;

-(void)didSendDataLength:(NSInteger)sendLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file;

-(void)didRecvDatalength:(NSInteger)recvLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file;

@end

@interface DeviceModel : BaseDeviceModel

@property (nonatomic,strong)UdpServer * udpServer;
@property (nonatomic,strong)TcpServer * tcpServer;
@property (nonatomic,strong)MsgClient * msgClient;
@property (nonatomic,strong)FileClient * fileClient;

@property (nonatomic,weak)id<deviceDelegate> delegate;

+(instancetype)currentDevice;

-(void)sendOnlineMsg;

-(void)sendOfflineMsg;

-(void)sendCurrentFile;

-(void)refuseReceiveCurrentFile;

-(void)acceptReceiveCurrentFile;

-(void)sendFileData:(NSData *)data withFileInfo:(FileModel *)file toDevice:(BaseDeviceModel *)device;

-(void)disconnect;

@end
