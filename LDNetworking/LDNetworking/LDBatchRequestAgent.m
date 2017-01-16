//
//  LDbatchRequestAgent.m
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBatchRequestAgent.h"
#import "LDBatchRequest.h"

@interface LDBatchRequestAgent()

@property (strong, nonatomic) NSMutableArray<LDBatchRequest *> *requestArray;

@end

@implementation LDBatchRequestAgent

+ (LDBatchRequestAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(LDBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(LDBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end
