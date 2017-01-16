//
//  LDNetworkPrivate.m
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDNetworkPrivate.h"
#import "LDNetworkConfig.h"

void LDLog(NSString *format, ...) {
#ifdef DEBUG
    if (![LDNetworkConfig sharedInstance].debugLogEnabled) {
        return;
    }
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}

NSString *const LDRequestValidationErrorDomain = @"com.leihouya.request.validation";

@implementation LDNetworkUtils

+ (NSStringEncoding)stringEncodingWithRequest:(LDBaseRequest *)request {
    // From AFNetworking 2.6.3
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (request.response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)request.response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    return stringEncoding;
}

@end

@implementation LDNetworkPrivate

- (NSError *)convertError:(NSError *)error {
    
    NSInteger errorCode = LDRequestStateNoNetWork;
    if (error.code == NSURLErrorTimedOut) {
        errorCode = LDRequestStateTimeout;
    }
    return [NSError errorWithDomain:LDRequestValidationErrorDomain code:errorCode userInfo:error.userInfo];
}

@end
