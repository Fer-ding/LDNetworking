//
//  testApi.h
//  LDNetworking
//
//  Created by YueHui on 17/1/18.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDRequest.h"

@interface RegisterApi : LDRequest

- (void)loadDataWithUserName:(NSString *)username pwd:(NSString *)pwd;

@end
