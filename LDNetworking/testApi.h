//
//  testApi.h
//  LDNetworking
//
//  Created by YueHui on 17/1/18.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBaseRequest.h"

@interface testApi : LDBaseRequest

- (void)loadDataWithUserName:(NSString *)username pwd:(NSString *)pwd;

@end
