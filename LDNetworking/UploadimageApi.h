//
//  UploadimageApi.h
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDBaseRequest.h"
#import <UIKit/UIKit.h>

@interface UploadimageApi : LDBaseRequest

- (id)initWithImage:(UIImage *)image;

- (NSString *)responseImageId;

@end
