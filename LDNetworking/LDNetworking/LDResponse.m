//
//  LDResponse.m
//  LDNetworking
//
//  Created by YueHui on 17/1/10.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDResponse.h"

@interface LDResponse ()

/** 响应状态 */
@property (nonatomic, assign, readwrite) LDResponseStatus status;
/** 回调json字符串 */
@property (nonatomic, copy, readwrite) NSString *contentString;
/** 回调对象, 字典或者数组 */
@property (nonatomic, copy, readwrite) id content;
///** 请求记录id (app生命周期内递增不会减少) */
//@property (nonatomic, assign, readwrite) NSInteger requestId;
/** 请求 */
@property (nonatomic, copy, readwrite) NSURLRequest *request;
/** 回调json的二进制Data */
@property (nonatomic, copy, readwrite) NSData *responseData;
/** 回调json的实际数据字典(不含返回码及message) */
@property (nonatomic, copy, readwrite) NSDictionary *result;
/** 返回码 */
@property (nonatomic,assign, readwrite) int responseCode;
/** 返回message */
@property (nonatomic,copy, readwrite) NSString *responseMessage;
/** 错误信息 */
@property (nonatomic, strong, readwrite) NSError *error;
/** 是否是缓存数据 */
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation LDResponse

#pragma mark - life cycle

- (instancetype)initWithRequest:(NSURLRequest *)request responseObject:(id)responseObject
{
    self = [super init];
    if (self) {
        self.status = LDResponseStatusSuccess;
        
        //        self.requestId = [requestId integerValue];
        self.request = request;
        //        self.requestParams = params;
        
        self.responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        
#ifdef DEBUG
        NSString *contentString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        self.contentString = contentString;
#else
        
#endif
        
        
        self.content = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:NULL];
        self.responseCode = [self.content[@"err"] intValue];
        self.responseMessage = self.content[@"message"];
        self.result = self.content;
        
        self.isCache = NO;
        
        NSLog(@"url : %@\n successCode : %d", self.request.URL, self.responseCode);
    }
    return self;
}

- (instancetype)initWithRequestId:(NSNumber *)requestId request:(NSURLRequest *)request error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.status = [self responseStatusWithError:error];
        
        //        self.requestId = [requestId integerValue];
        self.request = request;
        //        self.requestParams = params;
        
        NSError *underError = error.userInfo[@"NSUnderlyingError"];
        NSData *responseData = underError.userInfo[@"com.alamofire.serialization.response.error.data"];
        self.responseData = responseData;
        self.contentString = @"";
        self.error = error;
        
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
            self.responseCode = [self.content[@"err"] intValue];
            self.result = self.content;
        } else {
            self.content = nil;
        }
        
        self.isCache = NO;
        
        NSLog(@"url : %@\n successCode : %d", self.request.URL, self.responseCode);
    }
    return self;
}

// 使用initWithData的response，它的isCache是YES，上面两个函数生成的response的isCache是NO
- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        self.status = LDResponseStatusSuccess;
        
        //        self.requestId = 0;
        self.request = nil;
        
        self.responseData = [data copy];
        
#ifdef DEBUG
        NSString *contentString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        self.contentString = contentString;
#else
        
#endif
        self.content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        self.responseCode = [self.content[@"err"] intValue];
        self.responseMessage = self.content[@"message"];
        self.result = self.content;
        
        self.isCache = YES;
        
        NSLog(@"url : %@\n successCode : %d", self.request.URL, self.responseCode);
    }
    return self;
}

#pragma mark - private methods
- (LDResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        LDResponseStatus result = LDResponseStatusNoNetwork;
        
        NSLog(@"url : %@\n errorCode: %zd\n errorMessage: %@",self.request.URL ,error.code, error.userInfo[@"NSLocalizedDescription"]);
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = LDResponseStatusTimeout;
        }
        return result;
    } else {
        return LDResponseStatusSuccess;
    }
}


@end
