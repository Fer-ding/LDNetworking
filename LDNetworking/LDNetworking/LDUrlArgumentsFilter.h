//
//  LDUrlArgumentsFilter.h
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBaseRequest.h"
#import "LDNetworkConfig.h"

@interface LDUrlArgumentsFilter : NSObject <LDUrlFilterProtocol>

+ (LDUrlArgumentsFilter *)filterWithArguments:(NSDictionary *)arguments;

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(LDBaseRequest *)request;

@end
