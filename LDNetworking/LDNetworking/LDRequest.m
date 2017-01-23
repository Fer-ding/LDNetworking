//
//  LDRequest.m
//  LDNetworking
//
//  Created by YueHui on 17/1/17.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDRequest.h"
#import "LDNetworkPrivate.h"
#import "LDNetworkConfig.h"

@interface LDRequest ()

@property (nonatomic, assign) BOOL dataFromCache;

@property (nonatomic, strong) id cacheJson;

@end

@implementation LDRequest

- (void)loadData {
    if (self.ignoreCache) {
        [self loadDataWithoutCache];
        return;
    }
    
    // check cache time
    if ([self cacheTimeInSeconds] < 0) {
        [super loadData];
        return;
    }
    
    // check cache existance
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        [super loadData];
        return;
    }
    
    // check cache time
    int seconds = [self cacheFileDuration:path];
    if (seconds < 0 || seconds > [self cacheTimeInSeconds]) {
        [super loadData];
        return;
    }
    
    // load cache
    _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (_cacheJson == nil) {
        [super loadData];
        return;
    }
    
    _dataFromCache = YES;
    
    [self requestCompleteFilter];
    LDRequest *strongSelf = self;
    [strongSelf.delegate requestDidSuccess:strongSelf];
    if (strongSelf.successCompletionBlock) {
        strongSelf.successCompletionBlock(strongSelf);
    }
    [strongSelf clearCompletionBlock];
}

- (void)loadDataWithoutCache {
    [self clearCacheVariables];
    [super loadData];
}

#pragma mark - Subclass Override

- (NSInteger)cacheTimeInSeconds {
    return -1;
}

#pragma mark -

- (BOOL)isDataFromCache {
    return _dataFromCache;
}

- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        LDLog(@"create cache directory failed, error = %@",error);
    } else {
        [LDNetworkPrivate addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];
    
    // filter cache base path
    NSArray *filters = [[LDNetworkConfig sharedInstance] cacheDirPathFilters];
    if (filters.count > 0) {
        for (id<LDCacheDirPathFilterProtocol> f in filters) {
            path = [f filterCacheDirPath:path withRequest:self];
        }
    }
    
    [self checkDirectory:path];
    return path;
}

- (NSString *)cacheFileName {
    NSString *requestUrl = [self requestUrl];
    NSString *baseUrl = [LDNetworkConfig sharedInstance].baseUrl;
    id argument = [self cacheFileNameFilterForRequestArgument:[self requestArgument]];
    NSString *requestInfo = [NSString stringWithFormat:@"Type:%ld Host:%@ Url:%@ Argument:%@",
                             (long)[self requestType], baseUrl, requestUrl,
                             argument];
    NSString *cacheFileName = [LDNetworkPrivate md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheFilePath {
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        LDLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

- (id)cacheJson {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        return _cacheJson;
    }
}

- (id)responseJSONObject {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        return [super responseJSONObject];
    }
}

- (void)clearCacheVariables {
    _cacheJson = nil;
    _dataFromCache = NO;
}

#pragma mark - Network Request Delegate

- (void)requestCompleteFilter {
    [super requestCompleteFilter];
    [self saveJsonResponseToCacheFile:[super responseJSONObject]];
}

// 手动将其他请求的JsonResponse写入该请求的缓存
// 比如AddNoteApi, UpdateNoteApi都会获得Note，且其与GetNoteApi共享缓存，可以通过这个接口写入GetNoteApi缓存
- (void)saveJsonResponseToCacheFile:(id)jsonResponse {
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        NSDictionary *json = jsonResponse;
        if (json != nil) {
            [NSKeyedArchiver archiveRootObject:json toFile:[self cacheFilePath]];
        }
    }
}


@end
