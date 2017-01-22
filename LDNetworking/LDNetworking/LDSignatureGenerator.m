//
//  LDSignatureGenerator.m
//  LDNetworking
//
//  Created by YueHui on 17/1/22.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDSignatureGenerator.h"
#import <CommonCrypto/CommonDigest.h>
#import "LDCommonParamsGenerator.h"

@implementation LDSignatureGenerator

+ (NSDictionary *)ldUrlParamsSignForDictionary:(NSDictionary *)params {
    NSMutableDictionary *commonParams = [NSMutableDictionary dictionaryWithDictionary:[LDCommonParamsGenerator commonParamsDictionary]];
    [commonParams addEntriesFromDictionary:params];
    
    /**
     *  每个公司的签名方法不同，可以根据自己的设计进行修改，这里是将privateKey放在参数里面，然后将所有的参数和参数名转成字符串进行MD5，将得到的MD5值放进commonParams，上传的时候再讲privateKey从commonParams移除
     */
    //        commonParams[@"private_key"] = service.privateKey;
    //        NSString *signature = [LDSignatureGenerator sign:commonParams];
    //        commonParams[@"sign"] = signature;
    //        [commonParams removeObjectForKey:@"private_key"];
     commonParams[@"private_key"] = @"Oola_6d689f26128004186cea1b31686a4436";
    NSString *signature = [LDSignatureGenerator sign:commonParams];
    commonParams[@"kParamsMD5"] = signature;
    [commonParams removeObjectForKey:@"private_key"];
    
    return [commonParams copy];
}

+ (NSString *)sign:(NSDictionary *)dict {
    NSString *result;
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *sortedValues = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        [sortedValues addObject:key];
    }
    NSString *inputString;
    for (int i = 0; i < [sortedValues count]; i++) {
        if (i == 0) {
            inputString = [NSString stringWithFormat:@"%@=%@", [sortedValues objectAtIndex:i], [dict valueForKey:[sortedValues objectAtIndex:i]]];
        } else {
            inputString = [inputString stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", [sortedValues objectAtIndex:i], [dict valueForKey:[sortedValues objectAtIndex:i]]]];
        }
    }
    
    result = [self md5:inputString];
    
    return result;
}
+ (NSString *)md5:(NSString *)input {
    if(input == nil || [input length] == 0)
        return nil;
    
    const char *value = [input UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}



@end
