//
//  LDNetworkPrivate.m
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
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

+ (NSString *)md5StringFromString:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

@end
