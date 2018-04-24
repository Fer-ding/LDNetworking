//
//  LDBaseRequest.h
//  LDNetworking
//
//  Created by YueHui on 17/1/9.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const LDRequestValidationErrorDomain;

NS_ENUM(NSInteger) {
    LDRequestValidationErrorInvalidStatusCode = -8,
    LDRequestValidationErrorRequestFailed = -9,
    };

typedef NS_ENUM(NSUInteger, LDRequestType) {
    LDRequestTypeGet,
    LDRequestTypePost,
    LDRequestTypeUpload      //上传文件
};
    
typedef NS_ENUM(NSInteger , LDRequestPriority) {
    LDRequestPriorityLow = -4L,
    LDRequestPriorityDefault = 0,
    LDRequestPriorityHigh = 4,
};

@protocol AFMultipartFormData;

@class LDBaseRequest;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void(^LDRequestCompletionBlock)(__kindof LDBaseRequest *request);

/// Request Accessory，可以hook Request的start和stop
@protocol LDRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

//api回调
@protocol LDBaseRequestCallBackDelegate <NSObject>

@optional
- (void)requestDidSuccess:(LDBaseRequest *)request;
- (void)requestDidFailed:(LDBaseRequest *)request;

@end
    
#pragma mark -- 验证器，用于验证API的返回或者调用API的参数是否正确
@protocol LDBaseRequestValidator <NSObject>
@optional
//验证CallBack数据的正确性
- (BOOL)request:(LDBaseRequest *)request isCorrectWithResponseData:(NSDictionary *)data;
//验证传递的参数数据的正确性
- (BOOL)request:(LDBaseRequest *)request isCorrectWithParamsData:(NSDictionary *)data;
@end


#pragma mark - 负责重新组装API数据的对象
@protocol LDBaseRequestDataReformer <NSObject>
- (id)request:(LDBaseRequest *)request reformData:(NSDictionary *)data;
@end

@interface LDBaseRequest : NSObject

@property (nonatomic, weak) id<LDBaseRequestCallBackDelegate> delegate;
@property (nonatomic, weak) id<LDBaseRequestValidator> validator; //!<验证器

@property (nonatomic, copy) LDRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy) LDRequestCompletionBlock failureCompletionBlock;

@property (nonatomic, strong) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readonly) NSURLRequest *currentRequest;
@property (nonatomic, strong, readonly) NSURLRequest *originalRequest;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) NSInteger responseStatusCode;
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) id responseJSONObject;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSMutableArray<id<LDRequestAccessory>> *requestAccessories;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

/// 请求的优先级, 优先级高的请求会从请求队列中优先出列.Default is `LDRequestPriorityDefault`.
@property (nonatomic, assign) LDRequestPriority requestPriority;

/** 调用接口 */
- (void)loadData;
/** 调用接口, 并以block形式处理返回数据，如果使用这种方式，则响应控制器不需要遵守LDBaseRequestCallBackDelegate，响应请求类也不需要设置delegate */
- (void)loadDataWithCompletionBlockWithSuccess:(LDRequestCompletionBlock)success
                                       failure:(LDRequestCompletionBlock)failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<LDRequestAccessory>)accessory;

//取消全部网络请求
- (void)cancelAllRequests;

//取消网络请求
- (void)cancel;

#pragma mark - Subclass Override

/// 请求的URL
- (NSString *)requestUrl;

///  Called on the main thread after request succeeded.
- (void)requestCompleteFilter;

///  Called on the main thread when request failed.
- (void)requestFailedFilter;

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的BaseURL
- (NSString *)baseUrl;

/// Http请求的方法
- (LDRequestType)requestType;

///  Additional request argument.
- (id)requestArgument;

/// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument;

/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary;

/// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructingBodyBlock;

// 是否允许使用蜂窝连接
- (BOOL)allowsCellularAccess;

///  This validator will be used to test if `responseStatusCode` is valid.
- (BOOL)statusCodeValidator;

@end
