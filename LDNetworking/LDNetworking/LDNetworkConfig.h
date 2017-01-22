//
//  LDNetworkConfig.h
//  LDNetworking
//
//  Created by LeapDing on 2017/1/14.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDBaseRequest.h"

@interface LDNetworkConfig : NSObject

+ (LDNetworkConfig *)sharedInstance;

@property (nonatomic, strong) NSString *baseUrl;

///  Whether to log debug info. Default is NO;
@property (nonatomic, assign) BOOL debugLogEnabled;


@end
