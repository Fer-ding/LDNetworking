//
//  testApi.m
//  LDNetworking
//
//  Created by YueHui on 17/1/18.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "RegisterApi.h"

@implementation RegisterApi {
    NSString *_username;
    NSString *_password;
}

- (NSString *)requestUrl {
    return @"recycler/recycler-data";
}

- (void)loadDataWithUserName:(NSString *)username pwd:(NSString *)pwd {
    
    _username = username;
    _password = pwd;
    [self loadData];
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 3;
}

- (id)requestArgument {
    return @{@"username":_username,
             @"password":_password};
}

- (void)requestCompleteFilter {
    //在这里做转模型的事
}
@end
