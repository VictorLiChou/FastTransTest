//
//  MsgClient.h
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDeviceModel.h"
#import <UIKit/UIKit.h>

@protocol msgClientDelegate <NSObject>
@optional

@end

@interface MsgClient : NSObject

@property (nonatomic,weak)id<msgClientDelegate> delegate;

+(instancetype)defaultClient;

-(void)sendOnlineMsg;

-(void)sendOfflineMsg;

-(void)sendData:(NSData *)data toDevice:(BaseDeviceModel *)device;

@end
