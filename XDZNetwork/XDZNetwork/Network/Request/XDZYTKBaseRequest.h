//
//  XDZYTKBaseRequest.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "YTKRequest.h"
#import "XDZNetworkCommonDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDZYTKBaseRequest : YTKRequest

/**
 * 设置自定义的header内容
 *
 * @param value 头部字段的值
 * @param headerField 头部字段
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString * _Nullable)headerField;

/**
 * 设置请求的数据
 *
 * @param requestParams 数据由业务自定义实现
 */
- (void)setRequestParams:(NSDictionary *)requestParams;

/**
 * 设置请求的方法
 *
 * @param requestMethod 参考commonDefines.h
 */
- (void)setRequestMethod:(XDZRequestMethod)requestMethod;

// 设置参数填充的方式
- (void)setRequestParamSerializeMethod:(XDZRequestParamSerializeMethod)serializeMethod;

// 设置返回数据的解释方式
- (void)setResponseSerializeMethod:(XDZResponseSerializeMethod)serializeMethod;

// 设置上请求地址
- (void)setRequestUrl:(NSURL *)requestUrl;

// 设置超时时间
- (void)setRequestTimeoutInterval:(NSTimeInterval)timeoutInterval;


@end

NS_ASSUME_NONNULL_END
