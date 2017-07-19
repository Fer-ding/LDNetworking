//
//  LDNetworkPrivate.h
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBaseRequest.h"
#import "LDBatchRequest.h"

FOUNDATION_EXPORT void LDLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);


@interface LDNetworkPrivate : NSObject

+ (NSStringEncoding)stringEncodingWithRequest:(LDBaseRequest *)request;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

@end

@interface LDBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

@interface LDBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end


