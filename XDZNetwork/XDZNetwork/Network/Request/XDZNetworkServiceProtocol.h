//
//  XDZNetworkServiceProtocol.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//  网络服务托管在moduleManager

#import <Foundation/Foundation.h>
#import "XDZModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XDZBaseRequestProtocol;

@protocol XDZNetworkServiceProtocol <XDZModuleProtocol>

/**
 * 添加一个网络请求
 *
 * @param request 服从红人装网络请求协议的实例
 *
 * @return 是否成功添加，参数类型或空值返回NO。
 *
 * @discuss 网络层稍后会启动这个请求，调用方从请求的委托函数中获取请求的执行结果。如果
 *               调用方需要知道请求的具体状态，可以通过观察请求的isExcuting等状态来实现。
 */
- (BOOL)addNetworkRequest:(id<XDZBaseRequestProtocol>)request;

/**
 * 取消一个网络请求
 *
 * @param request 服从红人装网络请求协议的实例
 *
 * @discuss 被取消的请求不会触发任何结果委托的回调
 *              网络服务会在取消所有请求后通知服务管理器终止本次网络服务
 */
- (void)cancelNetworRequest:(id<XDZBaseRequestProtocol>)request;

/**
 * 根据请求的ID取消对应的网络请求
 *
 * @param requestID 网络请求的tag字段
 *
 * @discussion 网络层会尝试搜索ID对应的网络请求，如果搜索成功则停止请求，如果网络层无法
 *             找到对应的请求，则该调用无任务操作
 */
- (void)cancelNetworkRequestByID:(NSString *)requestID;

/**
 * 取消所有的网络请求
 *
 * @discuss 网络服务会在取消所有请求后通知服务管理器终止本次网络服务
 */
- (void)cancelAllNetworkRequest;

@end

NS_ASSUME_NONNULL_END
