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

@protocol AFMultipartFormData;

@class LDBaseRequest;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void(^LDRequestCompletionBlock)(__kindof LDBaseRequest *request);

//api回调
@protocol LDBaseRequestCallBackDelegate <NSObject>

@optional
- (void)requestDidSuccess:(LDBaseRequest *)request;
- (void)requestDidFailed:(LDBaseRequest *)request;

@end

#pragma mark - 获取调用API所需要的参数
@protocol LDBaseRequestParamDelegate <NSObject>
@required
- (NSDictionary *)paramsForRequest:(LDBaseRequest *)request;
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

@property (nonatomic, weak) id<LDBaseRequestParamDelegate> paramSource;
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
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

/** 调用接口 */
- (void)loadData;
/** 调用接口, 并以block形式处理返回数据，如果使用这种方式，则响应控制器不需要遵守LDBaseRequestCallBackDelegate，响应请求类也不需要设置delegate */
- (void)loadDataWithCompletionBlockWithSuccess:(LDRequestCompletionBlock)success
                                       failure:(LDRequestCompletionBlock)failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

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

/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary;

/// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructingBodyBlock;

// 是否允许使用蜂窝连接
- (BOOL)allowsCellularAccess;

///  This validator will be used to test if `responseStatusCode` is valid.
- (BOOL)statusCodeValidator;

@end
