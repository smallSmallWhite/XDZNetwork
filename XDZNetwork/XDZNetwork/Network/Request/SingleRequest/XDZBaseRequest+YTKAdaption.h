//
//  XDZBaseRequest+YTKAdaption.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//  该分类提供了XDZBaseRequest访问内部请求的能力，是对网络层是用
//  YTKNetworkAgent驱动的妥协

#import "XDZBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDZBaseRequest (YTKAdaption)

// 为适配NetworkManager底层的YTKNetworkAgent，需要支持提供
// 内部使用的request的访问入口。
@property (nonatomic, strong, readonly, nullable) id coreRequest;

@end

NS_ASSUME_NONNULL_END
