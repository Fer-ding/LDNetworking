//
//  LDResponse.h
//  LDNetworking
//
//  Created by YueHui on 17/1/10.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LDResponseStatus)
{
    LDResponseStatusSuccess,  //服务器请求成功即设置为此状态,内容是否错误由各子类验证
    LDResponseStatusTimeout,
    LDResponseStatusNoNetwork  // 默认除了超时以外的错误都是无网络错误。
};

@interface LDResponse : NSObject

/** 状态 */
@property (nonatomic, assign, readonly) LDResponseStatus status;
/** 回调json字符串 */
@property (nonatomic, copy, readonly) NSString *contentString;
/** 回调对象, 字典或者数组 */
@property (nonatomic, copy, readonly) id content;
///** 请求记录id (app生命周期内递增不会减少) */
//@property (nonatomic, assign, readonly) NSInteger requestId;
/** 请求 */
@property (nonatomic, copy, readonly) NSURLRequest *request;
/** 回调json的二进制Data */
@property (nonatomic, copy, readonly) NSData *responseData;
/** 回调json的实际数据字典(不含返回码及message) */
@property (nonatomic, copy, readonly) NSDictionary *result;
/** 返回码 */
@property (nonatomic,assign, readonly) int responseCode;
/** 返回message */
@property (nonatomic,copy, readonly) NSString *responseMessage;
/** 错误信息 */
@property (nonatomic, strong, readonly) NSError *error;

/** 是否是缓存数据 */
@property (nonatomic, assign, readonly) BOOL isCache;

/** 回调成功 LDAPIResponse初始化方法 */
- (instancetype)initWithRequest:(NSURLRequest *)request responseObject:(id)responseObject;

/** 回调失败 SJAPIResponse初始化方法 */
- (instancetype)initWithRequest:(NSURLRequest *)request error:(NSError *)error;

/** 使用缓存数据 SJAPIResponse的初始化方法，它的isCache是YES，上面两个函数生成的response的isCache是NO */
- (instancetype)initWithData:(NSData *)data;

@end
