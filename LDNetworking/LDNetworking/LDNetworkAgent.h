//
//  LDRequestProxy.h
//  LDNetworking
//
//  Created by YueHui on 17/1/10.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBaseRequest.h"


@interface LDNetworkAgent : NSObject

+ (LDNetworkAgent *)sharedInstance;

- (void)addRequest:(YTKBaseRequest *)request;

- (void)cancelRequest:(LDBaseRequest *)request;

- (void)cancelAllRequests;

@end
