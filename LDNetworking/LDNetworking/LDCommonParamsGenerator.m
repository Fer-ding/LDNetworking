//
//  LDCommonParamsGenerator.m
//  LDNetworking
//
//  Created by YueHui on 17/1/22.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDCommonParamsGenerator.h"

@implementation LDCommonParamsGenerator

+ (NSDictionary *)commonParamsDictionary {
    
    return @{@"date": [NSNumber numberWithInteger:[NSDate date].timeIntervalSince1970]};
}


@end
