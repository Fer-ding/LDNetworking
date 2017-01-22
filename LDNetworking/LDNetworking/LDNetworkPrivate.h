//
//  LDNetworkPrivate.h
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBaseRequest.h"

FOUNDATION_EXPORT void LDLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);


@interface LDNetworkUtils : NSObject

+ (NSStringEncoding)stringEncodingWithRequest:(LDBaseRequest *)request;

+ (NSString *)md5StringFromString:(NSString *)string;

@end


