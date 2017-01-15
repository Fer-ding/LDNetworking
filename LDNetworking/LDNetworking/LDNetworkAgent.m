//
//  LDRequestProxy.m
//  LDNetworking
//
//  Created by YueHui on 17/1/10.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDNetworkAgent.h"
#import "AFNetworking.h"
#import "LDNetworkConfig.h"

FOUNDATION_EXPORT void LDLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@implementation LDNetworkAgent {
    AFHTTPSessionManager *_manager;
    LDNetworkConfig *_config;
    NSMutableDictionary<NSNumber *, LDBaseRequest *> *_requestsRecord;
}

#pragma mark - life cycle
+ (LDNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _config = [LDNetworkConfig sharedInstance];
    _manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _requestsRecord = [NSMutableDictionary dictionary];
    
    return self;
}

#pragma mark - 

- (NSString *)buildRequestUrl:(LDBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    NSURL *temp = [NSURL URLWithString:detailUrl];
    // If detailUrl is valid URL。scheme==http或https，host==www.baidu.com。
    if (temp && temp.scheme && temp.host) {
        return detailUrl;
    }
    
    NSString *baseUrl;
    if ([request baseUrl].length > 0) {
        baseUrl = [request baseUrl];
    } else {
        baseUrl = [_config baseUrl];
    }
    
    // URL slash compability
    NSURL *url = [NSURL URLWithString:baseUrl];
    
    if (baseUrl.length > 0 && ![baseUrl hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    return [NSURL URLWithString:detailUrl relativeToURL:url].absoluteString;
}

- (AFHTTPRequestSerializer *)requestSerializerForRequest:(LDBaseRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == LDRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == LDRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    // If api needs to add custom value to HTTPHeaderField
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}

- (void)addRequest:(LDBaseRequest *)request {
    NSParameterAssert(request != nil);
}

- (void)cancelRequest:(LDBaseRequest *)request {
    NSParameterAssert(request != nil);
    
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSArray *allKeys = [_requestsRecord allKeys];
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            LDBaseRequest *request = _requestsRecord[key];
            // We are using non-recursive lock.
            // Do not lock `stop`, otherwise deadlock may occur.
            [request cancel];
        }
    }
}

- (BOOL)validateResult:(LDBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
}

- (void)requestDidSucceedWithRequest:(LDBaseRequest *)request {
}

- (void)requestDidFailWithRequest:(LDBaseRequest *)request error:(NSError *)error {
}

- (void)addRequestToRecord:(LDBaseRequest *)request {
    @synchronized (self) {
        _requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    }
}

- (void)removeRequestFromRecord:(LDBaseRequest *)request {
    @synchronized (self) {
        [_requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
        LDLog(@"Request queue size = %zd", [_requestsRecord count]);
    }
}


#pragma mark -

- (NSURLSessionTask *)sessionTaskForRequest:(LDBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    LDRequestType type = [request requestType];
    NSString *url = [self buildRequestUrl:request];
    
    id param = [request requestArgument];
    if ([request.paramSource respondsToSelector:@selector(paramsForRequest:)] && !param) {
        param = [request.paramSource paramsForRequest:request];
    }

    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:request];
    
    switch (type) {
        case LDRequestTypeGet:
           return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case LDRequestTypePost:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param constructingBodyWithBlock:nil error:error];
        case LDRequestTypeUpload:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:error];
        default:
            break;
    }
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError * _Nullable __autoreleasing *)error {
    return [self dataTaskWithHTTPMethod:method requestSerializer:requestSerializer URLString:URLString parameters:parameters constructingBodyWithBlock:nil error:error];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                           error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = nil;
    
    if (block) {
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request
                           completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *_error) {
                               [self handleRequestResult:dataTask responseObject:responseObject error:_error];
                           }];
    
    return dataTask;
}

@end
