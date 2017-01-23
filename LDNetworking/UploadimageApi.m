//
//  UploadimageApi.m
//  LDNetworking
//
//  Created by YueHui on 17/1/16.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "UploadimageApi.h"
#import "AFNetworking.h"

@implementation UploadimageApi {
    UIImage *_image;
}

- (void)loadDataWithImage:(UIImage *)image {
    _image = image;
    [self loadData];
}

- (LDRequestType)requestType {
    return LDRequestTypeUpload;
}

- (NSString *)requestUrl {
    return @"/iphone/image/upload";
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"image";
        NSString *formKey = @"image";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

- (void)requestCompleteFilter {
    NSDictionary *dict = self.responseJSONObject;
    NSString *imageId = dict[@"imageId"];
}


@end
