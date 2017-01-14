//
//  LDBaseRequest.h
//  LDNetworking
//
//  Created by YueHui on 17/1/9.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "LDResponse.h"

typedef NS_ENUM(NSUInteger, LDRequestState) {
    LDRequestStateDefault,     //没有产生过API请求，这个是manager的默认状态。
    LDRequestStateSuccess,     //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用。
    LDRequestStateContentError,   //API请求成功但返回数据不正确，如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    LDRequestStateNetError,    //API请求返回失败。
    LDRequestStateParamsError, //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    LDRequestStateTimeout,     //请求超时。具体超时时间的设置根据不同需求而有所差别。
    LDRequestStateNoNetWork    //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef NS_ENUM(NSUInteger, LDRequestType) {
    LDRequestTypeGet,
    LDRequestTypePost,
    LDRequestTypeUpload      //上传文件
};

@class LDBaseRequest;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void(^LDRequestCompletionBlock)(__kindof LDBaseRequest *request);

//api回调
@protocol LDBaseRequestCallBackDelegate <NSObject>

@required
- (void)requestDidSuccess:(LDBaseRequest *)request;
- (void)requestDidFailed:(LDBaseRequest *)request;

@end

#pragma mark -- 获取调用API所需要的参数
@protocol LDBaseRequestParamDelegate <NSObject>
@required
- (NSDictionary *)paramsForRequest:(LDBaseRequest *)request;
@end

#pragma mark -- 验证器，用于验证API的返回或者调用API的参数是否正确
@protocol LDBaseRequestValidator <NSObject>
@required
//验证CallBack数据的正确性
- (BOOL)request:(LDBaseRequest *)request isCorrectWithResponseData:(NSDictionary *)data;
//验证传递的参数数据的正确性
- (BOOL)request:(LDBaseRequest *)request isCorrectWithParamsData:(NSDictionary *)data;
@end

@interface LDBaseRequest : NSObject

@property (nonatomic, strong) NSURLSessionDataTask * requestTask;

@property (nonatomic, weak) id<LDBaseRequestParamDelegate> paramSource;
@property (nonatomic, weak) id<LDBaseRequestCallBackDelegate> delegate;
@property (nonatomic, weak) id<LDBaseRequestValidator> validator;

@property (nonatomic, copy) LDRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy) LDRequestCompletionBlock failureCompletionBlock;

- (BOOL)isExecuting;

///** 是否正在请求数据 */
//@property (nonatomic, assign, readonly) BOOL isLoading;
//@property (nonatomic, assign, readonly) BOOL isReachable;

/** 调用接口 */
- (void)loadData;
/** 调用接口, 并以block形式处理返回数据，如果使用这种方式，则响应控制器不需要遵守LDBaseRequestCallBackDelegate，响应请求类也不需要设置delegate */
- (void)loadDataWithCompletionBlockWithSuccess:(LDRequestCompletionBlock)success
                                       failure:(LDRequestCompletionBlock)failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

//- (void)deleteCache;

//取消全部网络请求
- (void)cancelAllRequests;

//取消网络请求
- (void)cancel;

/// 以下方法由子类继承来覆盖默认值

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的URL
- (NSString *)requestUrl;

/// 请求的BaseURL
- (NSString *)baseUrl;

/// Http请求的方法
- (LDRequestType)requestType;

/// 请求的参数列表
- (id)requestArgument;

/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary;

/// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructingBodyBlock;

// 拦截器方法，继承之后需要调用一下super，如果需要其他位置实现拦截， 使用代理
- (void)beforePerformSuccessWithResponse:(LDResponse *)response;
- (void)afterPerformSuccessWithResponse:(LDResponse *)response;

- (void)beforePerformFailWithResponse:(LDResponse *)response;
- (void)afterPerformFailWithResponse:(LDResponse *)response;

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params;
- (void)afterCallingAPIWithParams:(NSDictionary *)params;

@end
