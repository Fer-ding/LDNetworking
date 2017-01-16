//
//  LDNetworkConfig.h
//  LDNetworking
//
//  Created by LeapDing on 2017/1/14.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LDBaseRequest;

///  LDUrlFilterProtocol can be used to append common parameters to requests before sending them.
@protocol LDUrlFilterProtocol <NSObject>

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(LDBaseRequest *)request;

@end

@interface LDNetworkConfig : NSObject

+ (LDNetworkConfig *)sharedInstance;

@property (nonatomic, strong) NSString *baseUrl;

///  Whether to log debug info. Default is NO;
@property (nonatomic) BOOL debugLogEnabled;

@property (nonatomic, strong, readonly) NSArray<id<LDUrlFilterProtocol>> *urlFilters;

///  Add a new URL filter.
- (void)addUrlFilter:(id<LDUrlFilterProtocol>)filter;
///  Remove all URL filters.
- (void)clearUrlFilter;

@end
