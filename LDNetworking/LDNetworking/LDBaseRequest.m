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

- (LDRequestType)requestType {
    return LDRequestTypeGet;
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
    
    //参数设置，如果设置了requestArgument，代理会被覆盖
    id param = request.requestArgument;
    if (param == nil) {
        param = [request.paramSource paramsForRequest:request];
    }
    if ([self isCorrectWithParamsData:param]) {    //检查参数正确性
        // 实际的网络请求
        if ([self isReachable]) {              // 有网络
            [[LDRequestProxy sharedInstance] sendRequest:request success:^(LDResponse *response) {
                [self successedOnCallingAPI:response];
            } failure:^(LDResponse *response) {
                [self failedOnCallingAPI:response withErrorState:LDRequestStateNetError];
            }];
        } else { // 没网
            [self failedOnCallingAPI:nil withErrorState:LDRequestStateNoNetWork];
        }
    } else {
        [self failedOnCallingAPI:nil withErrorState:LDRequestStateParamsError];
    }
}

#pragma mark -- 验证器(validator)方法
- (BOOL)isCorrectWithParamsData:(NSDictionary*)params {
    
    if ([self.validator respondsToSelector:@selector(request:isCorrectWithParamsData:)]) {
        return [self.validator request:self isCorrectWithParamsData:params];
    }else{
        return YES;
    }
}

- (BOOL)isCorrectWithResponseData:(NSDictionary*)data {
    
    if ([self.validator respondsToSelector:@selector(request:isCorrectWithResponseData:)]) {
        return [self.validator request:self isCorrectWithResponseData:data];
    }else{
        return YES;
    }
}

#pragma mark - api 回调执行的方法
- (void)successedOnCallingAPI:(LDResponse *)response {
    
    if ([self isCorrectWithResponseData:response.content]) {  //检查JSON
        [self beforePerformSuccessWithResponse:response];
        
        if ([self.delegate respondsToSelector:@selector(requestDidSuccess:)]) {
            [self.delegate requestDidSuccess:self];
        }
        if (self.successCompletionBlock) {
            self.successCompletionBlock(self);
        }
        
        [self afterPerformSuccessWithResponse:response];
    } else {
        [self failedOnCallingAPI:response withErrorState:LDRequestStateContentError];
    }
}

- (void)failedOnCallingAPI:(LDResponse *)response withErrorState:(LDRequestState)state {
    
}

/** 接口返回成功，返回控制器回调requestDidSuccess之前的操作 */
- (void)beforePerformSuccessWithResponse:(LDResponse *)response
{
    
}

/** 接口返回失败，返回控制器回调requestDidFailed之前的操作 */
- (void)beforePerformFailWithResponse:(LDResponse *)response
{
    
}

/** 接口返回成功，返回控制器回调requestDidSuccess之后的操作 */
- (void)afterPerformSuccessWithResponse:(LDResponse *)response
{
    
}

/** 接口返回失败，返回控制器回调requestDidFailed之后的操作 */
- (void)afterPerformFailWithResponse:(LDResponse *)response
{
    
}

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
- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}


@end
