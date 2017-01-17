//
//  LDBaseRequest.m
//  LDNetworking
//
//  Created by YueHui on 17/1/9.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBaseRequest.h"
#import "AFNetworking.h"
#import "LDNetworkAgent.h"
#import "LDNetworkConfig.h"

@implementation LDBaseRequest

#pragma mark - life cycle
- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - Request and Response Information

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (NSInteger)responseStatusCode {
    return self.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}

- (NSURLRequest *)currentRequest {
    return self.requestTask.currentRequest;
}

- (NSURLRequest *)originalRequest {
    return self.requestTask.originalRequest;
}

- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

#pragma mark - Request Action

- (void)loadData {
    [[LDNetworkAgent sharedInstance] addRequest:self];
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

- (void)cancelAllRequests {
    [[LDNetworkAgent sharedInstance] cancelAllRequests];
}

- (void)cancel {
    self.delegate = nil;
    self.paramSource = nil;
    self.validator = nil;
    [[LDNetworkAgent sharedInstance] cancelRequest:self];
}

#pragma mark - Subclass Override

- (void)requestCompleteFilter {
}

- (void)requestFailedFilter {
    
}

- (NSString *)requestUrl {
    return @"";
}

- (NSString *)cdnUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (id)requestArgument {
    return nil;
}

- (LDRequestType)requestType {
    return LDRequestTypeGet;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    return (statusCode >= 200 && statusCode <= 299);
}

@end
