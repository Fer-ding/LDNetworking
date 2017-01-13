//
//  LDBaseRequest.m
//  LDNetworking
//
//  Created by YueHui on 17/1/9.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBaseRequest.h"
//#import "LDCache.h"
#import "LDRequestProxy.h"

@implementation LDBaseRequest

- (NSString *)requestUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (LDRequestMethod)requestMethod {
    return LDRequestMethodGet;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (id)requestArgument {
    return nil;
}

- (BOOL)isExecuting {
    //NSURLSessionDataTask比AFHTTPRequestOperation的isExceting多几个状态
    if(self.requestTask.state == NSURLSessionTaskStateRunning)
    {
        return YES;
    }else
    {
        return NO;
    }
}

#pragma mark - life cycle
- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - public Method
- (void)cancelAllRequests {
    [[LDRequestProxy sharedInstance] cancelAllRequests];
}

- (void)cancel {
    self.delegate = nil;
    self.paramSource = nil;
    self.validator = nil;
    [[LDRequestProxy sharedInstance] cancelRequest:self];
}

//- (void)deleteCache {
//    NSString *methodName = [self getMethodName];
//    [self.cache deleteCacheWithMethodName:methodName];
//}

#pragma mark - call
- (void)loadData {
    [self loadDataWithRequest:self];
}

- (void)loadDataWithCompletionBlockWithSuccess:(LDRequestCompletionBlock)success failure:(LDRequestCompletionBlock)failure {
    
    [self setWithCompletionBlockWithSuccess:success failure:failure];
    [self loadData];
}

- (void)setWithCompletionBlockWithSuccess:(LDRequestCompletionBlock)success failure:(LDRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (void)loadDataWithRequest:(LDBaseRequest *)request {
    
}

//#pragma mark -- 验证器(validator)方法
//-(BOOL)isCorrectWithParamsData:(NSDictionary*)params
//{
//    if ([self.validator respondsToSelector:@selector(request:isCorrectWithParamsData:)]) {
//        return [self.validator request:self isCorrectWithParamsData:params];
//    }else{
//        return YES;
//    }
//}
//
//-(BOOL)isCorrectWithResponseData:(NSDictionary*)data
//{
//    if ([self.validator respondsToSelector:@selector(request:isCorrectWithResponseData:)]) {
//        return [self.validator request:self isCorrectWithResponseData:data];
//    }else{
//        return YES;
//    }
//}
//-(NSString*)getMethodName
//{
//    NSString *methodName = [NSString stringWithFormat:@"%@_%@_%@",[self convertRequestMethod:self.child.requestMethod], @"token", self.child.requestUrl];
//    return methodName;
//}

#pragma mark - private method

//- (void)removeRequestIdWithRequestID:(NSInteger)requestId {
//    
//    NSNumber *requestIDToRemove = nil;
//    for (NSNumber *storedRequestId in self.requestIdList) {
//        if ([storedRequestId integerValue] == requestId) {
//            requestIDToRemove = storedRequestId;
//        }
//    }
//    if (requestIDToRemove) {
//        [self.requestIdList removeObject:requestIDToRemove];
//    }
//}
//
//- (NSString*)convertRequestMethod:(LDBaseRequestMethod)method {
//    NSString* str;
//    switch (method) {
//        case LDBaseRequestMethodPost:
//            str = @"POST";
//            break;
//        case LDBaseRequestMethodGet:
//            str = @"GET";
//            break;
//        case LDBaseRequestMethodUpload:
//            str = @"UPLOAD";
//            break;
//        default:
//            break;
//    }
//    return str;
//}

#pragma mark - getters and setters
//- (LDCache *)cache {
//    if (!_cache) {
//        _cache = [LDCache sharedInstance];
//    }
//    return _cache;
//}

//- (NSMutableArray *)requestIdList {
//    if (!_requestIdList) {
//        _requestIdList = [NSMutableArray array];
//    }
//    return _requestIdList;
//}
//
//- (BOOL)isReachable
//{
//    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
//        return YES;
//    } else {
//        return [[AFNetworkReachabilityManager sharedManager] isReachable];
//    }
//}
//
//- (BOOL)isLoading
//{
//    return [self.requestIdList count] > 0;
//}

@end
