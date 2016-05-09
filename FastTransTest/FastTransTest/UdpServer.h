//
//  UdpServer.h
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDeviceModel.h"
#import "FileModel.h"

@protocol udpServerDelegate <NSObject>
@optional

-(void)didReceiveOnlineMsgFromDevice:(BaseDeviceModel *)device;

-(void)didReceiveOfflineMsgFromDevice:(BaseDeviceModel *)device;

-(void)didReceiveSendFileRequestWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device;

-(void)didReceiveAcceptReceiveFileMsgWithFileInfo:(FileModel *)file andStartIndex:(NSInteger)index FromDevice:(BaseDeviceModel *)device;

-(void)didReceiveRefuseReceiveFileMsgWithFileInfo:(FileModel *)file FromDevice:(BaseDeviceModel *)device;

@end

@interface UdpServer : NSObject

@property (nonatomic,weak)id<udpServerDelegate> delegate;

@property (nonatomic,strong)BaseDeviceModel * currentDevice;

+(instancetype)defaultServer;

-(BOOL)start;

-(BOOL)stop;

@end
