//
//  XDZBaseRequest.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
// 享多赚的网络请求基类

#import <Foundation/Foundation.h>
#import "XDZBaseRequestProtocol.h"
#import <YTKBaseRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDZBaseRequest : NSObject <XDZBaseRequestProtocol, YTKRequestAccessory>

@end

NS_ASSUME_NONNULL_END
