//
//  LDRequest.h
//  LDNetworking
//
//  Created by YueHui on 17/1/17.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBaseRequest.h"

@interface LDRequest : LDBaseRequest

/// 选择是否忽视cache, Default use cache.
@property (nonatomic, assign) BOOL ignoreCache;

/// 是否当前的数据从缓存获得
- (BOOL)isDataFromCache;

/// 强制更新缓存
- (void)loadDataWithoutCache;

/// 手动将其他请求的JsonResponse写入该请求的缓存
- (void)saveJsonResponseToCacheFile:(id)jsonResponse;

- (NSInteger)cacheTimeInSeconds;

@end
