//
//  LDRequestProxy.h
//  LDNetworking
//
//  Created by YueHui on 17/1/10.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "LDResponse.h"
#import "LDBaseRequest.h"

typedef void(^LDProxyCallback)(LDResponse *response);

@interface LDRequestProxy : NSObject

+ (LDRequestProxy *)sharedInstance;

//- (NSInteger)callGETWithParams:(NSDictionary *)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(LDProxyCallback)success failure:(LDProxyCallback)failure;
//
//- (NSInteger)callPOSTWithParams:(NSDictionary *)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(LDProxyCallback)success failure:(LDProxyCallback)failure;
//
//- (NSInteger)callUPLOADWithParams:(NSDictionary *)params url:(NSString *)url headers:(NSDictionary*)headers uploads:(AFConstructingBlock)upload methodName:(NSString *)methodName success:(LDProxyCallback)success failure:(LDProxyCallback)failure;
//
//- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
//- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

- (void)sendRequest:(LDBaseRequest *)request success:(LDProxyCallback)success failure:(LDProxyCallback)failure;

- (void)cancelRequest:(LDBaseRequest *)request;

- (void)cancelAllRequests;

@end
