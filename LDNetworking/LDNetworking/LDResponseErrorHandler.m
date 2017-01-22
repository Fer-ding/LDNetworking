//
//  LDResponseErrorHandler.m
//  LDNetworking
//
//  Created by YueHui on 17/1/22.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDResponseErrorHandler.h"

@implementation LDResponseErrorHandler

+ (void)errorHandlerWithRequest:(LDBaseRequest *)request errorHandler:(void(^)(NSError *newError))errorHandler {
    
    if (request.error) {
        if (errorHandler) {
            NSInteger errorCode = 0;
            NSString *message = @"";
            if (request.error.code == NSURLErrorNotConnectedToInternet) {
                errorCode = LDResponseErrorTypeNoNetWork;
                message = @"网络连接失败!";
            }
            if (request.responseStatusCode == NSURLErrorTimedOut) {
                errorCode = LDResponseErrorTypeTimeout;
                message = @"连接超时!";
            }
            
            request.error = [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:message}];
            errorHandler(request.error);
        } else {
            NSInteger errorCode = 200;
            NSString *message = @"";
            if ([request.responseJSONObject[@"status"] isEqualToString:@"false"]) {
//                return NO;
            } else {
                //其他的错误解析逻辑，包含重新暂时不返回回调重新发起网络请求
                //注意只修改errorCode和message就行了，下面会统一生成新的error
                //如果是重新发起网络请求，发起网络请求后就直接return，不再执行下面的逻辑
            }
            if (errorCode != 200) {
                request.error = [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:message}];
                if (errorHandler) {
                    errorHandler(request.error);
                }
            } else {
                if (errorHandler) {
                    errorHandler(nil);
                }
            }
        }
        
    }
}

@end
