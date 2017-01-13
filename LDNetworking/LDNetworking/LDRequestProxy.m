//
//  LDRequestProxy.m
//  LDNetworking
//
//  Created by YueHui on 17/1/10.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDRequestProxy.h"

FOUNDATION_EXPORT void LDLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@interface LDRequestProxy ()

@property (nonatomic, copy) LDProxyCallback success;
@property (nonatomic, copy) LDProxyCallback failure;

@property (nonatomic, strong) NSMutableDictionary *requestsRecord;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation LDRequestProxy

#pragma mark - life cycle
+ (LDRequestProxy *)sharedInstance {
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
    
    _manager = [AFHTTPSessionManager manager];
    _requestsRecord = [NSMutableDictionary dictionary];
    
    return self;
}

- (NSString *)buildRequestUrl:(LDBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    
    NSString *baseUrl;
    if ([request baseUrl].length > 0) {
        baseUrl = [request baseUrl];
    } else {
        
    }
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}

#pragma mark - public Method
- (void)sendRequest:(LDBaseRequest *)request success:(LDProxyCallback)success failure:(LDProxyCallback)failure {
    
    self.success = success;
    self.failure = failure;
    
    LDRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    
    //参数设置，如果设置了requestArgument，代理会被覆盖
    id param = request.requestArgument;
    if (param == nil) {
        param = [request.paramSource paramsForRequest:request];
    }
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headers = [request requestHeaderFieldValueDictionary];
    if (headers != nil) {
        for (id httpHeaderField in headers.allKeys) {
            id value = headers[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [_manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                LDLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    if (method == LDRequestMethodGet) {
        request.requestTask = [_manager GET:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequestResult:task responseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestResult:task responseObject:error];
        }];
    } else if (method == LDRequestMethodPost) {
        request.requestTask = [_manager POST:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequestResult:task responseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestResult:task responseObject:error];
        }];
    } else if (method == LDRequestMethodUpload) {
        request.requestTask = [_manager POST:url parameters:param constructingBodyWithBlock:constructingBlock progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequestResult:task responseObject:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestResult:task responseObject:error];
        }];
    } else {
        LDLog(@"Error, unsupport method type");
        return;
    }
    
    
    [self addOperation:request];
}

- (void)cancelRequest:(LDBaseRequest *)request {
    [request.requestTask cancel];
    [self removeOperation:request.requestTask];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        LDBaseRequest *request = copyRecord[key];
        [request cancel];
    }
}

#pragma mark - private Method
- (void)handleRequestResult:(NSURLSessionDataTask *)task responseObject:(id)responseObject {
    NSString *key = [self requestHashKey:task];
    LDBaseRequest *request = _requestsRecord[key];
    if (request && ![responseObject isKindOfClass:[NSError class]]) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            LDResponse *response = [[LDResponse alloc] initWithRequest:task.originalRequest responseObject:responseObject];
            self.success(response);
        } else {
            LDResponse *response = [[LDResponse alloc] initWithRequest:task.originalRequest error:responseObject];
            self.failure(response);
        }
    }
    [self removeOperation:task];
    [request clearCompletionBlock];
}

- (NSString *)requestHashKey:(NSURLSessionDataTask *)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

- (void)addOperation:(LDBaseRequest *)request {
    if (request.requestTask != nil) {
        NSString *key = [self requestHashKey:request.requestTask];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeOperation:(NSURLSessionDataTask *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
    LDLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}

@end
