//
//  LDbatchRequestAgent.h
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LDBatchRequest;

@interface LDBatchRequestAgent : NSObject

+ (LDBatchRequestAgent *)sharedInstance;
- (void)addBatchRequest:(LDBatchRequest *)request;
- (void)removeBatchRequest:(LDBatchRequest *)request;

@end
