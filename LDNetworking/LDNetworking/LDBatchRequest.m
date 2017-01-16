//
//  LDBatchRequest.m
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBatchRequest.h"
#import "LDNetworkPrivate.h"
#import "LDBatchRequestAgent.h"
#import "LDBaseRequest.h"

@interface LDBatchRequest() <LDBaseRequestCallBackDelegate>

@property (nonatomic) NSInteger finishedCount;

@end

@implementation LDBatchRequest

- (void)dealloc {
    [self clearRequest];
}

- (instancetype)initWithRequestArray:(NSArray<LDBaseRequest *> *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        _finishedCount = 0;
        for (LDBaseRequest * req in _requestArray) {
            if (![req isKindOfClass:[LDBaseRequest class]]) {
                LDLog(@"Error, request item must be LDRequest instance.");
                return nil;
            }
        }
    }
    return self;
}

- (void)loadData {
    if (_finishedCount > 0) {
        LDLog(@"Error! Batch request has already started.");
        return;
    }
    _failedRequest = nil;
    [[LDBatchRequestAgent sharedInstance] addBatchRequest:self];
    for (LDBaseRequest * req in _requestArray) {
        req.delegate = self;
        [req clearCompletionBlock];
        [req loadData];
    }
}

- (void)cancel {
    _delegate = nil;
    [self clearRequest];
    [[LDBatchRequestAgent sharedInstance] removeBatchRequest:self];
}

- (void)loadDataWithCompletionBlockWithSuccess:(void (^)(LDBatchRequest *))success failure:(void (^)(LDBatchRequest *))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self loadData];
}

- (void)setCompletionBlockWithSuccess:(void (^)(LDBatchRequest *batchRequest))success
                              failure:(void (^)(LDBatchRequest *batchRequest))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

#pragma mark - Network Request Delegate

- (void)requestDidSuccess:(LDBaseRequest *)request {
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
        if ([_delegate respondsToSelector:@selector(batchRequestDidSuccess:)]) {
            [_delegate batchRequestDidSuccess:self];
        }
        if (_successCompletionBlock) {
            _successCompletionBlock(self);
        }
        [self clearCompletionBlock];
        [[LDBatchRequestAgent sharedInstance] removeBatchRequest:self];
    }
}

- (void)requestDidFailed:(LDBaseRequest *)request {
    _failedRequest = request;
    
    // Cancel
    for (LDBaseRequest *req in _requestArray) {
        [req cancel];
    }
    
    // Callback
    if ([_delegate respondsToSelector:@selector(batchRequestDidFailed:)]) {
        [_delegate batchRequestDidFailed:self];
    }
    if (_failureCompletionBlock) {
        _failureCompletionBlock(self);
    }
    //Clear
    [self clearCompletionBlock];
    
    [[LDBatchRequestAgent sharedInstance] removeBatchRequest:self];
}

- (void)clearRequest {
    for (LDBaseRequest * req in _requestArray) {
        [req cancel];
    }
    [self clearCompletionBlock];
}

@end
