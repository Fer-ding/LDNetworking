//
//  LDRequest.h
//  LDNetworking
//
//  Created by YueHui on 17/1/17.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBaseRequest.h"

@interface LDRequest : LDBaseRequest

@property (nonatomic, assign) BOOL isnoreCache;
- (BOOL)isDataFromCache;

- (NSInteger)cacheTimeInSeconds;

@end
