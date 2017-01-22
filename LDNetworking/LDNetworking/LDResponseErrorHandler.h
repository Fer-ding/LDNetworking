//
//  LDResponseErrorHandler.h
//  LDNetworking
//
//  Created by YueHui on 17/1/22.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBaseRequest.h"

#pragma mark -- LDResponseErrorType各种状态

typedef NS_ENUM(NSInteger, LDResponseErrorType) {
    LDResponseErrorTypeDefault,       //没有API请求，默认状态。
    LDResponseErrorTypeSuccess,       //API请求成功且返回数据正确。
    LDResponseErrorTypeNetError,      //API请求返回失败。
    LDResponseErrorTypeContentError,  //API请求成功但返回数据不正确。
    LDResponseErrorTypeParamsError,   //API请求参数错误。
    LDResponseErrorTypeTimeout,       //API请求超时。
    LDResponseErrorTypeNoNetWork      //网络故障。
};

@interface LDResponseErrorHandler : NSObject

+ (void)errorHandlerWithRequest:(LDBaseRequest *)request errorHandler:(void(^)(NSError *newError))errorHandler;

@end
