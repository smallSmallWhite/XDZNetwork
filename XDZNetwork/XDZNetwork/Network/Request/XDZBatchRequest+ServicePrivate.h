//
//  XDZBatchRequest+ServicePrivate.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//  该头文件定义了两个仅供网络服务使用的接口，一般使用者不需要使用该接口


NS_ASSUME_NONNULL_BEGIN

@interface XDZBatchRequest (ServicePrivate)

/**
 * 启动这批关联请求
 *
 * @discuss 该接口实际上让内部请求逐个添加到网络服务中，并将属于BatchRequest到底层request
 *          的计数逻辑启动。该接口不应该在网络层外任何地方调用
 */
- (void)start;

/**
 * 取消批量请求
 *
 * @discuss 当需要批量结束任务时调用，用户如果自己停止了某个请求，并不影线stop执行
 *             该接口不应该在网络层外任何地方调用
 */
- (void)stop;

/**
 * 访问内部成员
 */
- (NSArray<id<XDZBaseRequestProtocol>> *)requests;

@end

NS_ASSUME_NONNULL_END
