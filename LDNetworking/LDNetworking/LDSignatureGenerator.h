//
//  LDSignatureGenerator.h
//  LDNetworking
//
//  Created by YueHui on 17/1/22.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDSignatureGenerator : NSObject
+ (NSDictionary *)ldUrlParamsSignForDictionary:(NSDictionary *)params;
@end
