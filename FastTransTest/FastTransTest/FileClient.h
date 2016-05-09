//
//  FileClient.h
//  FastTransTest
//
//  Created by houxiebing on 16/5/6.
//  Copyright © 2016年 houxiebing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDeviceModel.h"
#import "FileModel.h"
#import <UIKit/UIKit.h>

@protocol fileClientDelegate <NSObject>
@optional

-(void)didSendDataLength:(NSInteger)sendLength andTotalLength:(NSInteger)totalLength withFileInfo:(FileModel *)file;

@end

@interface FileClient : NSObject

@property (nonatomic,weak) id<fileClientDelegate> delegate;

+(instancetype)defaultClient;

-(void)sendData:(NSData *)data withSatrtIndex:(NSInteger)index andFileInfo:(FileModel *)file toDevice:(BaseDeviceModel *)device;

@end
