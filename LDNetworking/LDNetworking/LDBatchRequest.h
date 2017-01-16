//
//  LDBatchRequest.h
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LDBaseRequest;
@class LDBatchRequest;

//api回调
@protocol LDBatchRequestCallBackDelegate <NSObject>

@optional
- (void)batchRequestDidSuccess:(LDBatchRequest *)request;
- (void)batchRequestDidFailed:(LDBatchRequest *)request;

@end

@interface LDBatchRequest : NSObject

@property (nonatomic, strong) NSArray<LDBaseRequest *> *requestArray;
@property (nonatomic, weak) id<LDBatchRequestCallBackDelegate> delegate;
@property (nonatomic, copy) void (^successCompletionBlock)(LDBatchRequest *);
@property (nonatomic, copy) void (^failureCompletionBlock)(LDBatchRequest *);
@property (nonatomic, strong, readonly) LDBaseRequest *failedRequest;

- (instancetype)initWithRequestArray:(NSArray<LDBaseRequest *> *)requestArray;

/** 调用接口 */
- (void)loadData;
/** 调用接口, 并以block形式处理返回数据，如果使用这种方式，则响应控制器不需要遵守LDBaseRequestCallBackDelegate，响应请求类也不需要设置delegate */
- (void)loadDataWithCompletionBlockWithSuccess:(void (^)(LDBatchRequest *batchRequest))success
                                       failure:(void (^)(LDBatchRequest *batchRequest))failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

//取消网络请求
- (void)cancel;

@end
