//
//  LDNetworkConfig.m
//  LDNetworking
//
//  Created by LeapDing on 2017/1/14.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDNetworkConfig.h"

@implementation LDNetworkConfig {
    NSMutableArray *_cacheDirPathFilters;
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
        _debugLogEnabled = NO;
        _cacheDirPathFilters = [NSMutableArray array];
    }
    return self;
}

- (void)addCacheDirPathFilter:(id<LDCacheDirPathFilterProtocol>)filter {
    [_cacheDirPathFilters addObject:filter];
}

- (NSArray *)cacheDirPathFilters {
    return [_cacheDirPathFilters copy];
}

@end
