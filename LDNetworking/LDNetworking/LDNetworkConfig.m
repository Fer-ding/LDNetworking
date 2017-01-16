//
//  LDNetworkConfig.m
//  LDNetworking
//
//  Created by LeapDing on 2017/1/14.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDNetworkConfig.h"

@implementation LDNetworkConfig {
    NSMutableArray<id<LDUrlFilterProtocol>> *_urlFilters;
}

+ (LDNetworkConfig *)sharedInstance {
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
        _baseUrl = @"";
    }
    return self;
}

- (void)addUrlFilter:(id<LDUrlFilterProtocol>)filter {
    [_urlFilters addObject:filter];
}

- (void)clearUrlFilter {
    [_urlFilters removeAllObjects];
}

@end
