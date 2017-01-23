//
//  UploadimageApi.h
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "LDRequest.h"
#import <UIKit/UIKit.h>

@interface UploadimageApi : LDRequest

- (void)loadDataWithImage:(UIImage *)image;

@end
