//
//  LDNetworkConfig.h
//  LDNetworking
//
//  Created by LeapDing on 2017/1/14.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBaseRequest.h"

///  LDCacheDirPathFilterProtocol can be used to append common path components when caching response results
@protocol LDCacheDirPathFilterProtocol <NSObject>
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(LDBaseRequest *)request;
@end

@interface LDNetworkConfig : NSObject

+ (LDNetworkConfig *)sharedInstance;

@property (nonatomic, strong) NSString *baseUrl;

///  Whether to log debug info. Default is NO;
@property (nonatomic, assign) BOOL debugLogEnabled;

@property (strong, nonatomic, readonly) NSArray *cacheDirPathFilters;

- (void)addCacheDirPathFilter:(id <LDCacheDirPathFilterProtocol>)filter;

@end
