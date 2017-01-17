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
#import "LDNetworkPrivate.h"

@implementation LDNetworkAgent {
    AFHTTPSessionManager *_manager;
    LDNetworkConfig *_config;
    AFJSONResponseSerializer *_jsonResponseSerializer;
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

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _jsonResponseSerializer;
}

#pragma mark - 

- (NSString *)buildRequestUrl:(LDBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    NSURL *temp = [NSURL URLWithString:detailUrl];
    // If detailUrl is valid URL。scheme==http或https，host==www.baidu.com。
    if (temp && temp.scheme && temp.host) {
        return detailUrl;
    }
    
    // Filter URL if needed
    NSArray *filters = [_config urlFilters];
    for (id<LDUrlFilterProtocol> f in filters) {
        detailUrl = [f filterUrl:detailUrl withRequest:request];
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
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];;
    
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
            return nil;
    }
}

- (void)addRequest:(LDBaseRequest *)request {
    NSParameterAssert(request != nil);
    
    NSError * __autoreleasing requestSerializationError = nil;
    
    request.requestTask = [self sessionTaskForRequest:request error:&requestSerializationError];
    
    if (requestSerializationError) {
        [self requestDidFailWithRequest:request error:requestSerializationError];
    }
    
    // Retain request
    LDLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addRequestToRecord:request];
    [request.requestTask resume];
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
            [request cancel];
        }
    }
}

- (BOOL)validateResult:(LDBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    
    BOOL result = [request statusCodeValidator];
    if (!result) {
        if (error) {
            *error = [NSError errorWithDomain:LDRequestValidationErrorDomain code:LDRequestValidationErrorInvalidStatusCode userInfo:@{NSLocalizedDescriptionKey:@"Invalid status code"}];
        }
        return result;
    }
    
    if ([request.validator respondsToSelector:@selector(request:isCorrectWithResponseData:)]) {
        result = [request.validator request:request isCorrectWithResponseData:request.responseJSONObject];
        if (!result) {
            if (error) {
                *error = [NSError errorWithDomain:LDRequestValidationErrorDomain code:LDRequestValidationErrorInvalidJSONFormat userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON format"}];
            }
            return result;
        }
    }
    return YES;
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    LDBaseRequest *request = _requestsRecord[@(task.taskIdentifier)];
    if (!request) {
        return;
    }
    
    LDLog(@"Finished Request: %@", NSStringFromClass([request class]));
    
    NSError * __autoreleasing serializationError = nil;
    NSError * __autoreleasing validationError = nil;
    
    NSError *requestError = nil;
    BOOL succeed = NO;
    
    request.responseObject = responseObject;
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        request.responseData = responseObject;
        request.responseString = [[NSString alloc] initWithData:responseObject encoding:[LDNetworkUtils stringEncodingWithRequest:request]];
        
        request.responseObject = [self.jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
        request.responseJSONObject = request.responseObject;
    }
    
    if (error) {
        succeed = NO;
        requestError = error;
    } else if (serializationError) {
        succeed = NO;
        requestError = serializationError;
    } else {
        succeed = [self request:request isCorrectWithResponseData:request.responseJSONObject];
        requestError = validationError;
    }
    
    if (succeed) {
        [self requestDidSucceedWithRequest:request];
    } else {
        [self requestDidFailWithRequest:request error:requestError];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestFromRecord:request];
        [request clearCompletionBlock];
    });

}

- (void)requestDidSucceedWithRequest:(LDBaseRequest *)request {
    
    [request requestCompleteFilter];
    if ([request.delegate respondsToSelector:@selector(requestDidSuccess:)]) {
        [request.delegate requestDidSuccess:request];
    }
    if (request.successCompletionBlock) {
        request.successCompletionBlock(request);
    }
}

- (void)requestDidFailWithRequest:(LDBaseRequest *)request error:(NSError *)error {
    request.error = error;
    LDLog(@"Request %@ failed, status code = %ld, error = %@",
           NSStringFromClass([request class]), (long)request.responseStatusCode, error.localizedDescription);
    
    [request requestFailedFilter];
    if ([request.delegate respondsToSelector:@selector(requestDidFailed:)]) {
        [request.delegate requestDidFailed:request];
    }
    if (request.failureCompletionBlock) {
        request.failureCompletionBlock(request);
    }
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

#pragma mark -- 验证器(validator)方法
- (BOOL)request:(LDBaseRequest *)request isCorrectWithParamsData:(NSDictionary *)data {
    
    if ([request.validator respondsToSelector:@selector(request:isCorrectWithParamsData:)]) {
        return [request.validator request:request isCorrectWithParamsData:data];
    }else{
        return YES;
    }
}

- (BOOL)request:(LDBaseRequest *)request isCorrectWithResponseData:(NSDictionary *)data {
    
    if ([request.validator respondsToSelector:@selector(request:isCorrectWithResponseData:)]) {
        return [request.validator request:request isCorrectWithResponseData:data];
    }else{
        return YES;
    }
}

@end
